import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/services/api_service.dart';
import 'package:Saborly/core/services/geolocation_service.dart';

const _barcelonaLat = 41.3851;
const _barcelonaLng = 2.1734;
const _sabadellLat = 41.5570164;
const _sabadellLng = 2.0969248;

class BranchSelectionScreen extends StatefulWidget {
  const BranchSelectionScreen({super.key});

  @override
  State<BranchSelectionScreen> createState() => _BranchSelectionScreenState();
}

class _BranchSelectionScreenState extends State<BranchSelectionScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _branches = [];
  bool _loadingBranches = true;
  String? _branchLoadError;
  int? _nearestBranchIndex;
  bool _isDetectingLocation = true;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.028).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadBranches();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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

      // Show branch cards IMMEDIATELY — don't wait for geolocation
      setState(() {
        _branches = list;
        _loadingBranches = false;
      });

      // On mobile: if user already has a saved branch, auto-navigate home now
      if (!kIsWeb) {
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
        // Mobile: mark location detection done (no geo on mobile)
        setState(() => _isDetectingLocation = false);
      } else {
        // Web: detect location in the background — cards are already visible
        _detectLocation(); // intentionally unawaited
      }

      if (list.length == 1 && list.first['isActive'] == true) {
        await _selectBranch('${list.first['_id']}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _branchLoadError = e.toString();
        _loadingBranches = false;
      });
    }
  }

  Future<void> _detectLocation() async {
    // Web-only. Mobile is handled separately.
    try {
      // Timeout after 4 s so a slow browser GPS never keeps the spinner forever
      final coords = await detectUserLocation()
          .timeout(const Duration(seconds: 4), onTimeout: () => null);
      if (!mounted) return;
      if (coords != null && _branches.length >= 2) {
        final distBarcelona = _haversine(
          coords['lat']!, coords['lng']!,
          _barcelonaLat, _barcelonaLng,
        );
        final distSabadell = _haversine(
          coords['lat']!, coords['lng']!,
          _sabadellLat, _sabadellLng,
        );
        int nearest = 0;
        double best = 1e12;
        for (var i = 0; i < _branches.length; i++) {
          final b = _branches[i];
          final lat = (b['latitude'] as num?)?.toDouble();
          final lng = (b['longitude'] as num?)?.toDouble();
          final double d;
          if (lat != null && lng != null) {
            d = _haversine(coords['lat']!, coords['lng']!, lat, lng);
          } else {
            final n = '${b['name']}'.toLowerCase();
            d = n.contains('sabadell') ? distSabadell : distBarcelona;
          }
          if (d < best) {
            best = d;
            nearest = i;
          }
        }
        if (mounted) {
          setState(() {
            _nearestBranchIndex = nearest;
            _isDetectingLocation = false;
          });
        }
      } else {
        if (mounted) setState(() => _isDetectingLocation = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isDetectingLocation = false);
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

  Future<void> _selectBranch(String id) async {
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
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

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
          Positioned(
            top: -100,
            right: -100,
            child: _GradientBlob(
              size: isWide ? 360 : 240,
              color: AppColors.primary.withOpacity(0.07),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: _GradientBlob(
              size: isWide ? 280 : 200,
              color: AppColors.primary.withOpacity(0.05),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 80.w : 24.w,
                    vertical: 40.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo3.png',
                        height: 56.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 44.h),
                      Text(
                        'Choose Your Branch',
                        style: GoogleFonts.poppins(
                          fontSize: isWide ? 38.sp : 26.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: _isDetectingLocation
                            ? Row(
                                key: const ValueKey('detecting'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 14.w,
                                    height: 14.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                          AppColors.primary),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Detecting your location…',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                key: const ValueKey('hint'),
                                _nearestBranchIndex != null
                                    ? '📍 We\'ve highlighted your nearest branch'
                                    : 'Select the branch you\'d like to order from',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: AppColors.textLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
                      SizedBox(height: 52.h),
                      if (_loadingBranches)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        )
                      else if (_branchLoadError != null)
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Text(
                            'Could not load branches. Check connection and try again.\n$_branchLoadError',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: Colors.redAccent,
                            ),
                          ),
                        )
                      else if (_branches.isEmpty)
                        Text(
                          'No branches available.',
                          style: GoogleFonts.poppins(fontSize: 14.sp),
                        )
                      else
                        isWide
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var i = 0; i < _branches.length; i++) ...[
                                    if (i > 0) SizedBox(width: 28.w),
                                    Expanded(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                            maxWidth: 420),
                                        child: _branchCard(i, _branches[i]),
                                      ),
                                    ),
                                  ],
                                ],
                              )
                            : Column(
                                children: _branches
                                    .asMap()
                                    .entries
                                    .map((e) => Padding(
                                          padding: EdgeInsets.only(
                                              bottom:
                                                  e.key < _branches.length - 1
                                                      ? 20.h
                                                      : 0),
                                          child: _branchCard(e.key, e.value),
                                        ))
                                    .toList(),
                              ),
                      SizedBox(height: 52.h),
                      Text(
                        '© ${DateTime.now().year} Saborly · Delivering happiness to your door',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: AppColors.textHint,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _branchCard(int index, Map<String, dynamic> b) {
    final id = '${b['_id']}';
    final name = '${b['name'] ?? 'Branch'}';
    final loc = '${b['location'] ?? b['address'] ?? ''}';
    final active = b['isActive'] == true;
    final isNearest = _nearestBranchIndex == index;

    // Robust phone fallback
    String? phone = b['phone']?.toString();
    final lowerName = name.toLowerCase();
    if (phone == null || phone.isEmpty || phone == 'null') {
      if (lowerName.contains('sabadell')) {
        phone = '669 37 85 28 / 935 35 92 24';
      } else {
        // Default to Barcelona/Main
        phone = '932 11 20 72 / 619 80 70 84';
      }
    }

    return _BranchCard(
      name: name,
      subtitle: loc.isNotEmpty ? loc : 'Saborly',
      address: loc.isNotEmpty ? loc : (b['address']?.toString() ?? ''),
      phone: phone,
      iconData: Icons.storefront_rounded,
      isNearest: isNearest,
      isComingSoon: !active,
      onTap: active ? () => _selectBranch(id) : () {},
      pulseAnimation: isNearest && active ? _pulseAnimation : null,
    );
  }
}

class _BranchCard extends StatefulWidget {
  final String name;
  final String subtitle;
  final String address;
  final String? phone;
  final IconData iconData;
  final bool isNearest;
  final bool isComingSoon;
  final VoidCallback onTap;
  final Animation<double>? pulseAnimation;

  const _BranchCard({
    required this.name,
    required this.subtitle,
    required this.address,
    this.phone,
    required this.iconData,
    required this.isNearest,
    required this.isComingSoon,
    required this.onTap,
    this.pulseAnimation,
  });

  @override
  State<_BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<_BranchCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Widget card = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.isComingSoon
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: widget.isNearest
                  ? AppColors.primary
                  : widget.isComingSoon
                      ? const Color(0xFFE0E0E0)
                      : (_hovered
                          ? AppColors.primary.withOpacity(0.5)
                          : const Color(0xFFE8E8E8)),
              width: widget.isNearest ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isNearest
                    ? AppColors.primary.withOpacity(_hovered ? 0.22 : 0.14)
                    : Colors.black.withOpacity(
                        _hovered && !widget.isComingSoon ? 0.10 : 0.06),
                blurRadius: widget.isNearest ? 24 : (_hovered ? 18 : 12),
                spreadRadius: widget.isNearest ? 2 : 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: widget.isComingSoon
                          ? const Color(0xFFF5F5F5)
                          : AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Icon(
                      widget.iconData,
                      size: 30.sp,
                      color: widget.isComingSoon
                          ? const Color(0xFFBDBDBD)
                          : AppColors.primary,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (widget.isNearest && !widget.isComingSoon)
                        _Pill(
                          text: '📍 Nearest to you',
                          bgColor: AppColors.primary.withOpacity(0.10),
                          textColor: AppColors.primary,
                        ),
                      if (widget.isComingSoon) ...[
                        _Pill(
                          text: 'Unavailable',
                          bgColor: const Color(0xFFFFF3E0),
                          textColor: const Color(0xFFE65100),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              SizedBox(height: 22.h),
              Text(
                widget.name,
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: widget.isComingSoon
                      ? const Color(0xFF9E9E9E)
                      : const Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
              SizedBox(height: 10.h),
              if (widget.phone != null && widget.phone!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 14.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        widget.phone!,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 13.sp,
                    color: const Color(0xFFBDBDBD),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      widget.address,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: const Color(0xFFBDBDBD),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              const Divider(color: Color(0xFFF2F2F2), thickness: 1, height: 1),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!widget.isComingSoon)
                    Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Open Now',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFB74D),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Inactive',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                        horizontal: 18.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: widget.isComingSoon
                          ? const Color(0xFFF5F5F5)
                          : (_hovered
                              ? AppColors.primaryDark
                              : AppColors.primary),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: widget.isComingSoon
                          ? []
                          : [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.30),
                                blurRadius: _hovered ? 12 : 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.isComingSoon ? '—' : 'Order now',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: widget.isComingSoon
                                ? const Color(0xFF9E9E9E)
                                : Colors.white,
                          ),
                        ),
                        if (!widget.isComingSoon) ...[
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.pulseAnimation != null) {
      return AnimatedBuilder(
        animation: widget.pulseAnimation!,
        builder: (context, child) => Transform.scale(
          scale: widget.pulseAnimation!.value,
          child: child,
        ),
        child: card,
      );
    }

    return card;
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;

  const _Pill({
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _GradientBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _GradientBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
