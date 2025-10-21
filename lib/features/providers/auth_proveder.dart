// lib/features/providers/auth_provider.dart - PRODUCTION READY

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Saborly/core/services/notification_service.dart';
import '../../../shared/models/user.dart';
import '../../../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final ApiService _apiService = ApiService();
  String? _resetToken;
  Timer? _tokenExpiryTimer;
  Timer? _tokenValidationTimer;

  // Token refresh 5 minutes before expiry
  static const Duration _tokenRefreshBuffer = Duration(minutes: 5);
  static const Duration _tokenValidationInterval = Duration(minutes: 5);

  String? get resetToken => _resetToken;

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _requiresVerification = false;
  String? _pendingVerificationEmail;

  AuthProvider(this._prefs);

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get requiresVerification => _requiresVerification;
  String? get pendingVerificationEmail => _pendingVerificationEmail;

  @override
  void dispose() {
    _tokenExpiryTimer?.cancel();
    _tokenValidationTimer?.cancel();
    super.dispose();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setRequiresVerification(bool requires, [String? email]) {
    _requiresVerification = requires;
    _pendingVerificationEmail = email;
    notifyListeners();
  }

  /// Setup timer to refresh token BEFORE expiry
  void _setupTokenExpiryTimer() {
    _tokenExpiryTimer?.cancel();
    _tokenValidationTimer?.cancel();
    
    final tokenExpiry = _prefs.getInt('token_expiry');
    if (tokenExpiry == null) {
      if (kDebugMode) print('⚠️ No token expiry found');
      return;
    }

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(tokenExpiry);
    final now = DateTime.now();
    
    if (kDebugMode) {
      print('🔐 Token expires at: $expiryTime');
      print('⏰ Current time: $now');
    }
    
    // Token already expired
    if (expiryTime.isBefore(now)) {
      if (kDebugMode) print('❌ Token expired - logging out');
      _handleTokenExpiry();
      return;
    }
    
    final duration = expiryTime.difference(now);
    final refreshDuration = duration - _tokenRefreshBuffer;
    
    if (kDebugMode) {
      print('⏳ Token expires in: ${duration.inMinutes} minutes');
      print('🔄 Will refresh in: ${refreshDuration.inMinutes} minutes');
    }
    
    // Refresh immediately if expiring soon
    if (refreshDuration.isNegative) {
      _refreshToken();
    } else {
      _tokenExpiryTimer = Timer(refreshDuration, _refreshToken);
    }
    
    // Safety net - validate every 5 minutes
    _tokenValidationTimer = Timer.periodic(
      _tokenValidationInterval,
      (_) => validateToken(),
    );
  }

  /// Attempt to refresh token before expiry
  Future<void> _refreshToken() async {
    if (_user == null) return;
    
    try {
      if (kDebugMode) print('🔄 Refreshing token...');
      
      final response = await _apiService.refreshToken();
      
      if (response.isSuccess && response.data != null) {
        // Update user token
        _user = _user!.copyWith(token: response.data);
        await _saveUserData();
        
        // Reset timer with new expiry
        _setupTokenExpiryTimer();
        
        if (kDebugMode) print('✅ Token refreshed successfully');
      } else {
        if (kDebugMode) print('❌ Refresh failed: ${response.error}');
        await _handleTokenExpiry();
      }
    } catch (e) {
      if (kDebugMode) print('❌ Refresh error: $e');
      await _handleTokenExpiry();
    }
  }

  /// Handle token expiry - force logout
  Future<void> _handleTokenExpiry() async {
    if (kDebugMode) print('🚫 Token expired - forcing logout');
    
    _setError('Your session has expired. Please login again.');
    await _clearUserData();
    _user = null;
    _setRequiresVerification(false);
    
    _tokenExpiryTimer?.cancel();
    _tokenValidationTimer?.cancel();
    
    notifyListeners();
  }

  /// Validate token on app resume
  Future<void> validateToken() async {
    final tokenExpiry = _prefs.getInt('token_expiry');
    
    if (tokenExpiry == null) {
      if (kDebugMode) print('⚠️ No token expiry found');
      return;
    }

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(tokenExpiry);
    final now = DateTime.now();
    
    if (kDebugMode) {
      print('🔍 Validating token...');
      print('   Expires: $expiryTime');
      print('   Now: $now');
    }
    
    // If expiring soon, try refresh
    if (now.add(_tokenRefreshBuffer).isAfter(expiryTime)) {
      if (kDebugMode) print('⏰ Token expiring soon - attempting refresh');
      await _refreshToken();
      return;
    }
    
    // If already expired
    if (expiryTime.isBefore(now)) {
      if (kDebugMode) print('❌ Token expired');
      await _handleTokenExpiry();
    } else {
      final remaining = expiryTime.difference(now);
      if (kDebugMode) print('✅ Token valid - ${remaining.inMinutes} min remaining');
    }
  }

  /// Check auth status on app start
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    
    try {
      final token = _prefs.getString('auth_token');
      if (token != null) {
        final tokenExpiry = _prefs.getInt('token_expiry');
        if (tokenExpiry != null) {
          final expiryTime = DateTime.fromMillisecondsSinceEpoch(tokenExpiry);
          
          // Try refresh if expired
          if (DateTime.now().isAfter(expiryTime)) {
            if (kDebugMode) print('⏰ Token expired on startup - refreshing');
            await _refreshToken();
            _setLoading(false);
            return;
          }
        }
        
        _apiService.setAuthToken(token);
        
        final userId = _prefs.getString('user_id');
        final firstName = _prefs.getString('firstName');
        final lastName = _prefs.getString('lastName');
        final email = _prefs.getString('email');
        final phone = _prefs.getString('phone');
        
        if (userId != null && firstName != null && lastName != null && 
            email != null && phone != null) {
          _user = User(
            id: userId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            token: token,
          );
          
          if (kDebugMode) print('✅ Auth restored for: $email');
          _setupTokenExpiryTimer();
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Auth check error: $e');
      _setError('Failed to check authentication');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _setError(null);
    _setRequiresVerification(false);
    
    try {
      final response = await _apiService.login(email, password);
      
      if (response.isSuccess && response.data != null) {
        _user = response.data!;
        await _saveUserData();
        _setupTokenExpiryTimer();
        await _registerFCMToken();
        
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login error occurred');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String firstName, String lastName, String email, 
                      String phone, String password) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );
      
      if (response.isSuccess) {
        final requiresVerification = response.rawData?['requiresVerification'] ?? false;
        
        if (requiresVerification) {
          _setRequiresVerification(true, email);
        } else if (response.data != null) {
          _user = response.data!;
          await _saveUserData();
          _setupTokenExpiryTimer();
        }
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Registration error');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOTP(String email, String otp) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.verifyOTP(email, otp);
      
      if (response.isSuccess && response.data != null) {
        _user = response.data!;
        await _saveUserData();
        _setupTokenExpiryTimer();
        await _registerFCMToken();
        _setRequiresVerification(false);
        
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Invalid OTP');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Verification error');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      _tokenExpiryTimer?.cancel();
      _tokenValidationTimer?.cancel();
      
      await _apiService.removeFCMToken();
      await _apiService.logout();
      await _clearUserData();
      _user = null;
      _setRequiresVerification(false);
      
      if (kDebugMode) print('✅ Signed out');
    } catch (e) {
      if (kDebugMode) print('⚠️ Logout error: $e');
      await _clearUserData();
      _user = null;
      _setRequiresVerification(false);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _registerFCMToken() async {
    try {
      final notificationService = NotificationService();
      final fcmToken = notificationService.fcmToken;
      
      if (fcmToken != null) {
        await _apiService.updateFCMToken(
          fcmToken: fcmToken,
          deviceId: 'default',
          platform: Platform.operatingSystem,
        );
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ FCM error: $e');
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      if (newPassword != confirmPassword) {
        _setError('Passwords do not match');
        _setLoading(false);
        return false;
      }

      if (newPassword.length < 6) {
        _setError('Password must be at least 6 characters');
        _setLoading(false);
        return false;
      }

      final response = await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      if (response.isSuccess) {
        final newToken = _apiService.getAuthToken();
        if (newToken != null && _user != null) {
          _user = _user!.copyWith(token: newToken);
          await _saveUserData();
          _setupTokenExpiryTimer();
        }
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to change password');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Password change error');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile(String firstName, String lastName, String phone) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.updateProfile({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      });
 
      if (response.isSuccess && response.data != null) {
        _user = response.data!;
        await _saveUserData();
        _setLoading(false);
        return true;
      } else {
        _setError('Profile update failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Profile update error');
      _setLoading(false);
      return false;
    }
  }

  // Password reset methods remain the same...
  Future<bool> requestPasswordReset(String email) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.requestPasswordReset(email);
      _setLoading(false);
      return response.isSuccess;
    } catch (e) {
      _setError('Error requesting reset');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyPasswordResetOTP(String email, String otp) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.verifyResetOTP(email, otp);
      
      if (response.isSuccess && response.data != null) {
        _resetToken = response.data!;
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Invalid OTP');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Verification error');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      if (_resetToken == null) {
        _setError('Verify OTP first');
        _setLoading(false);
        return false;
      }

      if (newPassword != confirmPassword) {
        _setError('Passwords do not match');
        _setLoading(false);
        return false;
      }

      if (newPassword.length < 6) {
        _setError('Password too short');
        _setLoading(false);
        return false;
      }

      final response = await _apiService.resetPassword(
        email: email,
        resetToken: _resetToken!,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      if (response.isSuccess && response.data != null) {
        _user = response.data!;
        await _saveUserData();
        _setupTokenExpiryTimer();
        _resetToken = null;
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Reset failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Reset error');
      _setLoading(false);
      return false;
    }
  }

  /// Save user data with 24-hour token expiry
  Future<void> _saveUserData() async {
    if (_user != null) {
      await _prefs.setString('user_id', _user!.id);
      await _prefs.setString('firstName', _user!.firstName);
      await _prefs.setString('lastName', _user!.lastName);
      await _prefs.setString('email', _user!.email);
      await _prefs.setString('phone', _user!.phone);
      await _prefs.setString('auth_token', _user!.token ?? '');
      
      final expiryTime = DateTime.now().add(const Duration(hours: 24));
      await _prefs.setInt('token_expiry', expiryTime.millisecondsSinceEpoch);
      
      if (kDebugMode) {
        print('💾 User data saved - expires: $expiryTime');
      }
    }
  }

  Future<bool> resendOTP(String email) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.resendOTP(email);
      
      if (response.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to send OTP');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }
  Future<bool> resendPasswordResetOTP(String email) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.resendResetOTP(email);
      
      if (response.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to send OTP');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<void> _clearUserData() async {
    await _prefs.remove('user_id');
    await _prefs.remove('firstName');
    await _prefs.remove('lastName');
    await _prefs.remove('email');
    await _prefs.remove('phone');
    await _prefs.remove('auth_token');
    await _prefs.remove('token_expiry');
    _apiService.clearAuthToken();
    
    if (kDebugMode) print('🗑️ User data cleared');
  }

  void clearError() => _setError(null);
  void clearVerificationState() => _setRequiresVerification(false);
  void clearResetToken() => _resetToken = null;
}