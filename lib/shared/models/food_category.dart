// lib/shared/models/food_category.dart - FIXED English Support
import 'package:equatable/equatable.dart';
import 'package:soely/core/services/language_service.dart';

class FoodCategory extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String icon;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FoodCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.icon,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        icon,
        isActive,
        sortOrder,
        createdAt,
        updatedAt,
      ];

  FoodCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? icon,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'icon': icon,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// ✅ FIXED: Proper multilingual parsing with English support
  factory FoodCategory.fromMap(Map<String, dynamic> map, {String? currentLanguage}) {
    // Get current language or default to English
    final lang = currentLanguage ?? LanguageService.english;
    
    // ✅ CRITICAL FIX: Enhanced text extraction with proper fallback chain
    String getLocalizedText(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      
      // 1. If already a string (from backend localization), use it
      if (value is String) {
        return value.isNotEmpty ? value : fallback;
      }
      
      // 2. If multilingual object, extract with proper fallback chain
      if (value is Map) {
        // Try current language first
        if (value[lang] != null && value[lang].toString().isNotEmpty) {
          return value[lang].toString();
        }
        
        // ✅ FIXED: Proper fallback chain for all languages
        // Fallback order: current → English → Spanish → Catalan → Arabic → any
        final fallbackOrder = [
          lang,                        // Current language
          LanguageService.english,     // ✅ Always try English
          LanguageService.spanish,     // Then Spanish (default)
          LanguageService.catalan,     // Then Catalan
          LanguageService.arabic,      // Then Arabic
        ];
        
        // Try each language in order
        for (final langCode in fallbackOrder) {
          if (value[langCode] != null && value[langCode].toString().isNotEmpty) {
            return value[langCode].toString();
          }
        }
        
        // Last resort: try any non-empty value
        for (var val in value.values) {
          if (val != null && val.toString().isNotEmpty) {
            return val.toString();
          }
        }
      }
      
      return fallback;
    }

    // Parse localized name and description
    final localizedName = getLocalizedText(map['name'], fallback: 'Unknown Category');
    final localizedDescription = getLocalizedText(map['description'], fallback: '');

    return FoodCategory(
      id: map['_id'] ?? map['id'] ?? '',
      name: localizedName,
      description: localizedDescription,
      imageUrl: map['imageUrl'] ?? '',
      icon: map['icon'] ?? '🍔',
      isActive: map['isActive'] ?? true,
      sortOrder: map['sortOrder']?.toInt() ?? 0,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  factory FoodCategory.fromJson(String source) {
    return FoodCategory.fromMap({});
  }

  String toJson() {
    return toMap().toString();
  }
}