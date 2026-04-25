import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/services/language_service.dart';
import 'package:Saborly/features/providers/home_provider.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController? controller;
  final Function(String)? onSearch;
  final String? hintText;
  final bool enabled;
  final VoidCallback? onSearchStarted;

  const SearchBarWidget({
    super.key,
    this.controller,
    this.onSearch,
    this.hintText,
    this.enabled = true,
    this.onSearchStarted,
  });

  @override
  State<SearchBarWidget> createState() => SearchBarWidgetState();
}

class SearchBarWidgetState extends State<SearchBarWidget> with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {});
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;

        final containerHeight = _calculateHeight(isSmallScreen, isTablet);
        final horizontalPadding = _calculateHorizontalPadding(isSmallScreen, isTablet);
        final fontSize = _calculateFontSize(isSmallScreen, isTablet);
        final iconSize = _calculateIconSize(isSmallScreen, isTablet);
        final borderRadius = _calculateBorderRadius(isSmallScreen, isTablet);

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: containerHeight,
                decoration: BoxDecoration(
                  gradient: AppColors.surfaceGradient,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? AppColors.primary
                        : AppColors.border,
                    width: _focusNode.hasFocus ? 2.0 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _focusNode.hasFocus
                          ? AppColors.primary.withOpacity(0.15 * _glowAnimation.value)
                          : AppColors.shadow.withOpacity(0.35),
                      blurRadius: _focusNode.hasFocus ? 20.r : 14.r,
                      offset: Offset(0, _focusNode.hasFocus ? 8.h : 5.h),
                      spreadRadius: _focusNode.hasFocus ? 1 : 0,
                    ),
                  ],
                ),
                child: Row(
                  textDirection: context.watch<LanguageService>().textDirection,
                  children: [
                    SizedBox(width: horizontalPadding),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: _focusNode.hasFocus
                            ? AppColors.primary.withOpacity(0.14)
                            : AppColors.accentCream,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        size: iconSize,
                        color: _focusNode.hasFocus
                            ? AppColors.primary
                            : Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: widget.enabled,
                        onChanged: _handleSearchChange,
                        onSubmitted: _handleSearchSubmit,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          letterSpacing: 0.2,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: widget.hintText ?? AppStrings.get('search'),
                          hintStyle: TextStyle(
                            fontSize: fontSize,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                        ),
                        textDirection: context.watch<LanguageService>().textDirection,
                      ),
                    ),
                    if (_controller.text.isNotEmpty)
                      AnimatedScale(
                        scale: 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20.r),
                            onTap: _handleClear,
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: AppColors.accentCream,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: iconSize - 4,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(width: horizontalPadding),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _calculateHeight(bool isSmallScreen, bool isTablet) {
    if (isSmallScreen) return 50.h.clamp(48.0, 54.0);
    if (isTablet) return 56.h.clamp(52.0, 60.0);
    return 62.h.clamp(58.0, 66.0);
  }

  double _calculateHorizontalPadding(bool isSmallScreen, bool isTablet) {
    if (isSmallScreen) return 12.w.clamp(10.0, 14.0);
    if (isTablet) return 16.w.clamp(14.0, 18.0);
    return 20.w.clamp(18.0, 22.0);
  }

  double _calculateFontSize(bool isSmallScreen, bool isTablet) {
    if (isSmallScreen) return 15.sp.clamp(14.0, 16.0);
    if (isTablet) return 16.sp.clamp(15.0, 17.0);
    return 17.sp.clamp(16.0, 18.0);
  }

  double _calculateIconSize(bool isSmallScreen, bool isTablet) {
    if (isSmallScreen) return 20.sp.clamp(18.0, 22.0);
    if (isTablet) return 22.sp.clamp(20.0, 24.0);
    return 24.sp.clamp(22.0, 26.0);
  }

  double _calculateBorderRadius(bool isSmallScreen, bool isTablet) {
    if (isSmallScreen) return 14.r.clamp(12.0, 16.0);
    if (isTablet) return 16.r.clamp(14.0, 18.0);
    return 18.r.clamp(16.0, 20.0);
  }

  void _handleSearchChange(String value) {
    setState(() {});
    if (widget.onSearch != null) {
      widget.onSearch!(value);
    }
    if (value.isEmpty) {
      context.read<HomeProvider>().loadHomeData();
    } else {
      widget.onSearchStarted?.call();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_controller.text == value && mounted) {
          context.read<HomeProvider>().performSearch(value);
          Future.delayed(const Duration(milliseconds: 500), () {
            widget.onSearchStarted?.call();
          });
        }
      });
    }
  }

  void _handleSearchSubmit(String value) {
    if (widget.onSearch != null) {
      widget.onSearch!(value);
    }
    if (value.isNotEmpty) {
      context.read<HomeProvider>().performSearch(value);
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onSearchStarted?.call();
      });
    }
    _focusNode.unfocus();
  }

  void _handleClear() {
    _controller.clear();
    if (widget.onSearch != null) {
      widget.onSearch!('');
    } else {
      context.read<HomeProvider>().loadHomeData();
    }
    setState(() {});
    _focusNode.unfocus();
  }
}

class SearchFeedbackBanner extends StatelessWidget {
  final String query;
  final int resultCount;
  final bool isLoading;
  final VoidCallback onClear;

  const SearchFeedbackBanner({
    super.key,
    required this.query,
    required this.resultCount,
    required this.isLoading,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondaryLight.withOpacity(0.45),
                  AppColors.primaryLight.withOpacity(0.25),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 16.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Row(
              textDirection: context.watch<LanguageService>().textDirection,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.12),
                        AppColors.secondary.withOpacity(0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppStrings.get('resultsFor'),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMedium,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '"$query"',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLoading)
                              SizedBox(
                                width: 12.sp,
                                height: 12.sp,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 14.sp,
                              ),
                            SizedBox(width: 6.w),
                            Text(
                              isLoading
                                  ? AppStrings.get('searching')
                                  : '$resultCount ${AppStrings.get(resultCount == 1 ? 'item' : 'items')} ${AppStrings.get('found')}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.r),
                    onTap: onClear,
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.textDark,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
