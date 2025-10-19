import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:soely/core/services/language_service.dart';

// Main Offer Model
class OfferModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String badge;
  final List<Color> gradientColors;
  final String? imageUrl;
  final DateTime? expiryDate;
  final String category;
  final String type;
  final double? value;
  final double minOrderAmount;
  final String? couponCode;
  final bool isActive;
  final bool isFeatured;

  const OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.badge,
    required this.gradientColors,
    this.imageUrl,
    this.expiryDate,
    required this.category,
    required this.type,
    this.value,
    this.minOrderAmount = 0,
    this.couponCode,
    this.isActive = true,
    this.isFeatured = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        badge,
        imageUrl,
        expiryDate,
        category,
        type,
        value,
        minOrderAmount,
        couponCode,
        isActive,
        isFeatured,
      ];

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    String badge = '';
    String category = 'general';
    
    switch (type) {
      case 'percentage':
        badge = 'SAVE ${json['value']}%';
        category = 'food';
        break;
      case 'fixed-amount':
        badge = '\$${json['value']} OFF';
        category = 'food';
        break;
      case 'buy-one-get-one':
        badge = 'BUY 1 GET 1';
        category = 'food';
        break;
      case 'free-delivery':
        badge = 'FREE DELIVERY';
        category = 'delivery';
        break;
      case 'combo':
        badge = 'COMBO DEAL';
        category = 'combo';
        break;
      default:
        badge = 'SPECIAL OFFER';
    }

    List<Color> gradientColors = _getGradientColors(
      json['bannerColor'] as String?,
      type,
    );

    return OfferModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      badge: badge,
      gradientColors: gradientColors,
      imageUrl: json['imageUrl'] as String?,
      expiryDate: json['endDate'] != null 
        ? DateTime.parse(json['endDate'] as String)
        : null,
      category: category,
      type: type,
      value: json['value']?.toDouble(),
      minOrderAmount: json['minOrderAmount']?.toDouble() ?? 0,
      couponCode: json['couponCode'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }
  

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'badge': badge,
      'imageUrl': imageUrl,
      'endDate': expiryDate?.toIso8601String(),
      'category': category,
      'type': type,
      'value': value,
      'minOrderAmount': minOrderAmount,
      'couponCode': couponCode,
      'isActive': isActive,
      'isFeatured': isFeatured,
    };
  }

  static List<Color> _getGradientColors(String? bannerColor, String type) {
    if (bannerColor != null && bannerColor.isNotEmpty) {
      try {
        final baseColor = _hexToColor(bannerColor);
        return [
          baseColor,
          baseColor.withOpacity(0.7),
        ];
      } catch (e) {
        // Fall back to default colors
      }
    }

    switch (type) {
      case 'percentage':
      case 'fixed-amount':
        return [const Color(0xFF7ED4AD), const Color(0xFF6BCF7F)];
      case 'buy-one-get-one':
        return [const Color(0xFFE91E63), const Color(0xFF9C27B0)];
      case 'free-delivery':
        return [const Color(0xFF2196F3), const Color(0xFF3F51B5)];
      case 'combo':
        return [const Color(0xFFFFC107), const Color(0xFFFF9800)];
      default:
        return [const Color(0xFF7ED4AD), const Color(0xFF6BCF7F)];
    }
  }

  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  bool get isValid {
    return isActive && !isExpired;
  }

  String get displayDiscount {
    switch (type) {
      case 'percentage':
        return '${value?.toInt()}% OFF';
      case 'fixed-amount':
        return '\$${value?.toInt()} OFF';
      case 'buy-one-get-one':
        return 'Buy 1 Get 1 Free';
      case 'free-delivery':
        return 'Free Delivery';
      case 'combo':
        return 'Special Combo Deal';
      default:
        return 'Special Offer';
    }
  }

  OfferModel copyWith({
    String? id,
    String? title,
    String? description,
    String? badge,
    List<Color>? gradientColors,
    String? imageUrl,
    DateTime? expiryDate,
    String? category,
    String? type,
    double? value,
    double? minOrderAmount,
    String? couponCode,
    bool? isActive,
    bool? isFeatured,
  }) {
    return OfferModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      badge: badge ?? this.badge,
      gradientColors: gradientColors ?? this.gradientColors,
      imageUrl: imageUrl ?? this.imageUrl,
      expiryDate: expiryDate ?? this.expiryDate,
      category: category ?? this.category,
      type: type ?? this.type,
      value: value ?? this.value,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      couponCode: couponCode ?? this.couponCode,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

// Simple Offer Info (used in FoodItem)
class SimpleOffer extends Equatable {
  final String id;
  final String title;
  final String type;
  final double value;
  final String badge;

  const SimpleOffer({
    required this.id,
    required this.title,
    required this.type,
    required this.value,
    required this.badge,
  });

  @override
  List<Object?> get props => [id, title, type, value, badge];

  factory SimpleOffer.fromJson(Map<String, dynamic> json) {
    return SimpleOffer(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      badge: json['badge'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'value': value,
      'badge': badge,
    };
  }

  SimpleOffer copyWith({
    String? id,
    String? title,
    String? type,
    double? value,
    String? badge,
  }) {
    return SimpleOffer(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      value: value ?? this.value,
      badge: badge ?? this.badge,
    );
  }
}

// Category Info (used in FoodItemWithOffer)

class CategoryInfo extends Equatable {
  final String id;
  final String name;
  final String? icon;

  const CategoryInfo({
    required this.id,
    required this.name,
    this.icon,
  });

  @override
  List<Object?> get props => [id, name, icon];

  factory CategoryInfo.fromJson(
    Map<String, dynamic> json, {
    String? currentLanguage,
  }) {
    try {
      final language = currentLanguage ?? LanguageService.spanish;

      // ✅ Handle multilingual category name
      String categoryName = '';
      if (json['name'] is Map) {
        categoryName = FoodItemWithOffer._getTextInLanguage(
          json['name'],
          language,
          fallback: 'Unknown',
        );
      } else {
        categoryName = json['name']?.toString() ?? 'Unknown';
      }

      return CategoryInfo(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: categoryName,
        icon: json['icon']?.toString(),
      );
    } catch (e) {
      return const CategoryInfo(
        id: 'unknown',
        name: 'Unknown Category',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'icon': icon,
    };
  }

  CategoryInfo copyWith({
    String? id,
    String? name,
    String? icon,
  }) {
    return CategoryInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }
}

// ... SimpleOffer class remains same ...
// Food Item with Offer (from items-with-offers endpoint)
class FoodItemWithOffer extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final CategoryInfo category;
  final bool isActive;
  final SimpleOffer? offer;
  final double discountedPrice;
  final double savings;
  final int discountPercentage;

  const FoodItemWithOffer({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isActive,
    this.offer,
    required this.discountedPrice,
    required this.savings,
    required this.discountPercentage,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        category,
        isActive,
        offer,
        discountedPrice,
        savings,
        discountPercentage,
      ];

  /// ✅ CRITICAL: Get text in specific language
  static String _getTextInLanguage(
    dynamic value,
    String targetLanguage, {
    String fallback = '',
  }) {
    if (value == null) return fallback;

    // If it's already a string, use it
    if (value is String) return value.isNotEmpty ? value : fallback;

    // If it's a multilingual Map
    if (value is Map) {
      // Try target language first
      if (value[targetLanguage] != null) {
        final text = value[targetLanguage].toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }

      // Fallback chain
      const fallbackChain = ['en', 'es', 'ca', 'ar'];
      for (final lang in fallbackChain) {
        if (value[lang] != null) {
          final text = value[lang].toString().trim();
          if (text.isNotEmpty) {
            return text;
          }
        }
      }
    }

    return fallback;
  }

  factory FoodItemWithOffer.fromJson(
    Map<String, dynamic> json, {
    String? currentLanguage,
  }) {
    try {
      // ✅ CRITICAL: Get language from parameter or LanguageService
      final language = currentLanguage ?? LanguageService.spanish;


      // ✅ Parse name with language
      final name = _getTextInLanguage(
        json['name'],
        language,
        fallback: 'Unknown Item',
      );

      // ✅ Parse description with language
      final description = _getTextInLanguage(
        json['description'],
        language,
        fallback: '',
      );

      // Parse category
      final categoryJson = json['category'];
      CategoryInfo category;

      if (categoryJson is Map) {
        category = CategoryInfo.fromJson(
          categoryJson as Map<String, dynamic>,
          currentLanguage: language,
        );
      } else {
        category = const CategoryInfo(
          id: 'unknown',
          name: 'Unknown Category',
        );
      }

      // Parse offer
      SimpleOffer? offerData;
      if (json['offer'] != null && json['offer'] is Map) {
        offerData = SimpleOffer.fromJson(json['offer'] as Map<String, dynamic>);
      }

      final result = FoodItemWithOffer(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: name,
        description: description,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: json['imageUrl']?.toString() ?? '',
        category: category,
        isActive: json['isActive'] as bool? ?? true,
        offer: offerData,
        discountedPrice: (json['discountedPrice'] as num?)?.toDouble() ??
            (json['price'] as num?)?.toDouble() ??
            0.0,
        savings: (json['savings'] as num?)?.toDouble() ?? 0.0,
        discountPercentage: json['discountPercentage'] as int? ?? 0,
      );

      return result;
    } catch (e, stackTrace) {
   
      rethrow;
    }
  }

}

