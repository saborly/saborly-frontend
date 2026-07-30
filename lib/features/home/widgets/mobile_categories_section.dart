import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/shared/models/food_category.dart';

/// Mobile-only redesign of the home categories row. Sized purely from its
/// content (SingleChildScrollView + Row, no guessed fixed height like the
/// shared web/mobile slider used before), so there's never leftover empty
/// space under the chips no matter how tall the labels wrap.
class MobileCategoriesSection extends StatelessWidget {
  final List<FoodCategory> categories;
  final ValueChanged<FoodCategory> onTap;

  const MobileCategoriesSection({super.key, required this.categories, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: AppColors.shadow.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (int i = 0; i < categories.length; i++) ...[
              if (i > 0) SizedBox(width: 16.w),
              _MobileCategoryChip(category: categories[i], onTap: () => onTap(categories[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class _MobileCategoryChip extends StatefulWidget {
  final FoodCategory category;
  final VoidCallback onTap;
  const _MobileCategoryChip({required this.category, required this.onTap});

  @override
  State<_MobileCategoryChip> createState() => _MobileCategoryChipState();
}

class _MobileCategoryChipState extends State<_MobileCategoryChip> {
  bool _pressed = false;

  static const _schemes = [
    [Color(0xFFD84E17), Color(0xFFF5A623)],
    [Color(0xFF6A1638), Color(0xFFE76F51)],
    [Color(0xFF2F7A53), Color(0xFF6FBC8E)],
    [Color(0xFF7B2F17), Color(0xFFDB8A36)],
    [Color(0xFFAA5C28), Color(0xFFF2B15E)],
    [Color(0xFFB23A48), Color(0xFFF28482)],
  ];

  List<Color> get _scheme => _schemes[widget.category.name.hashCode.abs() % _schemes.length];

  @override
  Widget build(BuildContext context) {
    const avatarSize = 68.0;
    final scheme = _scheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: 78.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: avatarSize.w,
                height: avatarSize.w,
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: scheme, begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: ClipOval(
                    child: widget.category.imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: widget.category.imageUrl,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 200),
                            placeholder: (_, __) => _iconFallback(scheme),
                            errorWidget: (_, __, ___) => _iconFallback(scheme),
                          )
                        : _iconFallback(scheme),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconFallback(List<Color> scheme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: scheme, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      alignment: Alignment.center,
      child: Text(widget.category.icon, style: TextStyle(fontSize: 24.sp)),
    );
  }
}
