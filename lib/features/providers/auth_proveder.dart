import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
  
  // ✅ FIXED: Configure Google Sign-In with proper client IDs
  late final GoogleSignIn _googleSignIn;
  
  // Add your mobile client IDs here
  static const String _androidClientId = '130218217091-1fl1m5mplj0rqmv4mjl3f5blncbi66u8.apps.googleusercontent.com';
  static const String _iosClientId = '130218217091-5e9j8a43lnhcuo6fai5dlne5e5fprq86.apps.googleusercontent.com'; // Add if you have iOS
  static const String _webClientId = '130218217091-ta95bq5pq3b38aqdlr158m6q6umug720.apps.googleusercontent.com';

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

  AuthProvider(this._prefs) {
    _initializeGoogleSignIn();
  }

  void _initializeGoogleSignIn() {
    String? clientId;
    
    if (kIsWeb) {
      clientId = _webClientId;
    } else if (Platform.isAndroid) {
      clientId = _androidClientId;
    } else if (Platform.isIOS) {
      clientId = _iosClientId;
    }

   
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ],
      clientId: clientId,
      // ✅ CRITICAL: For Android, also add this
      serverClientId: kIsWeb ? null : _webClientId,
    );
  }

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

  // CRITICAL FIX: Updated signInWithGoogle method in AuthProvider

Future<bool> signInWithGoogle() async {
  _setSocialLoading(true);
  _setError(null);

  try {
 

    // Sign out first to ensure clean state
    try {
      await _googleSignIn.signOut();
    } catch (e) {
    }

    // Trigger Google Sign-In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      _setSocialLoading(false);
      return false;
    }

  

    // Get authentication details
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    

    // ✅ CRITICAL FIX: Handle both web and mobile flows properly
    String? idToken = googleAuth.idToken;
    String? accessToken = googleAuth.accessToken;

    // Check if we have either token
    if (idToken == null && accessToken == null) {
      _setError('Failed to get Google credentials');
      _setSocialLoading(false);
      return false;
    }

    // ✅ FIX: Use web flow for both web AND when ID token is missing
    if (kIsWeb || (idToken == null && accessToken != null)) {
     
      try {
        // Get user info from Google using access token
        final userInfoResponse = await http.get(
          Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'),
          headers: {
            'Authorization': 'Bearer ${accessToken!}',
          },
        );

        if (userInfoResponse.statusCode == 200) {
          final userInfo = json.decode(userInfoResponse.body);
          
        

          // Send user info directly to backend
          final response = await _apiService.googleSignInWeb(
            email: userInfo['email'],
            firstName: userInfo['given_name'] ?? userInfo['name']?.split(' ').first ?? 'User',
            lastName: userInfo['family_name'] ?? userInfo['name']?.split(' ').last ?? '',
            googleId: userInfo['id'],
            accessToken: accessToken,
          );

          if (response.isSuccess && response.data != null) {
            _user = response.data!;
            await _saveUserData();
            _setupTokenExpiryTimer();
            await _registerFCMToken();

          
            
            _setSocialLoading(false);
            return true;
          } else {
            _setError(response.error ?? 'Google sign-in failed on server');
            _setSocialLoading(false);
            return false;
          }
        } else {
          throw Exception('Failed to get user info: ${userInfoResponse.statusCode}');
        }
      } catch (e) {
        _setError('Failed to get user information from Google');
        _setSocialLoading(false);
        return false;
      }
    }

    // Mobile flow with ID token (only if we have ID token)
    
    final response = await _apiService.googleSignIn(idToken!);

    if (response.isSuccess && response.data != null) {
      _user = response.data!;
      await _saveUserData();
      _setupTokenExpiryTimer();
      await _registerFCMToken();

     
      
      _setSocialLoading(false);
      return true;
    } else {
      _setError(response.error ?? 'Google sign-in failed on server');
      _setSocialLoading(false);
      return false;
    }
  } catch (e, stackTrace) {
   
    
    String errorMessage = 'Google sign-in error occurred';
    if (e.toString().contains('SIGN_IN_REQUIRED')) {
      errorMessage = 'Please try signing in again';
    } else if (e.toString().contains('network')) {
      errorMessage = 'Network error. Please check your connection';
    } else if (e.toString().contains('PERMISSION_DENIED')) {
      errorMessage = 'Please enable People API in Google Cloud Console';
    } else if (e.toString().contains('PlatformException')) {
      errorMessage = 'Google Sign-In not properly configured. Check your Google Cloud Console setup.';
    }
    
    _setError(errorMessage);
    _setSocialLoading(false);
    return false;
  }
}
  Future<void> _signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
    }
  }

  // Token management methods
  void _setupTokenExpiryTimer() {
    _tokenExpiryTimer?.cancel();
    _tokenValidationTimer?.cancel();
    
    final tokenExpiry = _prefs.getInt('token_expiry');
    if (tokenExpiry == null) {
      return;
    }

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(tokenExpiry);
    final now = DateTime.now();
   
    
    if (expiryTime.isBefore(now)) {
      _handleTokenExpiry();
      return;
    }
    
    final duration = expiryTime.difference(now);
    final refreshDuration = duration - _tokenRefreshBuffer;
    
    
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
      
      final response = await _apiService.refreshToken();
      
      if (response.isSuccess && response.data != null) {
        _user = _user!.copyWith(token: response.data);
        await _saveUserData();
        _setupTokenExpiryTimer();
        
      } else {
        await _handleTokenExpiry();
      }
    } catch (e) {
      await _handleTokenExpiry();
    }
  }

  Future<void> _handleTokenExpiry() async {
    
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
      return;
    }

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(tokenExpiry);
    final now = DateTime.now();
   
    
    if (now.add(_tokenRefreshBuffer).isAfter(expiryTime)) {
      await _refreshToken();
      return;
    }
    
    if (expiryTime.isBefore(now)) {
      await _handleTokenExpiry();
    } else {
      final remaining = expiryTime.difference(now);
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
          
          _setupTokenExpiryTimer();
        }
      }
    } catch (e) {
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
      
    } catch (e) {
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
    
  }

  void clearError() => _setError(null);
  void clearVerificationState() => _setRequiresVerification(false);
  void clearResetToken() => _resetToken = null;
}