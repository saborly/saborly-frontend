// lib/core/services/language_service.dart - Enhanced 4 Language Support
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  // Language codes
  static const String english = 'en';
  static const String spanish = 'es';
  static const String catalan = 'ca';
  static const String arabic = 'ar';
  
  // Supported languages with complete configuration
  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(
      code: english,
      name: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
      flagAsset: 'assets/images/flags/uk_flag.png',
      countryCode: 'GB',
      isRTL: false,
    ),
    LanguageOption(
      code: spanish,
      name: 'Spanish',
      nativeName: 'Español',
      flag: '🇪🇸',
      flagAsset: 'assets/images/flags/spain_flag.png',
      countryCode: 'ES',
      isRTL: false,
    ),
    LanguageOption(
      code: catalan,
      name: 'Catalan',
      nativeName: 'Català',
      flag: '🏴',
      flagAsset: 'assets/images/flags/catalan_flag.png',
      countryCode: 'CT',
      isRTL: false,
    ),
    LanguageOption(
      code: arabic,
      name: 'Arabic',
      nativeName: 'العربية',
      flag: '🇸🇦',
      flagAsset: 'assets/images/flags/arabic_flag.png',
      countryCode: 'SA',
      isRTL: true,
    ),
  ];
  
  String _currentLanguage = spanish; // Default to Spanish
  final SharedPreferences _prefs;
  
  LanguageService(this._prefs) {
    _loadSavedLanguage();
  }
  
  // Getters
  String get currentLanguage => _currentLanguage;
  
  LanguageOption get currentLanguageOption {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == _currentLanguage,
      orElse: () => supportedLanguages[1], // Default to Spanish
    );
  }
  
  bool get isRTL => currentLanguageOption.isRTL;
  
  TextDirection get textDirection {
    return isRTL ? TextDirection.rtl : TextDirection.ltr;
  }
  
  Locale get locale {
    final langCode = _currentLanguage;
    final countryCode = currentLanguageOption.countryCode;
    return Locale(langCode, countryCode);
  }
  
  // Check if current language is specific language
  bool get isEnglish => _currentLanguage == english;
  bool get isSpanish => _currentLanguage == spanish;
  bool get isCatalan => _currentLanguage == catalan;
  bool get isArabic => _currentLanguage == arabic;
  
  // Private methods
  void _loadSavedLanguage() {
    final savedLang = _prefs.getString(_languageKey);
    if (savedLang != null && _isValidLanguage(savedLang)) {
      _currentLanguage = savedLang;
    }
  }
  
  bool _isValidLanguage(String code) {
    return supportedLanguages.any((lang) => lang.code == code);
  }
  
  // Public methods
  Future<void> changeLanguage(String languageCode) async {
    if (!_isValidLanguage(languageCode)) {
      throw ArgumentError('Unsupported language: $languageCode');
    }
    
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      await _prefs.setString(_languageKey, languageCode);
      notifyListeners();
    }
  }
  
  // Get language option by code
  LanguageOption? getLanguageByCode(String code) {
    try {
      return supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }
  
  // Get localized language name
  String getLocalizedLanguageName(String languageCode) {
    switch (_currentLanguage) {
      case english:
        return _getEnglishName(languageCode);
      case spanish:
        return _getSpanishName(languageCode);
      case catalan:
        return _getCatalanName(languageCode);
      case arabic:
        return _getArabicName(languageCode);
      default:
        return getLanguageByCode(languageCode)?.name ?? languageCode;
    }
  }
  
  String _getEnglishName(String code) {
    switch (code) {
      case english: return 'English';
      case spanish: return 'Spanish';
      case catalan: return 'Catalan';
      case arabic: return 'Arabic';
      default: return code;
    }
  }
  
  String _getSpanishName(String code) {
    switch (code) {
      case english: return 'Inglés';
      case spanish: return 'Español';
      case catalan: return 'Catalán';
      case arabic: return 'Árabe';
      default: return code;
    }
  }
  
  String _getCatalanName(String code) {
    switch (code) {
      case english: return 'Anglès';
      case spanish: return 'Espanyol';
      case catalan: return 'Català';
      case arabic: return 'Àrab';
      default: return code;
    }
  }
  
  String _getArabicName(String code) {
    switch (code) {
      case english: return 'الإنجليزية';
      case spanish: return 'الإسبانية';
      case catalan: return 'الكاتالونية';
      case arabic: return 'العربية';
      default: return code;
    }
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final String flagAsset;
  final String countryCode;
  final bool isRTL;
  
  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.flagAsset,
    required this.countryCode,
    this.isRTL = false,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageOption && other.code == code;
  }
  
  @override
  int get hashCode => code.hashCode;
  
  @override
  String toString() => 'LanguageOption(code: $code, name: $name)';
}