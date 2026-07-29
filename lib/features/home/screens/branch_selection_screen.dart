import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/services/api_service.dart';
import 'package:Saborly/core/services/geolocation_service.dart';

/// Branches must be within this radius (km) of the user for delivery/pickup
/// to be allowed. Matches CheckoutProvider.maxDeliveryDistance.
const double _maxBranchDistanceKm = 3.5;

class BranchSelectionScreen extends StatefulWidget {
  const BranchSelectionScreen({super.key});

  @override
  State<BranchSelectionScreen> createState() => _BranchSelectionScreenState();
}

class _BranchSelectionScreenState extends State<BranchSelectionScreen> {
  List<Map<String, dynamic>> _branches = [];
  bool _loadingBranches = true;
  String? _branchLoadError;

  // Location step state
  bool _isDetectingLocation = false;
  double? _detectedLat;
  double? _detectedLng;
  String? _detectedAddress;
  String? _locationError;

  // Manual city/region fallback
  String? _selectedCityBranchId;

  bool _isSubmitting = false;
  String? _blockedMessage;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      final res = await ApiService().dio.get('/branches/public');
      final raw = res.data['branches'] as List<dynamic>? ?? [];
      final list = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      // Deduplicate by name (case-insensitive) keeping the first occurrence
      final seen = <String>{};
      list.retainWhere((b) => seen.add('${b['name']}'.toLowerCase().trim()));
      list.sort((a, b) => '${a['name']}'.compareTo('${b['name']}'));
      if (!mounted) return;

      setState(() {
        _branches = list;
        _loadingBranches = false;
      });

      // If the user already has a saved branch, skip straight to home.
      final savedBranchId = ApiService().branchId;
      if (savedBranchId != null && savedBranchId.isNotEmpty) {
        final savedBranch = list.firstWhere(
          (b) => '${b['_id']}' == savedBranchId && b['isActive'] == true,
          orElse: () => {},
        );
        if (savedBranch.isNotEmpty && mounted) {
          context.go('/home');
          return;
        }
      }

