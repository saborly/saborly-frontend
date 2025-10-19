// lib/shared/widgets/language_selector.dart - FIXED with Live Updates

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/services/api_service.dart';
import 'package:soely/features/providers/home_provider.dart';
import 'package:soely/features/providers/men_provider.dart';
import '../../core/constant/app_colors.dart';
import '../../core/services/language_service.dart';

class LanguageSelector extends StatelessWidget {
  final bool showLabel;
  final bool isCompact;
  
  const LanguageSelector({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, _) {
        final currentLang = languageService.currentLanguageOption;
        
        if (isCompact) {
          return _buildCompactSelector(context, languageService, currentLang);
        }
        
        return _buildFullSelector(context, languageService, currentLang);
      },
    );
  }

  Widget _buildCompactSelector(
    BuildContext context,
    LanguageService languageService,
    LanguageOption currentLang,
  ) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: DropdownButton<String>(
        value: currentLang.code,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: AppColors.textLight, size: 18.sp),
        items: LanguageService.supportedLanguages.map((lang) {
          return DropdownMenuItem<String>(
            value: lang.code,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(lang.flag, style: TextStyle(fontSize: 18.sp)),
                if (showLabel) ...[
                  SizedBox(width: 6.w),
                  Text(
                    lang.nativeName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            _changeLanguage(context, languageService, newValue);
          }
        },
      ),
    );
  }

  Widget _buildFullSelector(
    BuildContext context,
    LanguageService languageService,
    LanguageOption currentLang,
  ) {
    return InkWell(
      onTap: () => _showLanguageDialog(context, languageService),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentLang.flag, style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 8.w),
            Text(
              currentLang.nativeName,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.arrow_drop_down, color: AppColors.textLight, size: 20.sp),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageService languageService) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400.w),
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getDialogTitle(languageService),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: Icon(Icons.close, size: 24.sp),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                ...LanguageService.supportedLanguages.map((lang) {
                  final isSelected = lang.code == languageService.currentLanguage;
                  return _buildLanguageOption(
                    dialogContext,
                    languageService,
                    lang,
                    isSelected,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDialogTitle(LanguageService languageService) {
    switch (languageService.currentLanguage) {
      case LanguageService.english:
        return 'Select Language';
      case LanguageService.spanish:
        return 'Seleccionar Idioma';
      case LanguageService.catalan:
        return 'Seleccionar Idioma';
      case LanguageService.arabic:
        return 'اختر اللغة';
      default:
        return 'Select Language';
    }
  }

  Widget _buildLanguageOption(
    BuildContext context,
    LanguageService languageService,
    LanguageOption lang,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        _changeLanguage(context, languageService, lang.code);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(lang.flag, style: TextStyle(fontSize: 28.sp)),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.nativeName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                  Text(
                    languageService.getLocalizedLanguageName(lang.code),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  /// ✅ FIXED: Proper language change with immediate UI updates
  void _changeLanguage(
    BuildContext context,
    LanguageService languageService,
    String languageCode,
  ) async {
    final selectedLang = LanguageService.supportedLanguages
        .firstWhere((lang) => lang.code == languageCode);
    
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16.w,
              height: 16.h,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12.w),
            Text(_getLoadingMessage(languageService)),
          ],
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      // ✅ STEP 1: Change language in LanguageService
      await languageService.changeLanguage(languageCode);
      
      // ✅ STEP 2: Sync AppStrings IMMEDIATELY
      AppStrings.setLanguage(languageCode);
      
      // ✅ STEP 3: Update API service language
      ApiService().setLanguage(languageCode);
      
      // ✅ STEP 4: Force UI rebuild by calling setState on providers
      if (context.mounted) {
        // Reload data with new language
        final homeProvider = context.read<HomeProvider>();
        final menuProvider = context.read<MenuProvider>();
        
        // Force immediate reload
        await Future.wait([
          homeProvider.loadData(),
          menuProvider.loadCategories(),
          menuProvider.loadFoodItems(),
        ]);
      }
      
      // ✅ STEP 5: Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getSuccessMessage(languageService, selectedLang)),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Handle errors
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change language: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getLoadingMessage(LanguageService languageService) {
    switch (languageService.currentLanguage) {
      case LanguageService.english:
        return 'Changing language...';
      case LanguageService.spanish:
        return 'Cambiando idioma...';
      case LanguageService.catalan:
        return 'Canviant idioma...';
      case LanguageService.arabic:
        return 'تغيير اللغة...';
      default:
        return 'Changing language...';
    }
  }

  String _getSuccessMessage(LanguageService languageService, LanguageOption selectedLang) {
    switch (languageService.currentLanguage) {
      case LanguageService.english:
        return 'Language changed to ${selectedLang.nativeName}';
      case LanguageService.spanish:
        return 'Idioma cambiado a ${selectedLang.nativeName}';
      case LanguageService.catalan:
        return 'Idioma canviat a ${selectedLang.nativeName}';
      case LanguageService.arabic:
        return 'تم تغيير اللغة إلى ${selectedLang.nativeName}';
      default:
        return 'Language changed to ${selectedLang.nativeName}';
    }
  }
}