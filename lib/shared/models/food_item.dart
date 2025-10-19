// lib/shared/models/food_item.dart - FIXED English Support
import 'package:equatable/equatable.dart';
import 'package:soely/shared/models/offer.dart';
import 'package:soely/core/services/language_service.dart';
import 'package:flutter/foundation.dart';

class FoodItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isVeg;
  final bool isFeatured;
  final bool isPopular;
  final double rating;
  final int reviewCount;
  final SimpleOffer? offer;
  final List<String> tags;
  final List<MealSize> mealSizes;
  final List<Extra> extras;
  final List<Addon> addons;
  final String availabilityStatus;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isVeg = false,
    this.isFeatured = false,
    this.isPopular = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.offer,
    this.tags = const [],
    this.mealSizes = const [],
    this.extras = const [],
    this.addons = const [],
    this.availabilityStatus = 'in-stock',
  });

  @override
  List<Object?> get props => [
        id, name, description, price, imageUrl, category,
        isVeg, isFeatured, isPopular, rating, reviewCount,
        offer, tags, mealSizes, extras, addons, availabilityStatus,
      ];

  double get effectivePrice {
    if (offer == null) return price;
    switch (offer!.type) {
      case 'percentage':
        return price * (1 - offer!.value / 100);
      case 'fixed-amount':
        return (price - offer!.value).clamp(0, double.infinity);
      default:
        return price;
    }
  }

  double get discountAmount => price - effectivePrice;
  int get discountPercentage {
    if (offer == null || price == 0) return 0;
    return ((discountAmount / price) * 100).round();
  }
  bool get hasActiveOffer => offer != null && discountAmount > 0;

  FoodItem copyWith({
    String? id, String? name, String? description, double? price,
    String? imageUrl, String? category, bool? isVeg, bool? isFeatured,
    bool? isPopular, double? rating, int? reviewCount, SimpleOffer? offer,
    List<String>? tags, List<MealSize>? mealSizes, List<Extra>? extras,
    List<Addon>? addons, String? availabilityStatus,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isVeg: isVeg ?? this.isVeg,
      isFeatured: isFeatured ?? this.isFeatured,
      isPopular: isPopular ?? this.isPopular,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      offer: offer ?? this.offer,
      tags: tags ?? this.tags,
      mealSizes: mealSizes ?? this.mealSizes,
      extras: extras ?? this.extras,
      addons: addons ?? this.addons,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, 'name': name, 'description': description, 'price': price,
      'imageUrl': imageUrl, 'category': category, 'isVeg': isVeg,
      'isFeatured': isFeatured, 'isPopular': isPopular, 'rating': rating,
      'reviewCount': reviewCount, 'offer': offer?.toJson(), 'tags': tags,
      'mealSizes': mealSizes.map((x) => x.toMap()).toList(),
      'extras': extras.map((x) => x.toMap()).toList(),
      'addons': addons.map((x) => x.toMap()).toList(),
      'availabilityStatus': availabilityStatus,
    };
  }

  /// ✅ FIXED: Enhanced multilingual parsing with English support
