// lib/core/services/device_discount_manager.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

/// Manages device-level discount eligibility to ensure 
/// one device can only receive one discount
class DeviceDiscountManager {
  static const String _keyActiveDiscount = 'active_device_discount';
  static const String _keyDiscountHistory = 'device_discount_history';
  static const String _keyDeviceId = 'device_unique_id';
  
  final SharedPreferences _prefs;
  String? _deviceId;

  DeviceDiscountManager(this._prefs);

  /// Initialize and get device ID
  Future<void> initialize() async {
    _deviceId = await _getOrCreateDeviceId();
  }

  /// Get or create a unique device identifier
  Future<String> _getOrCreateDeviceId() async {
    // Check if we already have a device ID stored
    String? storedId = _prefs.getString(_keyDeviceId);
    if (storedId != null && storedId.isNotEmpty) {
      return storedId;
    }

    // Generate new device ID
    final deviceInfo = DeviceInfoPlugin();
    String deviceId;

    try {
      if (kIsWeb) {
        // For web, use a combination of browser info
        final webInfo = await deviceInfo.webBrowserInfo;
        deviceId = '${webInfo.vendor}_${webInfo.userAgent}_${webInfo.hardwareConcurrency}';
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; // This is the Android ID
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'ios_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        // Fallback for other platforms
        deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      }

      // Store the device ID
      await _prefs.setString(_keyDeviceId, deviceId);
      return deviceId;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting device ID: $e');
      }
      // Fallback to timestamp-based ID
      deviceId = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
      await _prefs.setString(_keyDeviceId, deviceId);
      return deviceId;
    }
  }

  /// Check if device already has an active discount
  Future<bool> hasActiveDiscount() async {
    final activeDiscountJson = _prefs.getString(_keyActiveDiscount);
    
    if (activeDiscountJson == null) {
      return false;
    }

    try {
      // Parse stored discount data
      final data = _parseDiscountData(activeDiscountJson);
      
      // Check if discount is still valid
      if (data['expiryDate'] != null) {
        final expiryDate = DateTime.parse(data['expiryDate'] as String);
        if (expiryDate.isBefore(DateTime.now())) {
          // Discount expired, clear it
          await clearActiveDiscount();
          return false;
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking active discount: $e');
      }
      return false;
    }
  }

  /// Get the currently active discount for this device
  Future<Map<String, dynamic>?> getActiveDiscount() async {
    final activeDiscountJson = _prefs.getString(_keyActiveDiscount);
    
    if (activeDiscountJson == null) {
      return null;
    }

    try {
      final data = _parseDiscountData(activeDiscountJson);
      
      // Check if discount is still valid
      if (data['expiryDate'] != null) {
        final expiryDate = DateTime.parse(data['expiryDate'] as String);
        if (expiryDate.isBefore(DateTime.now())) {
          // Discount expired
          await clearActiveDiscount();
          return null;
        }
      }

      return data;
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
  }) async {
    // Check if device already has an active discount
    if (await hasActiveDiscount()) {
      if (kDebugMode) {
        print('⚠️ Device already has an active discount');
      }
      return false;
    }

    final discountData = {
      'deviceId': _deviceId,
      'offerId': offerId,
      'offerTitle': offerTitle,
      'offerType': offerType,
      'discountValue': discountValue,
      'expiryDate': expiryDate?.toIso8601String(),
      'claimedAt': DateTime.now().toIso8601String(),
      'itemId': itemId,
      'itemName': itemName,
    };

    // Store as active discount
    await _prefs.setString(_keyActiveDiscount, _encodeDiscountData(discountData));
    
    // Add to history
    await _addToHistory(discountData);

    if (kDebugMode) {
      print('✅ Discount claimed successfully: $offerTitle');
    }

    return true;
  }

  /// Clear the active discount
  Future<void> clearActiveDiscount() async {
    await _prefs.remove(_keyActiveDiscount);
    
    if (kDebugMode) {
      print('🗑️ Active discount cleared');
    }
  }

  /// Get discount history for this device
  Future<List<Map<String, dynamic>>> getDiscountHistory() async {
    final historyJson = _prefs.getString(_keyDiscountHistory);
    
    if (historyJson == null) {
      return [];
    }

    try {
      // Simple comma-separated storage
      final List<String> historyItems = historyJson.split('|||');
      return historyItems
          .where((item) => item.isNotEmpty)
          .map((item) => _parseDiscountData(item))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting discount history: $e');
      }
      return [];
    }
  }

  /// Add discount to history
  Future<void> _addToHistory(Map<String, dynamic> discountData) async {
    final history = await getDiscountHistory();
    history.insert(0, discountData);
    
    // Keep only last 10 discounts
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    // Store history
    final historyJson = history
        .map((item) => _encodeDiscountData(item))
        .join('|||');
    
    await _prefs.setString(_keyDiscountHistory, historyJson);
  }

  /// Simple encoding for storage (key=value pairs)
  String _encodeDiscountData(Map<String, dynamic> data) {
    return data.entries
        .map((e) => '${e.key}=${e.value?.toString() ?? ""}')
        .join('&');
  }

  /// Simple decoding from storage
  Map<String, dynamic> _parseDiscountData(String encoded) {
    final Map<String, dynamic> data = {};
    
    final pairs = encoded.split('&');
    for (final pair in pairs) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        final key = parts[0];
        final value = parts[1];
        
        // Parse numbers
        if (key == 'discountValue') {
          data[key] = double.tryParse(value) ?? 0.0;
        } else {
          data[key] = value.isEmpty ? null : value;
        }
      }
    }
    
    return data;
  }

  /// Check if a specific offer was already claimed on this device
  Future<bool> wasOfferClaimed(String offerId) async {
    final history = await getDiscountHistory();
    return history.any((item) => item['offerId'] == offerId);
  }

  /// Get device ID
  String? get deviceId => _deviceId;

  /// Reset all discount data (for testing or user request)
  Future<void> resetAllDiscounts() async {
    await _prefs.remove(_keyActiveDiscount);
    await _prefs.remove(_keyDiscountHistory);
    
    if (kDebugMode) {
      print('🔄 All discount data reset');
    }
  }
}