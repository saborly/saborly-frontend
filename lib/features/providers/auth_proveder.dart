// lib/features/providers/auth_provider.dart - WEB ACCESS TOKEN FIX

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:Saborly/core/services/notification_service.dart';
import '../../../shared/models/user.dart';
import '../../../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final ApiService _apiService = ApiService();
  
  // Configure GoogleSignIn with better scopes
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
    clientId: kIsWeb 
      ? '130218217091-ta95bq5pq3b38aqdlr158m6q6umug720.apps.googleusercontent.com' 
      : null,
  );

  String? _resetToken;
  Timer? _tokenExpiryTimer;
  Timer? _tokenValidationTimer;
  bool _isSocialLoading = false;

  static const Duration _tokenRefreshBuffer = Duration(minutes: 5);
  static const Duration _tokenValidationInterval = Duration(minutes: 5);

  String? get resetToken => _resetToken;
  bool get isSocialLoading => _isSocialLoading;

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

  void _setSocialLoading(bool loading) {
    _isSocialLoading = loading;
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

  String _getPlatform() {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name.toLowerCase();
  }

  Future<bool> signInWithGoogle() async {
    _setSocialLoading(true);
    _setError(null);

    try {
      if (kDebugMode) {
        print('🔵 Starting Google Sign-In...');
        print('   Platform: ${kIsWeb ? "WEB" : "MOBILE"}');
      }

      // Sign out first to ensure clean state
      try {
        await _googleSignIn.signOut();
        if (kDebugMode) print('   Signed out previous session');
      } catch (e) {
        if (kDebugMode) print('   No previous session to sign out');
      }

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (kDebugMode) print('⚠️ User cancelled Google Sign-In');
        _setSocialLoading(false);
        return false;
      }

      if (kDebugMode) {
        print('✅ Got Google account:');
        print('   Email: ${googleUser.email}');
        print('   Display Name: ${googleUser.displayName}');
        print('   ID: ${googleUser.id}');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (kDebugMode) {
        print('✅ Got authentication:');
        print('   ID Token: ${googleAuth.idToken != null ? "Present (${googleAuth.idToken!.length} chars)" : "NULL"}');
        print('   Access Token: ${googleAuth.accessToken != null ? "Present" : "NULL"}');
      }

      String? idToken = googleAuth.idToken;

      // WEB FIX: If no ID token but we have access token, exchange it for ID token
      if (idToken == null && googleAuth.accessToken != null && kIsWeb) {
        if (kDebugMode) print('🔄 Web platform: Using access token to get user info...');
        
        try {
          // Get user info from Google using access token
          final userInfoResponse = await http.get(
            Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'),
            headers: {
              'Authorization': 'Bearer ${googleAuth.accessToken}',
            },
          );

          if (userInfoResponse.statusCode == 200) {
            final userInfo = json.decode(userInfoResponse.body);
            
            if (kDebugMode) {
              print('✅ Got user info from Google:');
              print('   Email: ${userInfo['email']}');
              print('   Name: ${userInfo['name']}');
              print('   Verified: ${userInfo['verified_email']}');
            }

            // Send user info directly to backend for web
            final response = await _apiService.googleSignInWeb(
              email: userInfo['email'],
              firstName: userInfo['given_name'] ?? userInfo['name']?.split(' ').first ?? 'User',
              lastName: userInfo['family_name'] ?? userInfo['name']?.split(' ').last ?? '',
              googleId: userInfo['id'],
              accessToken: googleAuth.accessToken!,
            );

            if (response.isSuccess && response.data != null) {
              _user = response.data!;
              await _saveUserData();
              _setupTokenExpiryTimer();
              await _registerFCMToken();

              if (kDebugMode) {
                print('✅ Google Sign-In successful (Web mode)!');
                print('   User: ${_user!.firstName} ${_user!.lastName}');
                print('   Email: ${_user!.email}');
              }
              
              _setSocialLoading(false);
              return true;
            } else {
              if (kDebugMode) print('❌ Backend error: ${response.error}');
              _setError(response.error ?? 'Google sign-in failed on server');
              _setSocialLoading(false);
              return false;
            }
          } else {
            throw Exception('Failed to get user info: ${userInfoResponse.statusCode}');
          }
        } catch (e) {
          if (kDebugMode) print('❌ Error getting user info: $e');
          _setError('Failed to get user information from Google');
          _setSocialLoading(false);
          return false;
        }
      }

      // Mobile flow: Use ID token
      if (idToken == null) {
        if (kDebugMode) print('❌ No ID token or access token available');
        _setError('Failed to get Google credentials');
        _setSocialLoading(false);
        return false;
      }

      // Send ID token to backend (mobile flow)
      if (kDebugMode) print('📤 Sending ID token to backend...');
      
      final response = await _apiService.googleSignIn(idToken);

      if (response.isSuccess && response.data != null) {
        _user = response.data!;
        await _saveUserData();
        _setupTokenExpiryTimer();
        await _registerFCMToken();

        if (kDebugMode) {
          print('✅ Google Sign-In successful!');
          print('   User: ${_user!.firstName} ${_user!.lastName}');
          print('   Email: ${_user!.email}');
        }
        
        _setSocialLoading(false);
        return true;
      } else {
        if (kDebugMode) print('❌ Backend error: ${response.error}');
        _setError(response.error ?? 'Google sign-in failed on server');
        _setSocialLoading(false);
        return false;
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Google Sign-In error: $e');
        print('Stack trace: $stackTrace');
      }
      
      String errorMessage = 'Google sign-in error occurred';
      if (e.toString().contains('SIGN_IN_REQUIRED')) {
        errorMessage = 'Please try signing in again';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('PERMISSION_DENIED')) {
        errorMessage = 'Please enable People API in Google Cloud Console';
      }
      
      _setError(errorMessage);
      _setSocialLoading(false);
      return false;
    }
  }

  Future<void> _signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      if (kDebugMode) print('✅ Signed out from Google');
    } catch (e) {
      if (kDebugMode) print('⚠️ Google sign-out error: $e');
    }
  }

  // Token management methods
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
    
    if (refreshDuration.isNegative) {
      _refreshToken();
    } else {
      _tokenExpiryTimer = Timer(refreshDuration, _refreshToken);
    }
    
    _tokenValidationTimer = Timer.periodic(
      _tokenValidationInterval,
      (_) => validateToken(),
    );
  }

  Future<void> _refreshToken() async {
    if (_user == null) return;
    
    try {
      if (kDebugMode) print('🔄 Refreshing token...');
      
      final response = await _apiService.refreshToken();
      
      if (response.isSuccess && response.data != null) {
        _user = _user!.copyWith(token: response.data);
        await _saveUserData();
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
    
    if (now.add(_tokenRefreshBuffer).isAfter(expiryTime)) {
      if (kDebugMode) print('⏰ Token expiring soon - attempting refresh');
      await _refreshToken();
      return;
    }
    
    if (expiryTime.isBefore(now)) {
      if (kDebugMode) print('❌ Token expired');
      await _handleTokenExpiry();
    } else {
      final remaining = expiryTime.difference(now);
      if (kDebugMode) print('✅ Token valid - ${remaining.inMinutes} min remaining');
    }
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    
    try {
      final token = _prefs.getString('auth_token');
      if (token != null) {
        final tokenExpiry = _prefs.getInt('token_expiry');
        if (tokenExpiry != null) {
          final expiryTime = DateTime.fromMillisecondsSinceEpoch(tokenExpiry);
          
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
      await _signOutFromGoogle();
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
      if (kIsWeb) {
        if (kDebugMode) print('⚠️ FCM not supported on web, skipping');
        return;
      }

      final notificationService = NotificationService();
      final fcmToken = notificationService.fcmToken;
      
      if (fcmToken != null) {
        await _apiService.updateFCMToken(
          fcmToken: fcmToken,
          deviceId: 'default',
          platform: _getPlatform(),
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