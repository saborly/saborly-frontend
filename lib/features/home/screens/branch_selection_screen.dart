import 'dart:math' as math;

import 'package:dio/dio.dart';
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

// Neutral tokens for the city/region picker.
const Color _ink = Color(0xFF1A1A2E);
const Color _inkMuted = Color(0xFF6B7280);
const Color _inkHint = Color(0xFF9CA3AF);
const Color _fieldBorder = Color(0xFFE4E4E7);

class BranchSelectionScreen extends StatefulWidget {
  /// When true the user came here to switch branch, so don't auto-skip to
  /// home because a branch is already saved.
  final bool allowChange;

  const BranchSelectionScreen({super.key, this.allowChange = false});

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

      final savedBranchId = ApiService().branchId;
      if (widget.allowChange) {
        // Switching branch: pre-select the current one and stay on this screen.
        if (savedBranchId != null &&
            list.any((b) => '${b['_id']}' == savedBranchId && b['isActive'] == true)) {
          setState(() => _selectedCityBranchId = savedBranchId);
        }
        return;
      }

      // If the user already has a saved branch, skip straight to home.
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
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _branchLoadError = ApiErrorClassifier.classify(e).message;
        _loadingBranches = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _branchLoadError = 'Something went wrong. Please try again.';
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

    // Generous outer bound: the browser's own permission prompt on a first
    // ever request blocks detectUserLocation() for as long as the user takes
    // to respond, which can exceed a short timeout here and abort a flow
    // that would otherwise have succeeded (see geolocation_service_web.dart).
    final coords = await detectUserLocation()
        .timeout(const Duration(seconds: 26), onTimeout: () => null);

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
                  constraints: const BoxConstraints(maxWidth: 560),
                  margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                  padding: EdgeInsets.symmetric(horizontal: 44.w, vertical: 40.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: const Color(0xFFF0EFF2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 36,
                        offset: const Offset(0, 14),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _loadingBranches
                      ? Padding(
                          padding: EdgeInsets.all(24.w),
                          child: const Center(child: CircularProgressIndicator()),
                        )
                      : _branchLoadError != null
                          ? _buildLoadError()
                          : _buildForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadError() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 40.sp, color: AppColors.textLight),
          SizedBox(height: 14.h),
          Text(
            _branchLoadError ?? 'Something went wrong. Please try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 46.h,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadingBranches = true;
                  _branchLoadError = null;
                });
                _loadBranches();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 28.w),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo3.png',
          height: 88.h,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 20.h),
        Text(
          'Choose your branch',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            height: 1.25,
            color: _ink,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Pick the Saborly location you want to order from, or let us find the nearest one.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            height: 1.45,
            color: _inkMuted,
          ),
        ),
        SizedBox(height: 22.h),
        _buildLocationButton(),
        if (_detectedLat != null) ...[
          SizedBox(height: 8.h),
          Text(
            _detectedAddress ??
                '${_detectedLat!.toStringAsFixed(5)}, ${_detectedLng!.toStringAsFixed(5)}',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12.sp, color: _inkMuted),
          ),
        ],
        if (_locationError != null) ...[
          SizedBox(height: 8.h),
          Text(
            _locationError!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12.sp, color: const Color(0xFFD32F2F)),
          ),
        ],
        SizedBox(height: 20.h),
        _buildDivider('or select a branch'),
        SizedBox(height: 16.h),
        _buildBranchCards(),
        SizedBox(height: 22.h),
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
          height: 54.h,
          child: ElevatedButton(
            onPressed: _canSubmit ? _onSelectPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              elevation: _canSubmit ? 6 : 0,
              shadowColor: AppColors.primary.withOpacity(0.28),
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
                    (_selectedCityBranchId != null || _detectedLat != null)
                        ? 'Continue'
                        : 'Select a branch',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: _canSubmit ? Colors.white : _inkHint,
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
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: detected ? AppColors.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: detected ? AppColors.primary.withOpacity(0.45) : _fieldBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
                size: 18.sp,
                color: AppColors.primary,
              ),
            SizedBox(width: 10.w),
            Text(
              _isDetectingLocation
                  ? 'Fetching Location...'
                  : detected
                      ? 'Location detected'
                      : 'Use my location',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: detected ? AppColors.primary : _ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCitySelected(String id) {
    setState(() {
      _selectedCityBranchId = id;
      // Manual city choice overrides a stale GPS fix.
      _detectedLat = null;
      _detectedLng = null;
      _blockedMessage = null;
    });
  }

  String _branchName(Map<String, dynamic> b) => '${b['name'] ?? 'Branch'}'.trim();

  /// Street address shown under the branch name, or null when the branch
  /// has none (or it just repeats the name).
  String? _branchAddress(Map<String, dynamic> b) {
    final loc = '${b['location'] ?? ''}'.trim();
    if (loc.isEmpty || loc.toLowerCase() == _branchName(b).toLowerCase()) return null;
    return loc;
  }

  Widget _buildDivider(String label) {
    return Row(
      children: [
        const Expanded(child: Divider(height: 1, color: _fieldBorder)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: _inkHint,
            ),
          ),
        ),
        const Expanded(child: Divider(height: 1, color: _fieldBorder)),
      ],
    );
  }

  /// Branches as selectable cards (nothing floats over the Select button).
  Widget _buildBranchCards() {
    final branches = _branches.where((b) => b['isActive'] == true).toList();
    if (branches.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        child: Text(
          'No branches available right now',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: _inkMuted),
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < branches.length; i++) ...[
          if (i > 0) SizedBox(height: 10.h),
          _buildBranchCard(branches[i]),
        ],
      ],
    );
  }

  Widget _buildBranchCard(Map<String, dynamic> b) {
    final id = '${b['_id']}';
    final selected = id == _selectedCityBranchId && _detectedLat == null;
    final address = _branchAddress(b);
    final radius = BorderRadius.circular(14.r);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        borderRadius: radius,
        color: selected ? AppColors.primary.withOpacity(0.06) : Colors.white,
        border: Border.all(
          color: selected ? AppColors.primary : _fieldBorder,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: [
          if (selected)
            BoxShadow(color: AppColors.primary.withOpacity(0.10), spreadRadius: 4)
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: () => _onCitySelected(id),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 64.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  _branchBadge(selected: selected),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _branchName(b),
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: _ink,
                            height: 1.3,
                          ),
                        ),
                        if (address != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              address,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5.sp,
                                color: _inkMuted,
                                height: 1.4,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: selected ? AppColors.primary : const Color(0xFFD1D5DB),
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _branchBadge({required bool selected}) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.primary.withOpacity(0.09),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        Icons.storefront_rounded,
        size: 22.sp,
        color: selected ? Colors.white : AppColors.primary,
      ),
    );
  }
}
