// lib/core/services/device_discount_manager.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceDiscountManager {
  final SharedPreferences _prefs;
  String? _deviceId;

  static const String _keyActiveDiscount = 'active_discount';
  static const String _keyDiscountHistory = 'discount_history';
  static const String _keyDeviceId = 'device_id';
  static const String _keyClaimedOffers = 'claimed_offers'; // NEW

  DeviceDiscountManager(this._prefs);

  String? get deviceId => _deviceId;

  /// Initialize and get/generate device ID
  Future<void> initialize() async {
    _deviceId = _prefs.getString(_keyDeviceId);

    if (_deviceId == null || _deviceId!.isEmpty) {
      _deviceId = await _generateDeviceId();
      await _prefs.setString(_keyDeviceId, _deviceId!);
      
      if (kDebugMode) {
        print('📱 Generated new device ID: $_deviceId');
      }
    } else {
      if (kDebugMode) {
        print('📱 Using existing device ID: $_deviceId');
      }
    }
  }

  /// Generate unique device ID
  Future<String> _generateDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String identifier = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        identifier = '${androidInfo.id}_${androidInfo.device}_${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        identifier = '${iosInfo.identifierForVendor}_${iosInfo.model}';
      } else {
        identifier = 'web_${DateTime.now().millisecondsSinceEpoch}';
      }

      return identifier.hashCode.abs().toString();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating device ID: $e');
      }
      return 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // ==================== CLAIMED OFFERS MANAGEMENT ====================

  /// Get set of claimed offer IDs for this device
  Future<Set<String>> getClaimedOfferIds() async {
    try {
      final claimedJson = _prefs.getString(_keyClaimedOffers);
      if (claimedJson == null) return {};

      final List<dynamic> claimedList = json.decode(claimedJson);
      return claimedList
          .map((item) => item['offerId'] as String?)
          .whereType<String>()
          .toSet();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting claimed offers: $e');
      }
      return {};
    }
  }

  /// Mark an offer as claimed by this device
  Future<bool> markOfferAsClaimed(String offerId, {
    String? offerTitle,
    String? userId,
  }) async {
    try {
      final claimedJson = _prefs.getString(_keyClaimedOffers) ?? '[]';
      final List<dynamic> claimedList = json.decode(claimedJson);

      // Check if already claimed
      if (claimedList.any((item) => item['offerId'] == offerId)) {
        if (kDebugMode) {
          print('⚠️ Offer $offerId already claimed by this device');
        }
        return false;
      }

      // Add new claim
      claimedList.add({
        'offerId': offerId,
        'offerTitle': offerTitle,
        'claimedAt': DateTime.now().toIso8601String(),
        'userId': userId,
        'deviceId': _deviceId,
      });

      await _prefs.setString(_keyClaimedOffers, json.encode(claimedList));

      if (kDebugMode) {
        print('✅ Marked offer $offerId as claimed for device $_deviceId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error marking offer as claimed: $e');
      }
      return false;
    }
  }

  /// Check if specific offer is claimed by this device
  Future<bool> isOfferClaimed(String offerId) async {
    final claimedIds = await getClaimedOfferIds();
    return claimedIds.contains(offerId);
  }

  /// Get full claimed offers history
  Future<List<Map<String, dynamic>>> getClaimedOffersHistory() async {
    try {
      final claimedJson = _prefs.getString(_keyClaimedOffers);
      if (claimedJson == null) return [];

      final List<dynamic> claimedList = json.decode(claimedJson);
      return claimedList.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting claimed offers history: $e');
      }
      return [];
    }
  }

  // ==================== ACTIVE DISCOUNT MANAGEMENT ====================

  /// Check if device has an active discount
  Future<bool> hasActiveDiscount() async {
    final activeDiscount = await getActiveDiscount();
    return activeDiscount != null;
  }

  /// Get currently active discount for this device
  Future<Map<String, dynamic>?> getActiveDiscount() async {
    try {
      final discountJson = _prefs.getString(_keyActiveDiscount);
      if (discountJson == null) return null;

      final discount = json.decode(discountJson) as Map<String, dynamic>;

      // Check if expired
      if (discount['expiryDate'] != null) {
        final expiry = DateTime.parse(discount['expiryDate']);
        if (expiry.isBefore(DateTime.now())) {
          await clearActiveDiscount();
          return null;
        }
      }

      return discount;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting active discount: $e');
      }
      return null;
    }
  }

  /// Claim a discount for this device
  Future<bool> claimDiscount({
    required String offerId,
    required String offerTitle,
    required String offerType,
    required double discountValue,
    DateTime? expiryDate,
    String? itemId,
    String? itemName,
    bool isOneTimeOffer = false,
  }) async {
    try {
      // Check if device already has active discount
      if (await hasActiveDiscount()) {
        if (kDebugMode) {
          print('⚠️ Device already has an active discount');
        }
        return false;
      }

      // Check if one-time offer already claimed
      if (isOneTimeOffer && await isOfferClaimed(offerId)) {
        if (kDebugMode) {
          print('⚠️ One-time offer already claimed by this device');
        }
        return false;
      }

      final discount = {
        'offerId': offerId,
        'offerTitle': offerTitle,
        'offerType': offerType,
        'discountValue': discountValue,
        'expiryDate': expiryDate?.toIso8601String(),
        'claimedAt': DateTime.now().toIso8601String(),
        'itemId': itemId,
        'itemName': itemName,
        'deviceId': _deviceId,
        'isOneTimeOffer': isOneTimeOffer,
      };

      await _prefs.setString(_keyActiveDiscount, json.encode(discount));

      // Add to history
      await _addToHistory(discount);

      // Mark as claimed if one-time offer
      if (isOneTimeOffer) {
        await markOfferAsClaimed(offerId, offerTitle: offerTitle);
      }

      if (kDebugMode) {
        print('✅ Discount claimed: $offerTitle');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error claiming discount: $e');
      }
      return false;
    }
  }

  /// Clear active discount (called after order completion)
  Future<void> clearActiveDiscount() async {
    await _prefs.remove(_keyActiveDiscount);
    
    if (kDebugMode) {
      print('🗑️ Active discount cleared');
    }
  }

  /// Get discount history
  Future<List<Map<String, dynamic>>> getDiscountHistory() async {
    try {
      final historyJson = _prefs.getString(_keyDiscountHistory);
      if (historyJson == null) return [];

      final List<dynamic> history = json.decode(historyJson);
      return history.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting history: $e');
      }
      return [];
    }
  }

  /// Add discount to history
  Future<void> _addToHistory(Map<String, dynamic> discount) async {
    try {
      final history = await getDiscountHistory();
      history.insert(0, {
        ...discount,
        'usedAt': DateTime.now().toIso8601String(),
      });

      // Keep only last 50 entries
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }

      await _prefs.setString(_keyDiscountHistory, json.encode(history));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding to history: $e');
      }
    }
  }

  /// Clear all data (for testing/debugging)
  Future<void> clearAll() async {
    await _prefs.remove(_keyActiveDiscount);
    await _prefs.remove(_keyDiscountHistory);
    await _prefs.remove(_keyClaimedOffers);
    
    if (kDebugMode) {
      print('🗑️ All discount data cleared');
    }
  }
}