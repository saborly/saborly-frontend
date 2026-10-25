import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/constant/app_typography.dart';

/// Section title with an optional kicker label and "view all" action,
/// used above every homepage section so they all share one rhythm.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final bool isWeb;

  final String? kicker;

  const SectionHeader(
    this.title, {
    super.key,
    this.onViewAll,
    this.isWeb = false,
    this.kicker,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kicker != null) ...[
                Text(
                  kicker!.toUpperCase(),
                  style: AppTypography.kicker(AppColors.primary, size: isWeb ? 12.5 : 11.5),
                ),
                SizedBox(height: isWeb ? 6.h : 4.h),
              ],
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.heading(isWeb ? 30 : 22, color: AppColors.textDark, height: 1.15),
              ),
            ],
          ),
        ),
        if (onViewAll != null) ...[
          SizedBox(width: 12.w),
          _ViewAllButton(onTap: onViewAll!, isWeb: isWeb),
        ],
      ],
    );
  }
}

class _ViewAllButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isWeb;

  const _ViewAllButton({required this.onTap, required this.isWeb});

  @override
  State<_ViewAllButton> createState() => _ViewAllButtonState();
}

class _ViewAllButtonState extends State<_ViewAllButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isWeb = widget.isWeb;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 16 : 12,
            vertical: isWeb ? 10 : 7,
          ),
          decoration: BoxDecoration(
            color: _hovering ? AppColors.primary : AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.viewAll,
                style: AppTypography.body(
                  isWeb ? 14 : 13,
                  color: _hovering ? Colors.white : AppColors.primary,
                  weight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                size: AppTypography.size(isWeb ? 16 : 15),
                color: _hovering ? Colors.white : AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
