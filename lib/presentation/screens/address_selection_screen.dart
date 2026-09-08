import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/address.dart';
import '../widgets/custom_button.dart';

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
  late Address _selectedAddress;

  final List<Address> _dummyAddresses = const [
    Address(
      id: 'addr_1',
      title: 'Home',
      fullAddress: '123 Toy Street, 2nd Floor',
      city: 'Green Park, Bangalore - 560001',
      state: 'Karnataka',
      country: 'India',
      latitude: 12.9716,
      longitude: 77.5946,
      isDefault: true,
    ),
    Address(
      id: 'addr_2',
      title: 'Office',
      fullAddress: '456 Tech Park, Sector 4',
      city: 'Whitefield, Bangalore - 560066',
      state: 'Karnataka',
      country: 'India',
      latitude: 12.9698,
      longitude: 77.7499,
      isDefault: false,
    ),
  ];

  double _lat = 12.9716;
  double _lng = 77.5946;
  double _alt = 920.0;

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.initialAddress ?? _dummyAddresses.first;
    _lat = _selectedAddress.latitude;
    _lng = _selectedAddress.longitude;
    _alt = _selectedAddress.altitude;
  }

  void _onMapTapped(TapDownDetails details, Size size) {
    // Dynamically calculate latitude/longitude/altitude variance based on tap position
    final dx = (details.localPosition.dx / size.width - 0.5) * 0.02;
    final dy = (0.5 - details.localPosition.dy / size.height) * 0.02;
    setState(() {
      _lat = double.parse((_lat + dy).toStringAsFixed(4));
      _lng = double.parse((_lng + dx).toStringAsFixed(4));
      _alt = double.parse((_alt + (dy * 100)).toStringAsFixed(1));
      _selectedAddress = Address(
        id: _selectedAddress.id,
        name: _selectedAddress.name,
        fullAddress: _selectedAddress.fullAddress,
        city: _selectedAddress.city,
        state: _selectedAddress.state,
        country: _selectedAddress.country,
        pincode: _selectedAddress.pincode,
        label: _selectedAddress.label,
        latitude: _lat,
        longitude: _lng,
        altitude: _alt,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Delivery Location',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Map Container matching exact mockup UI
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final mapSize = Size(constraints.maxWidth, constraints.maxHeight);
                return GestureDetector(
                  onTapDown: (details) => _onMapTapped(details, mapSize),
                  child: Stack(
                    children: [
                      // Simulated Map Graphics
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: const Color(0xFFE5E9EC),
                        child: CustomPaint(
                          painter: MapBackgroundPainter(),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentOrange.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentOrange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'Lat: $_lat, Lng: $_lng',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Search location overlay input
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              icon: Icon(Icons.search, color: AppColors.textMuted),
                              hintText: 'Search Google Maps location',
                              hintStyle: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      // Bottom map action floating buttons
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: Column(
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'my_location',
                              backgroundColor: Colors.white,
                              onPressed: () {
                                setState(() {
                                  _lat = 12.9716;
                                  _lng = 77.5946;
                                  _alt = 920.0;
                                  _selectedAddress = Address(
                                    id: _selectedAddress.id,
                                    name: _selectedAddress.name,
                                    fullAddress: _selectedAddress.fullAddress,
                                    city: _selectedAddress.city,
                                    state: _selectedAddress.state,
                                    country: _selectedAddress.country,
                                    pincode: _selectedAddress.pincode,
                                    label: _selectedAddress.label,
                                    latitude: _lat,
                                    longitude: _lng,
                                    altitude: _alt,
                                  );
                                });
                              },
                              child: const Icon(Icons.my_location,
                                  color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'layers',
                              backgroundColor: Colors.white,
                              onPressed: () {},
                              child: const Icon(Icons.layers_outlined,
                                  color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Address Card & Select Button Bottom Sheet
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedAddress.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_selectedAddress.fullAddress}, ${_selectedAddress.city}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.explore_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Lat: $_lat  •  Lng: $_lng  •  Alt: ${_alt}m',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Use this Location Address',
                    onPressed: () {
                      Navigator.pop(context, _selectedAddress);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Decorative Painter to mimic modern Map graphics
class MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintRoad = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final paintSecondaryRoad = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final paintPark = Paint()
      ..color = const Color(0xFFD4E7D0)
      ..style = PaintingStyle.fill;

    // Green Park area
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 40, size.width * 0.4, size.height * 0.3),
        const Radius.circular(16),
      ),
      paintPark,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            size.width * 0.65, size.height * 0.5, size.width * 0.3, size.height * 0.35),
        const Radius.circular(16),
      ),
      paintPark,
    );

    // Main Roads
    final path1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..cubicTo(size.width * 0.3, size.height * 0.3, size.width * 0.7,
          size.height * 0.6, size.width, size.height * 0.5);

    final path2 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.5, size.height);

    canvas.drawPath(path1, paintRoad);
    canvas.drawPath(path2, paintSecondaryRoad);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
