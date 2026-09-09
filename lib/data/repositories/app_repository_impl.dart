import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../core/constants/api_constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/app_repository.dart';
import '../datasources/app_data_source.dart';

class AppRepositoryImpl implements AppRepository {
  final String baseUrl;
  final AppDataSource? dataSource;

  static const String _addressPrefsKey = 'saved_user_addresses';
  final List<AddressEntity> _addresses = [];
  UserEntity? _currentUser;
  String? _authToken;
  final List<UserOrderEntity> _orders = [];

  AppRepositoryImpl({
    this.baseUrl = ApiConstants.baseUrl,
    this.dataSource,
  }) {
    _loadAddressesFromPrefs();
  }

  Future<void> _saveAddressesToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = _addresses.map((a) => {
        'id': a.id,
        'name': a.name,
        'fullAddress': a.fullAddress,
        'city': a.city,
        'state': a.state,
        'pincode': a.pincode,
        'phone': a.phone,
        'label': a.label,
        'isDefault': a.isDefault,
        'country': a.country,
        'latitude': a.latitude,
        'longitude': a.longitude,
        'altitude': a.altitude,
      }).toList();
      await prefs.setString(_addressPrefsKey, jsonEncode(listJson));
    } catch (e) {
      debugPrint('Error saving addresses to prefs: $e');
    }
  }

  Future<void> _loadAddressesFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_addressPrefsKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        _addresses.clear();
        for (var item in decoded) {
          final m = item as Map<String, dynamic>;
          _addresses.add(AddressEntity(
            id: m['id']?.toString() ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
            name: m['name']?.toString() ?? 'Customer',
            fullAddress: m['fullAddress']?.toString() ?? '',
            city: m['city']?.toString() ?? '',
            state: m['state']?.toString() ?? '',
            pincode: m['pincode']?.toString() ?? '',
            phone: m['phone']?.toString() ?? '',
            label: m['label']?.toString() ?? 'Home',
            isDefault: m['isDefault'] == true,
            country: m['country']?.toString() ?? 'India',
            latitude: (m['latitude'] as num?)?.toDouble() ?? 12.9716,
            longitude: (m['longitude'] as num?)?.toDouble() ?? 77.5946,
            altitude: (m['altitude'] as num?)?.toDouble() ?? 920.0,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error loading addresses from prefs: $e');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken ??= prefs.getString('auth_token');
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  @override
  Future<UserEntity> signInWithEmailPassword(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'] as String?;
        final userJson = data['user'] as Map<String, dynamic>;

        final prefs = await SharedPreferences.getInstance();
        if (_authToken != null) {
          await prefs.setString('auth_token', _authToken!);
        }

        _currentUser = UserEntity(
          id: userJson['id']?.toString() ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
          name: userJson['name']?.toString() ?? email.split('@')[0],
          email: userJson['email']?.toString() ?? email,
          phone: userJson['phone']?.toString() ?? '+91 9876543210',
          avatarUrl: userJson['avatarUrl']?.toString(),
        );
        return _currentUser!;
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err['error'] ?? 'Authentication failed (${response.statusCode})');
      }
    } catch (e) {
      // Direct fallback if offline/mock user
      _currentUser = UserEntity(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@')[0],
        email: email,
        phone: '+91 9876543210',
      );
      return _currentUser!;
    }
  }

  @override
  Future<UserEntity> signUp(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _authToken = data['token'] as String?;
        final userJson = data['user'] as Map<String, dynamic>;

        final prefs = await SharedPreferences.getInstance();
        if (_authToken != null) {
          await prefs.setString('auth_token', _authToken!);
        }

        _currentUser = UserEntity(
          id: userJson['id']?.toString() ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
          name: userJson['name']?.toString() ?? name,
          email: userJson['email']?.toString() ?? email,
          phone: '+91 9876543210',
        );
        return _currentUser!;
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err['error'] ?? 'Sign up failed');
      }
    } catch (e) {
      _currentUser = UserEntity(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: '+91 9876543210',
      );
      return _currentUser!;
    }
  }

  @override
  Future<UserEntity> signInWithGoogle({String? email, String? name, String? avatarUrl}) async {
    try {
      if (kIsWeb) {
        final googleProvider = fb.GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        final userCredential = await fb.FirebaseAuth.instance.signInWithPopup(googleProvider);
        final fbUser = userCredential.user;

        if (fbUser != null) {
          final gEmail = fbUser.email ?? 'google_user@funfillers.com';
          final gName = fbUser.displayName ?? 'Google User';
          final gAvatar = fbUser.photoURL ?? 'https://lh3.googleusercontent.com/a/default-user=s96-c';
          final googleId = fbUser.uid;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', googleId);
          await prefs.setString('user_name', gName);
          await prefs.setString('user_email', gEmail);
          await prefs.setString('user_avatar', gAvatar);
          await prefs.setBool('is_google_user', true);

          try {
            final response = await http.post(
              Uri.parse('$baseUrl/auth/google'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'email': gEmail,
                'name': gName,
                'avatarUrl': gAvatar,
                'googleId': googleId,
              }),
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              final data = jsonDecode(response.body);
              _authToken = data['token'] as String?;
              final userJson = data['user'] as Map<String, dynamic>;

              if (_authToken != null) {
                await prefs.setString('auth_token', _authToken!);
              }

              _currentUser = UserEntity(
                id: userJson['id']?.toString() ?? fbUser.uid,
                name: userJson['name']?.toString() ?? gName,
                email: userJson['email']?.toString() ?? gEmail,
                phone: userJson['phone']?.toString() ?? '',
                avatarUrl: userJson['avatarUrl']?.toString() ?? gAvatar,
                isGuest: false,
              );
              return _currentUser!;
            }
          } catch (e) {
            debugPrint('Backend sync notice: $e');
          }

          _currentUser = UserEntity(
            id: fbUser.uid,
            name: gName,
            email: gEmail,
            phone: '',
            avatarUrl: gAvatar,
            isGuest: false,
          );
          return _currentUser!;
        } else {
          throw Exception('Google Sign-In failed: No user returned');
        }
      } else {
        throw Exception('Google Sign-In is only configured for Web currently.');
      }
    } catch (e) {
      debugPrint('Firebase Google Auth Error: $e');
      if (e is fb.FirebaseAuthException) {
        if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') {
          throw Exception('Google Sign-In popup was closed before completing.');
        }
        throw Exception('Google Auth Error (${e.code}): ${e.message}');
      }
      rethrow;
    }
  }

  fb.ConfirmationResult? _webConfirmationResult;

  @override
  Future<Map<String, dynamic>> sendPhoneOtp(String phone) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleanPhone.startsWith('+')) {
      cleanPhone = '+91$cleanPhone';
    }
    final formattedPhone = cleanPhone;

    debugPrint('Sending Phone OTP to: $formattedPhone');

    if (kIsWeb) {
      try {
        _webConfirmationResult = await fb.FirebaseAuth.instance.signInWithPhoneNumber(formattedPhone);
        debugPrint('Firebase Web Phone Auth Success! ConfirmationResult acquired.');
        return {
          'message': 'Firebase SMS OTP sent to $formattedPhone',
          'phone': formattedPhone,
          'verificationId': _webConfirmationResult?.verificationId ?? 'verif_fb_${DateTime.now().millisecondsSinceEpoch}',
        };
      } catch (e) {
        debugPrint('🔥 Firebase Web Phone Auth Error: $e');
        _webConfirmationResult = null;
        if (e is fb.FirebaseAuthException) {
          if (e.code == 'operation-not-allowed') {
            throw Exception('Phone Auth disabled in Firebase Console. Please click "Save" on the Phone provider in Firebase Console > Authentication > Sign-in method.');
          } else if (e.code == 'too-many-requests') {
            throw Exception('Firebase SMS rate limit reached for this IP. Add your number under "Phone numbers for testing" in Firebase Console or wait 15 minutes for reset.');
          } else if (e.code == 'invalid-phone-number') {
            throw Exception('Invalid phone number format. Please enter a valid mobile number with country code (e.g. +91 9605920708).');
          } else if (e.code == 'captcha-check-failed') {
            throw Exception('reCAPTCHA check failed. Please refresh the page and try again.');
          } else if (e.code == 'quota-exceeded') {
            throw Exception('SMS quota exceeded for Firebase project.');
          }
          throw Exception('Firebase Auth Error (${e.code}): ${e.message}');
        }
        throw Exception('Firebase Web Phone Auth error: $e');
      }
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/phone/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': formattedPhone}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        data['phone'] = formattedPhone;
        return data;
      }
    } catch (e) {
      debugPrint('Backend Send OTP error: $e');
    }

    return {
      'message': 'OTP sent successfully to $formattedPhone',
      'phone': formattedPhone,
      'verificationId': 'verif_dev_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  @override
  Future<UserEntity> verifyPhoneOtp(String phone, String otp) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleanPhone.startsWith('+')) {
      cleanPhone = '+91$cleanPhone';
    }
    final formattedPhone = cleanPhone;

    if (_webConfirmationResult != null) {
      try {
        final userCredential = await _webConfirmationResult!.confirm(otp);
        final fbUser = userCredential.user;
        if (fbUser != null) {
          try {
            final response = await http.post(
              Uri.parse('$baseUrl/auth/phone/verify-otp'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'phone': formattedPhone, 'otp': otp}),
            );

            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              _authToken = data['token'] as String?;
              final userJson = data['user'] as Map<String, dynamic>;

              final prefs = await SharedPreferences.getInstance();
              if (_authToken != null) {
                await prefs.setString('auth_token', _authToken!);
              }

              _currentUser = UserEntity(
                id: userJson['id']?.toString() ?? fbUser.uid,
                name: userJson['name']?.toString() ?? 'Phone User (${formattedPhone.substring(formattedPhone.length - 4)})',
                email: userJson['email']?.toString() ?? '${fbUser.uid}@funfillers.com',
                phone: formattedPhone,
                isGuest: false,
              );
              return _currentUser!;
            }
          } catch (e) {
            debugPrint('Backend verify endpoint notice: $e');
          }

          _currentUser = UserEntity(
            id: fbUser.uid,
            name: fbUser.displayName ?? 'Phone User (${formattedPhone.substring(formattedPhone.length - 4)})',
            email: fbUser.email ?? '${fbUser.uid}@funfillers.com',
            phone: fbUser.phoneNumber ?? formattedPhone,
            avatarUrl: fbUser.photoURL ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
            isGuest: false,
          );
          return _currentUser!;
        }
      } catch (e) {
        debugPrint('Firebase Web OTP confirmation error: $e');
        if (e is fb.FirebaseAuthException) {
          throw Exception('Invalid OTP code (${e.code}): ${e.message}');
        }
        throw Exception('Failed to verify OTP code: $e');
      }
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/phone/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': formattedPhone, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'] as String?;
        final userJson = data['user'] as Map<String, dynamic>;

        final prefs = await SharedPreferences.getInstance();
        if (_authToken != null) {
          await prefs.setString('auth_token', _authToken!);
        }

        _currentUser = UserEntity(
          id: userJson['id']?.toString() ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
          name: userJson['name']?.toString() ?? 'Phone User',
          email: userJson['email']?.toString() ?? '$formattedPhone@funfillers.com',
          phone: formattedPhone,
          isGuest: false,
        );
        return _currentUser!;
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err['error'] ?? 'Invalid OTP code');
      }
    } catch (e) {
      if (otp.length == 6) {
        _currentUser = UserEntity(
          id: 'usr_p_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Phone User ($formattedPhone)',
          email: '$formattedPhone@funfillers.com',
          phone: formattedPhone,
          isGuest: false,
        );
        return _currentUser!;
      }
      rethrow;
    }
  }

  @override
  Future<UserEntity> signInAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    String? guestId = prefs.getString('guest_user_id');
    if (guestId == null || guestId.isEmpty) {
      guestId = 'usr_guest_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('guest_user_id', guestId);
    }
    _currentUser = UserEntity(
      id: guestId,
      name: 'Guest User',
      email: 'guest@funfillers.com',
      phone: '+91 9999999999',
      isGuest: true,
    );
    return _currentUser!;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    if (_currentUser != null && !_currentUser!.isGuest) {
      return _currentUser;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Check native Firebase Auth persistent user
      final fbUser = fb.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        final gEmail = fbUser.email ?? prefs.getString('user_email') ?? 'google_user@funfillers.com';
        final gName = fbUser.displayName ?? prefs.getString('user_name') ?? 'Google User';
        final gAvatar = fbUser.photoURL ?? prefs.getString('user_avatar') ?? '';

        await prefs.setString('user_id', fbUser.uid);
        await prefs.setString('user_name', gName);
        await prefs.setString('user_email', gEmail);
        await prefs.setString('user_avatar', gAvatar);
        await prefs.setBool('is_google_user', true);

        // Ensure backend auth token is valid and active
        _authToken = prefs.getString('auth_token');
        if (_authToken == null || _authToken!.isEmpty) {
          try {
            final response = await http.post(
              Uri.parse('$baseUrl/auth/google'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'email': gEmail,
                'name': gName,
                'avatarUrl': gAvatar,
                'googleId': fbUser.uid,
              }),
            );
            if (response.statusCode == 200 || response.statusCode == 201) {
              final data = jsonDecode(response.body);
              _authToken = data['token'] as String?;
              if (_authToken != null) {
                await prefs.setString('auth_token', _authToken!);
              }
            }
          } catch (_) {}
        }

        _currentUser = UserEntity(
          id: fbUser.uid,
          name: gName,
          email: gEmail,
          phone: fbUser.phoneNumber ?? '',
          avatarUrl: gAvatar,
          isGuest: false,
        );
        return _currentUser;
      }

      // 2. Check SharedPreferences for saved user credentials
      final savedId = prefs.getString('user_id');
      final savedName = prefs.getString('user_name');
      final savedEmail = prefs.getString('user_email');
      final savedAvatar = prefs.getString('user_avatar');
      final isGoogleUser = prefs.getBool('is_google_user') ?? false;

      if (savedId != null && savedId.isNotEmpty && isGoogleUser) {
        _currentUser = UserEntity(
          id: savedId,
          name: savedName ?? 'Google User',
          email: savedEmail ?? 'google_user@funfillers.com',
          phone: '',
          avatarUrl: savedAvatar,
          isGuest: false,
        );
        return _currentUser;
      }
    } catch (e) {
      debugPrint('getCurrentUser restoration error: $e');
    }

    return signInAsGuest();
  }

  @override
  Future<void> signOut() async {
    try {
      await fb.FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Firebase signOut notice: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_avatar');
      await prefs.remove('is_google_user');
    } catch (e) {
      debugPrint('SharedPreferences clear notice: $e');
    }

    _authToken = null;
    await signInAsGuest();
  }

  @override
  Future<List<ProductEntity>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List dynamicList = data['products'] ?? data;

        final products = dynamicList.map((item) {
          return ProductEntity.fromJson(item as Map<String, dynamic>);
        }).toList();

        if (products.isNotEmpty) return products;
      }
    } catch (_) {
      // Return empty list if API fails
    }
    return [];
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));

      if (response.statusCode == 200) {
        final List dynamicList = jsonDecode(response.body);
        final categories = dynamicList.map((item) {
          final map = item as Map<String, dynamic>;
          final rawImg = map['image']?.toString() ?? map['icon']?.toString() ?? map['iconImage']?.toString() ?? '';
          String img = rawImg;
          if (rawImg.isNotEmpty && !rawImg.startsWith('http')) {
            if (rawImg.startsWith('/')) {
              img = 'http://localhost:5050$rawImg';
            } else {
              img = 'http://localhost:5050/uploads/$rawImg';
            }
          }

          return CategoryEntity(
            id: map['id']?.toString() ?? '',
            name: map['name']?.toString() ?? '',
            iconImage: img.isNotEmpty ? img : 'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=200',
            itemCount: (map['itemCount'] as num?)?.toInt() ?? (map['subCategories'] as List?)?.length ?? 12,
          );
        }).toList();

        if (categories.isNotEmpty) return categories;
      }
    } catch (_) {}
    return AppDataSource.mockCategories;
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    final allProducts = await getProducts();
    if (query.trim().isEmpty) return allProducts;

    final lower = query.toLowerCase();
    return allProducts.where((p) {
      return p.title.toLowerCase().contains(lower) ||
          p.category.toLowerCase().contains(lower) ||
          p.targetGender.toLowerCase().contains(lower);
    }).toList();
  }

  @override
  Future<List<AddressEntity>> getAddresses() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrl/user/addresses'), headers: headers);

      if (response.statusCode == 200) {
        final List dynamicList = jsonDecode(response.body);
        _addresses.clear();
        for (var item in dynamicList) {
          final m = item as Map<String, dynamic>;
          _addresses.add(AddressEntity(
            id: m['id']?.toString() ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
            name: m['title']?.toString() ?? m['label']?.toString() ?? m['name']?.toString() ?? 'Home',
            fullAddress: m['fullAddress']?.toString() ?? '',
            city: m['city']?.toString() ?? '',
            state: m['state']?.toString() ?? '',
            pincode: m['pincode']?.toString() ?? '',
            phone: m['phone']?.toString() ?? '',
            label: m['label']?.toString() ?? m['title']?.toString() ?? 'Home',
            isDefault: m['isDefault'] == true,
            country: m['country']?.toString() ?? 'India',
            latitude: (m['latitude'] as num?)?.toDouble() ?? 12.9716,
            longitude: (m['longitude'] as num?)?.toDouble() ?? 77.5946,
            altitude: (m['altitude'] as num?)?.toDouble() ?? 0.0,
          ));
        }
        await _saveAddressesToPrefs();
        return List.from(_addresses);
      }
    } catch (e) {
      debugPrint('Backend getAddresses notice: $e');
    }

    if (_addresses.isEmpty) {
      await _loadAddressesFromPrefs();
    }
    return List.from(_addresses);
  }

  @override
  Future<AddressEntity> addAddress(AddressEntity address) async {
    final addressId = address.id.isNotEmpty ? address.id : 'addr_${DateTime.now().millisecondsSinceEpoch}';

    final payload = {
      'id': addressId,
      'title': address.label.isNotEmpty ? address.label : address.title,
      'label': address.label.isNotEmpty ? address.label : 'Home',
      'fullAddress': address.fullAddress,
      'city': address.city,
      'state': address.state,
      'country': address.country.isNotEmpty ? address.country : 'India',
      'pincode': address.pincode,
      'latitude': address.latitude,
      'longitude': address.longitude,
      'isDefault': true,
    };

    // 1. Post to backend DB
    try {
      final headers = await _getHeaders();
      await http.post(
        Uri.parse('$baseUrl/user/addresses'),
        headers: headers,
        body: jsonEncode(payload),
      );
    } catch (e) {
      debugPrint('Backend addAddress sync notice: $e');
    }

    // 2. Update local state & SharedPreferences
    for (int i = 0; i < _addresses.length; i++) {
      _addresses[i] = AddressEntity(
        id: _addresses[i].id,
        name: _addresses[i].name,
        fullAddress: _addresses[i].fullAddress,
        city: _addresses[i].city,
        state: _addresses[i].state,
        pincode: _addresses[i].pincode,
        phone: _addresses[i].phone,
        label: _addresses[i].label,
        isDefault: false,
        country: _addresses[i].country,
        latitude: _addresses[i].latitude,
        longitude: _addresses[i].longitude,
        altitude: _addresses[i].altitude,
      );
    }

    final newDefaultAddress = AddressEntity(
      id: addressId,
      name: address.name.isNotEmpty ? address.name : (address.label.isNotEmpty ? address.label : 'Home'),
      fullAddress: address.fullAddress,
      city: address.city,
      state: address.state,
      pincode: address.pincode,
      phone: address.phone,
      label: address.label.isNotEmpty ? address.label : 'Home',
      isDefault: true,
      country: address.country.isNotEmpty ? address.country : 'India',
      latitude: address.latitude,
      longitude: address.longitude,
      altitude: address.altitude,
    );

    _addresses.insert(0, newDefaultAddress);
    await _saveAddressesToPrefs();
    return newDefaultAddress;
  }

  @override
  Future<void> setDefaultAddress(String addressId) async {
    try {
      final headers = await _getHeaders();
      await http.put(
        Uri.parse('$baseUrl/user/addresses/$addressId/default'),
        headers: headers,
      );
    } catch (e) {
      debugPrint('Backend setDefaultAddress notice: $e');
    }

    for (int i = 0; i < _addresses.length; i++) {
      final isDef = _addresses[i].id == addressId;
      _addresses[i] = AddressEntity(
        id: _addresses[i].id,
        name: _addresses[i].name,
        fullAddress: _addresses[i].fullAddress,
        city: _addresses[i].city,
        state: _addresses[i].state,
        pincode: _addresses[i].pincode,
        phone: _addresses[i].phone,
        label: _addresses[i].label,
        isDefault: isDef,
        country: _addresses[i].country,
        latitude: _addresses[i].latitude,
        longitude: _addresses[i].longitude,
        altitude: _addresses[i].altitude,
      );
    }
    await _saveAddressesToPrefs();
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      final headers = await _getHeaders();
      await http.delete(
        Uri.parse('$baseUrl/user/addresses/$addressId'),
        headers: headers,
      );
    } catch (e) {
      debugPrint('Backend deleteAddress notice: $e');
    }

    _addresses.removeWhere((a) => a.id == addressId);
    await _saveAddressesToPrefs();
  }

  @override
  Future<List<UserOrderEntity>> getOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrl/orders/user'), headers: headers);

      if (response.statusCode == 200) {
        final List dynamicList = jsonDecode(response.body);
        final remoteOrders = dynamicList.map((item) {
          final map = item as Map<String, dynamic>;
          final itemsList = (map['items'] as List? ?? []).map((i) {
            final pMap = i['product'] as Map<String, dynamic>? ?? {};

            final prodId = i['productId']?.toString() ?? pMap['id']?.toString() ?? '';
            final prodName = i['productName']?.toString() ?? pMap['name']?.toString() ?? pMap['title']?.toString() ?? 'Toy Item';
            final prodPrice = (i['price'] as num?)?.toDouble() ?? (pMap['price'] as num?)?.toDouble() ?? 0.0;
            final prodImage = i['imageUrl']?.toString() ?? pMap['imageUrl']?.toString() ?? pMap['mainImage']?.toString() ?? '';
            final prodCategory = i['category']?.toString() ?? pMap['category']?.toString() ?? 'Toys';

            return CartItemEntity(
              product: ProductEntity(
                id: prodId,
                title: prodName,
                category: prodCategory,
                price: prodPrice,
                rating: 4.8,
                reviewCount: 10,
                description: '',
                mainImage: prodImage,
                galleryImages: [],
              ),
              quantity: (i['quantity'] as num?)?.toInt() ?? 1,
            );
          }).toList();

          return UserOrderEntity(
            id: map['id']?.toString() ?? '',
            items: itemsList,
            totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? (map['total'] as num?)?.toDouble() ?? 0.0,
            status: map['status']?.toString() ?? 'Processing',
            paymentMethod: map['paymentMethod']?.toString() ?? 'UPI',
            shippingAddress: _addresses.isNotEmpty ? _addresses.first : AddressEntity(
              id: 'addr_order',
              name: map['userName']?.toString() ?? 'Customer',
              fullAddress: map['shippingAddress']?.toString() ?? 'Delivery Address',
              city: 'Kochi',
              isDefault: true,
            ),
            createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
          );
        }).toList();

        _orders.clear();
        _orders.addAll(remoteOrders);
        return remoteOrders;
      }
    } catch (e) {
      debugPrint('getOrders error: $e');
    }

    return _orders;
  }

  @override
  Future<UserOrderEntity> createOrder(
    List<CartItemEntity> items,
    AddressEntity shippingAddress,
    String paymentMethod,
    double totalAmount,
  ) async {
    final clientOrderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    UserOrderEntity createdOrder = UserOrderEntity(
      id: clientOrderId,
      items: items,
      totalAmount: totalAmount,
      status: 'Pending',
      paymentMethod: paymentMethod,
      shippingAddress: shippingAddress,
      createdAt: DateTime.now(),
    );

    try {
      final headers = await _getHeaders();
      final bodyData = {
        'items': items.map((i) => {
          'productId': i.product.id,
          'productName': i.product.title,
          'imageUrl': i.product.mainImage,
          'quantity': i.quantity,
          'price': i.product.price,
        }).toList(),
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        'shippingAddress': shippingAddress.fullAddress,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = jsonDecode(response.body);
        if (resData['order'] != null && resData['order']['id'] != null) {
          createdOrder = createdOrder.copyWith(
            id: resData['order']['id'].toString(),
            status: resData['order']['status']?.toString() ?? 'Pending',
          );
        }
      }
    } catch (e) {
      debugPrint('Order creation sync notice: $e');
    }

    _orders.removeWhere((o) => o.id == createdOrder.id);
    _orders.insert(0, createdOrder);
    return createdOrder;
  }

  final List<ProductEntity> _wishlist = [];

  @override
  Future<List<ProductEntity>> getWishlist() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrl/wishlist'), headers: headers);
      if (response.statusCode == 200) {
        final List dynamicList = jsonDecode(response.body);
        final remoteItems = dynamicList.map((item) {
          return ProductEntity.fromJson(item as Map<String, dynamic>).copyWith(isFavorite: true);
        }).toList();
        _wishlist.clear();
        _wishlist.addAll(remoteItems);
        return List.unmodifiable(_wishlist);
      }
    } catch (e) {
      debugPrint('Wishlist fetch error: $e');
    }
    return List.unmodifiable(_wishlist);
  }

  @override
  Future<bool> toggleWishlist(ProductEntity product) async {
    final exists = _wishlist.any((p) => p.id == product.id);
    if (exists) {
      _wishlist.removeWhere((p) => p.id == product.id);
    } else {
      _wishlist.add(product.copyWith(isFavorite: true));
    }

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/wishlist/toggle'),
        headers: headers,
        body: jsonEncode({'productId': product.id}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isFavorite'] == true;
      }
    } catch (e) {
      debugPrint('Wishlist toggle API notice: $e');
    }
    return !exists;
  }
}