      if (list.length == 1 && list.first['isActive'] == true) {
        await _finalizeSelection('${list.first['_id']}', lat: null, lng: null);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _branchLoadError = e.toString();
        _loadingBranches = false;
      });
    }
  }

  Future<void> _useMyLocation() async {
    setState(() {
      _isDetectingLocation = true;
      _locationError = null;
      _blockedMessage = null;
    });

    final coords = await detectUserLocation()
        .timeout(const Duration(seconds: 10), onTimeout: () => null);

    if (!mounted) return;

    if (coords == null) {
      setState(() {
        _isDetectingLocation = false;
        _locationError =
            'Couldn\'t detect your location. Please allow location access or pick your city below.';
      });
      return;
    }

    setState(() {
      _detectedLat = coords['lat'];
      _detectedLng = coords['lng'];
      _detectedAddress = null;
      _isDetectingLocation = false;
      _selectedCityBranchId = null; // GPS takes priority once detected
    });

    // Fetch a human-readable address in the background; the location
    // button already shows "Location detected" while this resolves.
    final address = await ApiService().reverseGeocode(coords['lat']!, coords['lng']!);
    if (mounted && _detectedLat == coords['lat'] && _detectedLng == coords['lng']) {
      setState(() => _detectedAddress = address);
    }
  }

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _rad(double deg) => deg * math.pi / 180;

  ({String id, double distanceKm})? _nearestBranch(double lat, double lng) {
    if (_branches.isEmpty) return null;
    String bestId = '${_branches.first['_id']}';
    double best = double.infinity;
    for (final b in _branches) {
      final blat = (b['latitude'] as num?)?.toDouble();
      final blng = (b['longitude'] as num?)?.toDouble();
      if (blat == null || blng == null) continue;
      final d = _haversine(lat, lng, blat, blng);
      if (d < best) {
        best = d;
        bestId = '${b['_id']}';
      }
    }
    return (id: bestId, distanceKm: best);
  }

  bool get _canSubmit =>
      !_isSubmitting && (_detectedLat != null || _selectedCityBranchId != null);

  Future<void> _onSelectPressed() async {
    if (!_canSubmit) return;
    setState(() {
      _isSubmitting = true;
      _blockedMessage = null;
    });

    if (_detectedLat != null && _detectedLng != null) {
      final nearest = _nearestBranch(_detectedLat!, _detectedLng!);
      if (nearest == null || nearest.distanceKm > _maxBranchDistanceKm) {
        setState(() {
          _isSubmitting = false;
          _blockedMessage = nearest == null
              ? 'Sorry, we couldn\'t find a nearby branch.'
              : 'Sorry, we don\'t deliver to your area yet. Our nearest branch is ${nearest.distanceKm.toStringAsFixed(1)} km away.';
        });
        return;
      }
      await _finalizeSelection(
        nearest.id,
        lat: _detectedLat,
        lng: _detectedLng,
        addressText: _detectedAddress,
      );
      return;
    }

    // Manual city/region choice — trust the user's explicit selection.
    final branch = _branches.firstWhere(
      (b) => '${b['_id']}' == _selectedCityBranchId,
      orElse: () => {},
    );
    final lat = (branch['latitude'] as num?)?.toDouble();
    final lng = (branch['longitude'] as num?)?.toDouble();
    await _finalizeSelection(
      _selectedCityBranchId!,
      lat: lat,
      lng: lng,
      addressText: _cityLabel(branch),
    );
  }

  Future<void> _finalizeSelection(
    String id, {
    double? lat,
    double? lng,
    String? addressText,
  }) async {
    // If switching to a different branch, clear the cart to avoid
    // stale items from the previous branch blocking order placement.
    final currentBranchId = ApiService().branchId;
    if (currentBranchId != null &&
        currentBranchId.isNotEmpty &&
        currentBranchId != id) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cart_items');
    }
    await ApiService().setBranchId(id);
    if (lat != null && lng != null) {
      await ApiService().setSelectedLocation(lat, lng, addressText: addressText);
    }
    if (mounted) context.go('/home');
  }

  String _cityLabel(Map<String, dynamic> b) {
    final loc = '${b['location'] ?? ''}';
    if (loc.isNotEmpty) return loc;
    return '${b['name'] ?? 'Branch'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF0F6),
                    Colors.white,
                    Color(0xFFF8F9FA),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 36.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _loadingBranches
                      ? Padding(
                          padding: EdgeInsets.all(24.w),
                          child: const Center(child: CircularProgressIndicator()),
                        )
                      : _branchLoadError != null
                          ? Text(
                              'Could not load branches. Check connection and try again.\n$_branchLoadError',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: Colors.redAccent,
                              ),
                            )
                          : _buildForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Image.asset(
            'assets/images/logo3.png',
            height: 84.h,
            width: 84.h,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 22.h),
        Text(
          'Select your order type',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Text(
            'Instant',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 26.h),
        Text(
          'Please select your location',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        SizedBox(height: 12.h),
        _buildLocationButton(),
        if (_detectedLat != null) ...[
          SizedBox(height: 8.h),
          Text(
            _detectedAddress ??
                '${_detectedLat!.toStringAsFixed(5)}, ${_detectedLng!.toStringAsFixed(5)}',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textLight),
          ),
        ],
        if (_locationError != null) ...[
          SizedBox(height: 8.h),
          Text(
            _locationError!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.redAccent),
          ),
        ],
        SizedBox(height: 22.h),
        Align(
          alignment: Alignment.centerLeft,
          child: _sectionLabel('Select City / Region'),
        ),
        SizedBox(height: 10.h),
        _buildCityDropdown(),
        SizedBox(height: 26.h),
        if (_blockedMessage != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              _blockedMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE65100),
              ),
            ),
          ),
        ],
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: _canSubmit ? _onSelectPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: const Color(0xFFD8D8D8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: _isSubmitting
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    'Select',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationButton() {
    final detected = _detectedLat != null;
    return InkWell(
      onTap: _isDetectingLocation ? null : _useMyLocation,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F2),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isDetectingLocation)
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                detected ? Icons.check_circle_rounded : Icons.my_location_rounded,
                size: 17.sp,
                color: detected ? AppColors.primary : AppColors.textDark,
              ),
            SizedBox(width: 8.w),
            Text(
              _isDetectingLocation
                  ? 'Fetching Location...'
                  : detected
                      ? 'Location detected'
                      : 'Use my location',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: detected ? AppColors.primary : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      width: double.infinity,
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCityBranchId,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textLight),
          hint: Text(
            'Select City / Region',
            style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.textLight),
          ),
          items: _branches
              .where((b) => b['isActive'] == true)
              .map(
                (b) => DropdownMenuItem<String>(
                  value: '${b['_id']}',
                  child: Text(
                    _cityLabel(b),
                    style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCityBranchId = value;
              // Manual city choice overrides a stale GPS fix.
              _detectedLat = null;
              _detectedLng = null;
              _blockedMessage = null;
            });
          },
        ),
      ),
    );
  }
}
