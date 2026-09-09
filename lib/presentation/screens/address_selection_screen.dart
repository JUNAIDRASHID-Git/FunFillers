import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' hide Path;

import '../../domain/entities/address.dart';

class AddressSelectionScreen extends StatefulWidget {
  final Address? initialAddress;

  const AddressSelectionScreen({
    super.key,
    this.initialAddress,
  });

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final MapController _mapController = MapController();
  late Address _selectedAddress;

  // Reference coordinates for distance calculation
  double _initialLat = 12.9716;
  double _initialLng = 77.5946;

  double _currentLat = 12.9716;
  double _currentLng = 77.5946;

  String _localityName = 'Detecting location...';
  String _subAddressLine = 'Locating area details...';
  String _distanceNotice = 'Delivering to this location';

  bool _isGeocoding = false;
  bool _isSearching = false;
  bool _isLocating = false;
  bool _isCameraMoving = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _selectedAddress = widget.initialAddress!;
      _currentLat = _selectedAddress.latitude;
      _currentLng = _selectedAddress.longitude;
      _initialLat = _currentLat;
      _initialLng = _currentLng;
      _localityName = _selectedAddress.title.isNotEmpty
          ? _selectedAddress.title
          : _selectedAddress.city;
      _subAddressLine = '${_selectedAddress.city} - ${_selectedAddress.country}';
      _updateDistanceNotice(_currentLat, _currentLng);
    } else {
      _selectedAddress = const Address(
        id: 'addr_selected',
        title: 'Home',
        label: 'Home',
        fullAddress: 'Detecting address...',
        city: 'Bengaluru',
        state: 'Karnataka',
        country: 'India',
        pincode: '560001',
        latitude: 12.9716,
        longitude: 77.5946,
        altitude: 920.0,
      );
      // Automatically request device location for accurate customer location
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestAndFetchDeviceLocation();
      });
    }

    _reverseGeocode(_currentLat, _currentLng);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Request device location permission and obtain accurate GPS coordinates
  Future<void> _requestAndFetchDeviceLocation({bool isUserTriggered = false}) async {
    if (!mounted) return;
    setState(() => _isLocating = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (isUserTriggered && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable GPS / Location services on your device.'),
              backgroundColor: Color(0xFFB45309),
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      bool locationFound = false;

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Try medium accuracy first (most reliable on desktop Chrome / macOS)
        try {
          final Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 4),
            ),
          );
          locationFound = true;
          _applyCoordinates(position.latitude, position.longitude);
        } catch (_) {
          // If medium accuracy failed, try low accuracy
          try {
            final Position position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
                timeLimit: Duration(seconds: 3),
              ),
            );
            locationFound = true;
            _applyCoordinates(position.latitude, position.longitude);
          } catch (_) {}
        }
      }

      // If browser GPS/CoreLocation was unavailable, fall back to accurate network IP geolocation
      if (!locationFound) {
        try {
          final res = await http
              .get(Uri.parse('https://ipwho.is/'))
              .timeout(const Duration(seconds: 4));
          if (res.statusCode == 200) {
            final data = json.decode(res.body);
            if (data['success'] == true) {
              final double? lat = (data['latitude'] as num?)?.toDouble();
              final double? lon = (data['longitude'] as num?)?.toDouble();
              if (lat != null && lon != null) {
                locationFound = true;
                _applyCoordinates(lat, lon);
              }
            }
          }
        } catch (e) {
          debugPrint('Network geolocation error: $e');
        }
      }

      if (!locationFound && isUserTriggered && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not auto-detect location. Please search your area or drag the map.'),
            backgroundColor: Color(0xFFB45309),
          ),
        );
      }
    } catch (e) {
      debugPrint('Device location detection error: $e');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _applyCoordinates(double lat, double lon) {
    if (!mounted) return;
    setState(() {
      _currentLat = lat;
      _currentLng = lon;
      _initialLat = lat;
      _initialLng = lon;
    });

    _mapController.move(LatLng(lat, lon), 16.5);
    _updateDistanceNotice(lat, lon);
    _reverseGeocode(lat, lon);
  }

  double _calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  void _updateDistanceNotice(double lat, double lng) {
    final dist = _calculateDistanceKm(_initialLat, _initialLng, lat, lng);
    if (dist < 0.5) {
      _distanceNotice = 'Delivering to this location';
    } else if (dist > 999) {
      _distanceNotice = 'Pin is 999+ km away from your current location';
    } else {
      _distanceNotice = 'Pin is ${dist.toStringAsFixed(0)} km away from your current location';
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    if (!mounted) return;
    setState(() => _isGeocoding = true);

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&addressdetails=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'FunFillersApp/1.0 (contact@funfillers.com)'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addressDetails = data['address'] as Map<String, dynamic>?;

        final building = addressDetails?['building'] ??
            addressDetails?['house_name'] ??
            addressDetails?['amenity'] ??
            addressDetails?['shop'] ??
            addressDetails?['office'] ??
            data['name'];

        final road = addressDetails?['road'] ??
            addressDetails?['pedestrian'] ??
            addressDetails?['suburb'] ??
            addressDetails?['neighbourhood'] ??
            addressDetails?['residential'] ??
            addressDetails?['hamlet'];

        final locality = addressDetails?['village'] ??
            addressDetails?['town'] ??
            addressDetails?['city'] ??
            addressDetails?['city_district'] ??
            addressDetails?['county'] ??
            'Location';

        final state = addressDetails?['state'] ?? '';
        final country = addressDetails?['country'] ?? 'India';
        final postcode = addressDetails?['postcode'] ?? '';
        final displayName = data['display_name']?.toString() ?? '';

        String primaryTitle = (building ?? road ?? locality).toString().trim();
        if (primaryTitle.isEmpty || primaryTitle == 'null') {
          primaryTitle = 'Selected Location';
        }

        List<String> subParts = [];
        if (locality != primaryTitle && locality.isNotEmpty && locality != 'null') {
          subParts.add(locality);
        }
        if (state.isNotEmpty && state != primaryTitle && state != locality && state != 'null') {
          subParts.add(state);
        }
        if (country.isNotEmpty && country != 'null') {
          subParts.add(country);
        }

        String subTitleStr = subParts.isNotEmpty
            ? subParts.join(', ').replaceAll(', $country', ' - $country')
            : country;

        if (mounted) {
          setState(() {
            _localityName = primaryTitle;
            _subAddressLine = subTitleStr;
            _selectedAddress = Address(
              id: _selectedAddress.id,
              name: _selectedAddress.name,
              fullAddress: displayName.length > 80
                  ? displayName.substring(0, 80)
                  : displayName,
              city: locality != 'Location' ? locality : 'City',
              state: state,
              country: country,
              pincode: postcode,
              label: _selectedAddress.label,
              latitude: lat,
              longitude: lng,
              altitude: _selectedAddress.altitude,
            );
          });
        }
      }
    } catch (_) {
      // Retain coordinates even if network times out
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=5&addressdetails=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'FunFillersApp/1.0 (contact@funfillers.com)'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        if (mounted) {
          setState(() {
            _searchResults = list.map((e) => e as Map<String, dynamic>).toList();
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _searchResults = []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(Map<String, dynamic> item) {
    final double? lat = double.tryParse(item['lat']?.toString() ?? '');
    final double? lon = double.tryParse(item['lon']?.toString() ?? '');

    if (lat != null && lon != null) {
      _currentLat = lat;
      _currentLng = lon;

      _mapController.move(LatLng(lat, lon), 16.5);

      final addressDetails = item['address'] as Map<String, dynamic>?;
      final road = addressDetails?['road'] ??
          addressDetails?['suburb'] ??
          item['name'] ??
          'Location';
      final city = addressDetails?['city'] ??
          addressDetails?['town'] ??
          addressDetails?['county'] ??
          'City';
      final state = addressDetails?['state'] ?? '';
      final country = addressDetails?['country'] ?? 'Country';
      final postcode = addressDetails?['postcode'] ?? '';
      final displayName = item['display_name'] ?? '';

      setState(() {
        _searchController.text = item['name'] ?? displayName;
        _searchResults = [];
        _localityName = road;
        _subAddressLine = '$city - $country';
        _selectedAddress = Address(
          id: _selectedAddress.id,
          name: _selectedAddress.name,
          fullAddress: displayName.length > 80
              ? displayName.substring(0, 80)
              : displayName,
          city: city,
          state: state,
          country: country,
          pincode: postcode,
          label: _selectedAddress.label,
          latitude: lat,
          longitude: lon,
          altitude: _selectedAddress.altitude,
        );
      });
      _updateDistanceNotice(lat, lon);
      FocusScope.of(context).unfocus();
    }
  }



  void _confirmAndSubmitAddress() {
    Navigator.pop(context, _selectedAddress);
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom < 20.0) {
      _mapController.move(_mapController.camera.center, currentZoom + 1.0);
    }
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom > 3.0) {
      _mapController.move(_mapController.camera.center, currentZoom - 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Full Screen Interactive Map with Google Maps Tiles (Detailed buildings, NO watermark, NO API key required!)
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(_currentLat, _currentLng),
                initialZoom: 16.5,
                minZoom: 3.0,
                maxZoom: 20.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onPositionChanged: (camera, hasGesture) {
                  if (hasGesture) {
                    _currentLat = camera.center.latitude;
                    _currentLng = camera.center.longitude;
                    if (!_isCameraMoving) {
                      setState(() => _isCameraMoving = true);
                    }
                  }
                },
                onMapEvent: (event) {
                  if (event is MapEventMoveEnd) {
                    setState(() => _isCameraMoving = false);
                    _updateDistanceNotice(_currentLat, _currentLng);
                    _debounceTimer?.cancel();
                    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
                      _reverseGeocode(_currentLat, _currentLng);
                    });
                  }
                },
                onTap: (tapPosition, point) {
                  _mapController.move(point, _mapController.camera.zoom);
                  setState(() {
                    _currentLat = point.latitude;
                    _currentLng = point.longitude;
                  });
                  _updateDistanceNotice(point.latitude, point.longitude);
                  _reverseGeocode(point.latitude, point.longitude);
                },
              ),
              children: [
                // High-definition Google Maps Tiles: Detailed buildings, houses, stores & roads with ZERO watermarks!
                TileLayer(
                  urlTemplate: 'https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                  subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                  userAgentPackageName: 'com.funfillers.app',
                  maxZoom: 20,
                ),
              ],
            ),
          ),

          // 2. Fixed Center Screen Delivery Pin with Noon Speech Bubble
          Center(
            child: Transform.translate(
              offset: const Offset(0, -22), // Anchors the pin point exactly at center
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Speech bubble: "Your order will be delivered here"
                  AnimatedScale(
                    scale: _isCameraMoving ? 0.92 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isGeocoding)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                  color: Color(0xFF3866DF),
                                ),
                              ),
                            ),
                          const Text(
                            'Your order will be delivered here',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Downward pointing arrow of speech bubble
                  CustomPaint(
                    size: const Size(12, 6),
                    painter: BubbleTrianglePainter(),
                  ),
                  const SizedBox(height: 2),

                  // Black Location Pin Marker (Noon style)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 44,
                        color: Color(0xFF000000),
                      ),
                      Positioned(
                        top: 9,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Ground contact shadow
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: _isCameraMoving ? 8 : 12,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Noon Floating Search Bar (Top)
          Positioned(
            top: topInset + 12,
            left: 16,
            right: 16,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: Color(0xFF1F2937),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: (val) {
                                _debounceTimer?.cancel();
                                _debounceTimer = Timer(
                                  const Duration(milliseconds: 350),
                                  () => _searchLocation(val),
                                );
                              },
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1F2937),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Search for your building, area...',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_isSearching)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF3866DF),
                                ),
                              ),
                            )
                          else if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: Color(0xFF6B7280)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: Icon(
                                Icons.search,
                                size: 22,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Search Results List
                    if (_searchResults.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = _searchResults[index];
                            return ListTile(
                              leading: const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF3866DF),
                              ),
                              title: Text(
                                item['name'] ?? item['display_name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                item['display_name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _selectSearchResult(item),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Floating Zoom Controls (+ / -)
          Positioned(
            right: 16,
            bottom: 216 + bottomInset,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    onTap: _zoomIn,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.add, size: 20, color: Color(0xFF1F2937)),
                    ),
                  ),
                  const SizedBox(
                    width: 24,
                    child: Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                  ),
                  InkWell(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                    onTap: _zoomOut,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.remove, size: 20, color: Color(0xFF1F2937)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Floating "Current location" Pill Button (Triggers device GPS permission)
          Positioned(
            left: 0,
            right: 0,
            bottom: 216 + bottomInset,
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _requestAndFetchDeviceLocation(isUserTriggered: true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLocating)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF3866DF),
                            ),
                          ),
                        )
                      else
                        Transform.rotate(
                          angle: -pi / 4,
                          child: const Icon(
                            Icons.navigation_rounded,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _isLocating ? 'Locating...' : 'Current location',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 5. Noon Bottom Sheet Container (Docked with curved top corners)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Inner Location Info Box
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Section with Black Pin & Location Texts
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF3F4F6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.location_on,
                                          color: Colors.black,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _localityName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF111827),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              _subAddressLine,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF4B5563),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Light Orange / Peach Distance Notice Banner
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFDF0E1),
                                  ),
                                  child: Text(
                                    _distanceNotice,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Noon Royal Blue "Add address details" Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3866DF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ).copyWith(
                                overlayColor: WidgetStateProperty.resolveWith<Color?>(
                                  (states) {
                                    if (states.contains(WidgetState.hovered)) {
                                      return const Color(0xFF2552C7);
                                    }
                                    if (states.contains(WidgetState.pressed)) {
                                      return const Color(0xFF1D42A7);
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              onPressed: _confirmAndSubmitAddress,
                              child: const Text(
                                'Add address details',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Downward pointer arrow for speech bubble
class BubbleTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
