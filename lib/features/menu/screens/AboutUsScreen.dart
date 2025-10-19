import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/services/language_service.dart';
import 'package:soely/core/utils/responsive_utils.dart';
import 'package:soely/shared/widgets/ooter.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = ResponsiveUtils.isWeb(context);
    
    // ✅ WRAP WITH Consumer TO REBUILD ON LANGUAGE CHANGE
    return Consumer<LanguageService>(
      builder: (context, languageService, _) {
        return Scaffold(
          backgroundColor: isWeb ? const Color(0xFFFAFAFA) : Colors.white,
          appBar: _buildAppBar(context, isWeb),
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 1400.w),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWeb ? 60.w : 16.w,
                        vertical: isWeb ? 40.h : 24.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroSection(isWeb),
                          SizedBox(height: isWeb ? 60.h : 40.h),
                          _buildStorySection(isWeb),
                          SizedBox(height: isWeb ? 60.h : 40.h),
                          _buildValuesSection(isWeb),
                          SizedBox(height: isWeb ? 60.h : 40.h),
                          _buildMissionSection(isWeb),
                          SizedBox(height: isWeb ? 60.h : 40.h),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isWeb)
                  Container(
                    width: double.infinity,
                    child: FoodKingFooter(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isWeb) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textDark, size: 24.sp),
        onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
      ),
      title: Text(
        AppStrings.get('aboutUs'),
        style: TextStyle(
          fontSize: isWeb ? 24.sp : 20.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeroSection(bool isWeb) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWeb ? 48.w : 24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primaryLight.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: isWeb ? 80.sp : 60.sp,
            color: AppColors.primary,
          ),
          SizedBox(height: 24.h),
          Text(
            AppStrings.get('welcomeToApp').replaceAll('{appName}', AppStrings.appName),
            style: TextStyle(
              fontSize: isWeb ? 36.sp : 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            AppStrings.get('bestFastFoodDestination'),
            style: TextStyle(
              fontSize: isWeb ? 20.sp : 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMedium,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.get('ourStory'), isWeb),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(isWeb ? 32.w : 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            AppStrings.get('storyDescription').replaceAll('{appName}', AppStrings.appName),
            style: TextStyle(
              fontSize: isWeb ? 18.sp : 15.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMedium,
              height: 1.8,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  Widget _buildValuesSection(bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.get('ourValues'), isWeb),
        SizedBox(height: 24.h),
        LayoutBuilder(
          builder: (context, constraints) {
            if (isWeb && constraints.maxWidth > 800) {
              return Row(
                children: [
                  Expanded(child: _buildValueCard(
                    AppStrings.get('quality'), 
                    Icons.star, 
                    AppStrings.get('qualityDescription'), 
                    isWeb
                  )),
                  SizedBox(width: 20.w),
                  Expanded(child: _buildValueCard(
                    AppStrings.get('speed'), 
                    Icons.flash_on, 
                    AppStrings.get('speedDescription'), 
                    isWeb
                  )),
                  SizedBox(width: 20.w),
                  Expanded(child: _buildValueCard(
                    AppStrings.get('passion'), 
                    Icons.favorite, 
                    AppStrings.get('passionDescription'), 
                    isWeb
                  )),
                ],
              );
            }
            return Column(
              children: [
                _buildValueCard(
                  AppStrings.get('quality'), 
                  Icons.star, 
                  AppStrings.get('qualityDescription'), 
                  isWeb
                ),
                SizedBox(height: 16.h),
                _buildValueCard(
                  AppStrings.get('speed'), 
                  Icons.flash_on, 
                  AppStrings.get('speedDescription'), 
                  isWeb
                ),
                SizedBox(height: 16.h),
                _buildValueCard(
                  AppStrings.get('passion'), 
                  Icons.favorite, 
                  AppStrings.get('passionDescription'), 
                  isWeb
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildValueCard(String title, IconData icon, String description, bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 28.w : 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: isWeb ? 40.sp : 32.sp, color: AppColors.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: isWeb ? 22.sp : 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(
              fontSize: isWeb ? 16.sp : 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMedium,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection(bool isWeb) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWeb ? 40.w : 24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppStrings.get('ourMission'),
            style: TextStyle(
              fontSize: isWeb ? 32.sp : 24.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            AppStrings.get('missionDescription'),
            style: TextStyle(
              fontSize: isWeb ? 18.sp : 15.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isWeb ? 32.sp : 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 60.w,
          height: 4.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.5)],
            ),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ],
    );
  }
}