factory FoodItem.fromMap(Map<String, dynamic> map, {String? currentLanguage}) {
  try {
    final lang = currentLanguage ?? LanguageService.english;

    /// ✅ FIXED: Extract from _multilingual first, then fallback to top-level
    String getLocalizedText(dynamic value, String fieldName, {String fallback = ''}) {
      if (value == null) return fallback;
      
      // If already a string, use it
      if (value is String) return value.isNotEmpty ? value : fallback;
      
      // If multilingual object, extract with proper fallback chain
      if (value is Map) {
        // Try current language first
        if (value[lang] != null && value[lang].toString().isNotEmpty) {
          return value[lang].toString();
        }
        
        // Proper fallback order
        final fallbackOrder = [
          lang,
          LanguageService.english,
          LanguageService.spanish,
          LanguageService.catalan,
          LanguageService.arabic,
        ];
        
        for (final langCode in fallbackOrder) {
          if (value[langCode] != null && value[langCode].toString().isNotEmpty) {
            return value[langCode].toString();
          }
        }
        
        // Last resort: any non-empty value
        for (var val in value.values) {
          if (val != null && val.toString().isNotEmpty) {
            return val.toString();
          }
        }
      }
      
      return fallback;
    }

    // ✅ CRITICAL: Check _multilingual first
    final multilingualData = map['_multilingual'] as Map<String, dynamic>?;
    
    // Parse name: Use _multilingual.name if available, otherwise fallback
    String parsedName = '';
    if (multilingualData != null && multilingualData['name'] != null) {
      parsedName = getLocalizedText(multilingualData['name'], 'name', fallback: 'Unknown Item');
    } else if (map['name'] != null) {
      parsedName = getLocalizedText(map['name'], 'name', fallback: 'Unknown Item');
    } else {
      parsedName = 'Unknown Item';
    }
    
    // Parse description: Use _multilingual.description if available
    String parsedDescription = '';
    if (multilingualData != null && multilingualData['description'] != null) {
      parsedDescription = getLocalizedText(multilingualData['description'], 'description', fallback: '');
    } else if (map['description'] != null) {
      parsedDescription = getLocalizedText(map['description'], 'description', fallback: '');
    }

    // Parse category ID
    String categoryId = '';
    if (map['category'] != null) {
      if (map['category'] is String) {
        categoryId = map['category'];
      } else if (map['category'] is Map) {
        categoryId = map['category']['_id']?.toString() ?? 
                    map['category']['id']?.toString() ?? '';
      }
    }

    // Parse rating
    double ratingValue = 0.0;
    int reviewCountValue = 0;
    if (map['rating'] != null) {
      if (map['rating'] is num) {
        ratingValue = map['rating'].toDouble();
        reviewCountValue = map['reviewCount']?.toInt() ?? 0;
      } else if (map['rating'] is Map) {
        ratingValue = (map['rating']['average'] ?? 0).toDouble();
        reviewCountValue = (map['rating']['count'] ?? 0).toInt();
      }
    }

    // Parse offer
    SimpleOffer? offerData;
    if (map['offer'] != null && map['offer'] is Map) {
      offerData = SimpleOffer.fromJson(map['offer']);
    }

    // Parse tags with localization
    List<String> parsedTags = [];
    if (map['tags'] != null && map['tags'] is List) {
      parsedTags = (map['tags'] as List)
          .map((tag) => getLocalizedText(tag, 'tag', fallback: ''))
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    // ✅ Parse meal sizes from _multilingual if available
    List<MealSize> parsedMealSizes = [];
    List<dynamic>? mealSizesList;
    
    if (multilingualData != null && multilingualData['mealSizes'] is List) {
      mealSizesList = multilingualData['mealSizes'] as List;
    } else if (map['mealSizes'] is List) {
      mealSizesList = map['mealSizes'] as List;
    }
    
    if (mealSizesList != null) {
      parsedMealSizes = mealSizesList
          .where((x) => x is Map<String, dynamic>)
          .map((x) => MealSize.fromMap(x as Map<String, dynamic>, currentLanguage: lang))
          .toList();
    }

    // Parse extras
    List<Extra> parsedExtras = [];
    if (map['extras'] is List) {
      parsedExtras = (map['extras'] as List)
          .where((x) => x is Map<String, dynamic> && x.isNotEmpty)
          .map((x) => Extra.fromMap(x as Map<String, dynamic>, currentLanguage: lang))
          .toList();
    }

    // Parse addons
    List<Addon> parsedAddons = [];
    if (map['addons'] is List) {
      parsedAddons = (map['addons'] as List)
          .where((x) => x is Map<String, dynamic> && x.isNotEmpty)
          .map((x) => Addon.fromMap(x as Map<String, dynamic>, currentLanguage: lang))
          .toList();
    }

  

    return FoodItem(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      name: parsedName,
      description: parsedDescription,
      price: (map['price'] is num ? map['price'].toDouble() : 0.0),
      imageUrl: map['imageUrl']?.toString() ?? '',
      category: categoryId,
      isVeg: map['isVeg'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
      isPopular: map['isPopular'] ?? false,
      rating: ratingValue,
      reviewCount: reviewCountValue,
      offer: offerData,
      tags: parsedTags,
      mealSizes: parsedMealSizes,
      extras: parsedExtras,
      addons: parsedAddons,
      availabilityStatus: map['availabilityStatus']?.toString() ?? 'in-stock',
    );
  } catch (e, stackTrace) {
    rethrow;
  }
}}

/// ✅ FIXED: MealSize, Extra, Addon with proper English support
class MealSize extends Equatable {
  final String id;
  final String name;
  final double additionalPrice;

  const MealSize({
    required this.id,
    required this.name,
    required this.additionalPrice,
  });

  @override
  List<Object?> get props => [id, name, additionalPrice];

  MealSize copyWith({String? id, String? name, double? additionalPrice}) {
    return MealSize(
      id: id ?? this.id,
      name: name ?? this.name,
      additionalPrice: additionalPrice ?? this.additionalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'additionalPrice': additionalPrice};
  }

  factory MealSize.fromMap(Map<String, dynamic> map, {String? currentLanguage}) {
    String getLocalizedText(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      if (value is String) return value.isNotEmpty ? value : fallback;
      if (value is Map) {
        final lang = currentLanguage ?? LanguageService.english;
        // ✅ Try current language → English → Spanish → any
        return value[lang]?.toString() ?? 
               value[LanguageService.english]?.toString() ?? 
               value[LanguageService.spanish]?.toString() ?? 
               fallback;
      }
      return fallback;
    }

    return MealSize(
      id: map['id']?.toString() ?? map['_id']?.toString() ?? '',
      name: getLocalizedText(map['name'], fallback: 'Unknown Size'),
      additionalPrice: (map['additionalPrice'] is num ? map['additionalPrice'].toDouble() : 0.0),
    );
  }
}

class Extra extends Equatable {
  final String id;
  final String name;
  final double price;

  const Extra({required this.id, required this.name, required this.price});

  @override
  List<Object?> get props => [id, name, price];

  Extra copyWith({String? id, String? name, double? price}) {
    return Extra(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'price': price};
  }

  factory Extra.fromMap(Map<String, dynamic> map, {String? currentLanguage}) {
    String getLocalizedText(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      if (value is String) return value.isNotEmpty ? value : fallback;
      if (value is Map) {
        final lang = currentLanguage ?? LanguageService.english;
        return value[lang]?.toString() ?? 
               value[LanguageService.english]?.toString() ?? 
               value[LanguageService.spanish]?.toString() ?? 
               fallback;
      }
      return fallback;
    }

    return Extra(
      id: map['id']?.toString() ?? map['_id']?.toString() ?? '',
      name: getLocalizedText(map['name'], fallback: 'Unknown Extra'),
      price: (map['price'] is num ? map['price'].toDouble() : 0.0),
    );
  }
}

class Addon extends Equatable {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  const Addon({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, price, imageUrl];

  Addon copyWith({String? id, String? name, double? price, String? imageUrl}) {
    return Addon(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'price': price, 'imageUrl': imageUrl};
  }

  factory Addon.fromMap(Map<String, dynamic> map, {String? currentLanguage}) {
    String getLocalizedText(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      if (value is String) return value.isNotEmpty ? value : fallback;
      if (value is Map) {
        final lang = currentLanguage ?? LanguageService.english;
        return value[lang]?.toString() ?? 
               value[LanguageService.english]?.toString() ?? 
               value[LanguageService.spanish]?.toString() ?? 
               fallback;
      }
      return fallback;
    }

    return Addon(
      id: map['id']?.toString() ?? map['_id']?.toString() ?? '',
      name: getLocalizedText(map['name'], fallback: 'Unknown Addon'),
      price: (map['price'] is num ? map['price'].toDouble() : 0.0),
      imageUrl: map['imageUrl']?.toString() ?? '',
    );
  }
}