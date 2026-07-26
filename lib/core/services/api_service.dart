import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:Saborly/shared/models/app_settings.dart';
import 'package:Saborly/shared/models/user.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Saborly/core/constant/api_constants.dart';
import 'package:Saborly/core/services/notification_service.dart';
import 'package:Saborly/shared/models/order.dart';
import '../../shared/models/food_item.dart';
import '../../shared/models/food_category.dart';

// Cache entry class
class _CachedResponse {
  final dynamic data;
  final DateTime timestamp;
  static const Duration cacheTTL = Duration(minutes: 5);

  _CachedResponse(this.data, this.timestamp);

  bool get isExpired => DateTime.now().difference(timestamp) > cacheTTL;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  String? _authToken;
  String? _branchId;
  String _currentLanguage = 'es'; // Default language
  Dio get dio => _dio;

  String? get branchId => _branchId;

  Future<void> loadBranchFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _branchId = prefs.getString('branch_id');
  }

  Future<void> setBranchId(String id) async {
    _branchId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('branch_id', id);
    clearCache();
  }

  Future<void> clearBranchId() async {
    _branchId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('branch_id');
    clearCache();
  }

  // Response cache for GET requests (5 minutes TTL)
  final Map<String, _CachedResponse> _responseCache = {};

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      // Optimized timeouts - reduced for faster failure detection
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      // Enable HTTP keep-alive for connection reuse
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Language': _currentLanguage,
        // NOTE: Do NOT set 'Connection' header — it is a forbidden browser
        // header. Browsers (XMLHttpRequest / Fetch) silently reject it and
        // flood the console with "Refused to set unsafe header" errors which
        // break all API calls on Flutter Web.
      },
      // persistentConnection is a dart:io / mobile-only feature; omit it on
      // web to avoid Dio trying to set Connection: keep-alive internally.
      // Follow redirects
      followRedirects: true,
      maxRedirects: 3,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
          // Update last activity timestamp for authenticated requests
          _updateLastActivity();
        }

        if (_branchId != null && _branchId!.isNotEmpty) {
          options.headers['X-Branch-Id'] = _branchId;
        }

        // ✅ CRITICAL: Always include current language in BOTH header and query
        options.headers['X-Language'] = _currentLanguage;
        options.queryParameters['lang'] = _currentLanguage;

        // Check cache for GET requests (except auth endpoints)
        if (options.method == 'GET' && !options.path.contains('/auth/')) {
          final cacheKey = _getCacheKey(options);
          final cached = _responseCache[cacheKey];
          if (cached != null && !cached.isExpired) {
            // Return cached response
            return handler.resolve(Response(
              data: cached.data,
              statusCode: 200,
              requestOptions: options,
            ));
          }
        }

        handler.next(options);
      },
      onResponse: (response, handler) {
        // Cache successful GET responses (except auth endpoints)
        if (response.requestOptions.method == 'GET' &&
            response.statusCode == 200 &&
            !response.requestOptions.path.contains('/auth/')) {
          final cacheKey = _getCacheKey(response.requestOptions);
          _responseCache[cacheKey] = _CachedResponse(
            response.data,
            DateTime.now(),
          );
          // Limit cache size (keep last 50 entries)
          if (_responseCache.length > 50) {
            final oldestKey = _responseCache.entries
                .reduce((a, b) =>
                    a.value.timestamp.isBefore(b.value.timestamp) ? a : b)
                .key;
            _responseCache.remove(oldestKey);
          }
        }
        handler.next(response);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  /// ✅ CRITICAL: Set language and update default headers
  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    // Update the default headers
    _dio.options.headers['X-Language'] = languageCode;
  }

  String getCurrentLanguage() {
    return _currentLanguage;
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  String? getAuthToken() {
    return _authToken;
  }

  // Throttle activity updates - only update once per minute
  DateTime? _lastActivityUpdate;
  static const Duration _activityUpdateThrottle = Duration(minutes: 1);

  // Generate cache key from request options
  String _getCacheKey(RequestOptions options) {
    final queryParams = options.queryParameters.toString();
    return '${options.method}:${options.path}:$queryParams:${_branchId ?? ''}';
  }

  // Clear cache (useful after login/logout)
  void clearCache() {
    _responseCache.clear();
  }

  // Update last activity timestamp (throttled - only updates once per minute)
  void _updateLastActivity() {
    final now = DateTime.now();
    // Only update if more than 1 minute has passed since last update
    if (_lastActivityUpdate == null ||
        now.difference(_lastActivityUpdate!) > _activityUpdateThrottle) {
      _lastActivityUpdate = now;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setInt('last_activity', now.millisecondsSinceEpoch);
      }).catchError((error) {
        // Silently fail if we can't update activity
      });
    }
  } // Add this to your lib/core/services/api_service.dart

  /// Refresh authentication token
  Future<ApiResponse<String>> refreshToken() async {
    try {
      if (_authToken == null) {
        return ApiResponse.error('No token available for refresh');
      }

      final response = await _dio.post(
        ApiConstants.refreshToken,
        // Auth token is already in header via interceptor
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'];

        if (newToken != null && newToken.isNotEmpty) {
          setAuthToken(newToken);

          return ApiResponse.success(newToken, statusCode: response.statusCode);
        }

        return ApiResponse.error('No token in response',
            statusCode: response.statusCode);
      }

      return ApiResponse.error(
        response.data['message'] ?? 'Token refresh failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return ApiResponse.error('Token invalid - login required',
            statusCode: 401);
      }

      return ApiResponse.error(
        _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error during refresh: $e');
    }
  }

  /// ✅ FIXED: Get categories with current language
  Future<ApiResponse<List<FoodCategory>>> getCategories() async {
    try {
      final response = await _dio.get(
        ApiConstants.categories,
        queryParameters: {
          'lang': _currentLanguage, // Explicit language parameter
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['categories'] ?? [];

        // ✅ Parse with current language
        final categories = data
            .map((json) =>
                FoodCategory.fromMap(json, currentLanguage: _currentLanguage))
            .toList();

        return ApiResponse.success(categories, statusCode: response.statusCode);
      }
      return ApiResponse.error('Failed to fetch categories',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e),
          statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  /// ✅ FIXED: Get food items with current language
  // Add this to your ApiService.getFoodItems() to debug

  Future<ApiResponse<AppSettings>> getPublicSettings() async {
    try {
      final response = await _dio.get('/settings/public');

      if (response.statusCode == 200) {
        final settings = AppSettings.fromMap(response.data['settings']);
        return ApiResponse.success(settings, statusCode: response.statusCode);
      }
      return ApiResponse.error('Failed to fetch settings',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e),
          statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

// Add this method to your ApiService class (api_service.dart)

  /// Google Sign-In
  Future<ApiResponse<User>> googleSignIn(String idToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.googleSignIn, // Add this to ApiConstants
        data: {
          'idToken': idToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = response.data['user'];
        final token = response.data['token'];

        final user = User(
          id: userData['id'].toString(),
          firstName: userData['firstName'],
          lastName: userData['lastName'],
          email: userData['email'],
          phone: userData['phone'] ?? '',
          token: token,
        );

        setAuthToken(token);

        return ApiResponse.success(user, statusCode: response.statusCode);
      }
      return ApiResponse.error('Google sign-in failed',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e),
          statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<User>> googleSignInWeb({
    required String email,
    required String firstName,
    required String lastName,
    required String googleId,
    required String accessToken,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.googleSignInWeb,
        data: {
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'googleId': googleId,
          'accessToken': accessToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = response.data['user'];
        final token = response.data['token'];

        final user = User(
          id: userData['id'].toString(),
          firstName: userData['firstName'],
          lastName: userData['lastName'],
          email: userData['email'],
          phone: userData['phone'] ?? '',
          token: token,
        );

        setAuthToken(token);

        return ApiResponse.success(user, statusCode: response.statusCode);
      }
      return ApiResponse.error('Google sign-in failed',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e),
          statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred: $e');
    }
  }

  Future<String> getDeviceId() async {
    if (kIsWeb) return 'unknown_web';
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios';
      }
    } catch (_) {}
    return 'unknown_device';
  }

  /// Apple Sign-In
  Future<ApiResponse<User>> appleSignIn({
    required String identityToken,
    required String authorizationCode,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final notificationService = NotificationService();
    final fcmToken = notificationService.fcmToken;
    final deviceId = await getDeviceId();

    try {
      final response = await _dio.post(ApiConstants.appleSignIn, data: {
        'identityToken': identityToken,
        'firstName': firstName ?? 'firstname',
        'lastName': lastName ?? '',
        'fcmToken': fcmToken,
        'deviceId': deviceId,
        'platform': Platform.isIOS ? 'ios' : 'android',
        if (email != null) 'email': email,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = response.data['user'];
        final token = response.data['token'];

        final user = User(
          id: userData['id'].toString(),
          firstName: userData['firstName'],
          lastName: userData['lastName'],
          email: userData['email'],
          phone: userData['phone'] ?? '',
          token: token,
        );

        setAuthToken(token);

        return ApiResponse.success(user, statusCode: response.statusCode);
      }
      return ApiResponse.error('Apple sign-in failed',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e),
          statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<List<FoodItem>>> getFoodItems({
    String? categoryId,
    bool? featured,
    bool? popular,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'lang': _currentLanguage,
        'includeOffers': true, // ✅ CRITICAL: Request offers to be included
      };

      if (categoryId != null) queryParams['category'] = categoryId;
      if (featured != null) queryParams['featured'] = featured;
      if (popular != null) queryParams['popular'] = popular;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        ApiConstants.foodItems,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? [];

        final items = data
            .map((json) =>
                FoodItem.fromMap(json, currentLanguage: _currentLanguage))
            .toList();

        return ApiResponse.success(items, statusCode: response.statusCode);
      }
      return ApiResponse.error('Failed to fetch food items',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e),
          statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<FoodItem>> getFoodItem(String id) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.foodItems}/$id',
        queryParameters: {
          'lang': _currentLanguage,
          'includeOffers': true, // ✅ Include offers for single item too
        },
      );

      if (response.statusCode == 200) {
        final itemData = response.data['item'];

        final item = FoodItem.fromMap(
          itemData,
          currentLanguage: _currentLanguage,
        );

        return ApiResponse.success(item, statusCode: response.statusCode);
      }
      return ApiResponse.error('Failed to fetch food item',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e),
          statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  // Auth endpoints
  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final token = response.data['token'];

        final user = User(
          id: userData['id'].toString(),
          firstName: userData['firstName'],
          lastName: userData['lastName'],
          email: userData['email'],
          phone: userData['phone'],
          token: token,
        );

        setAuthToken(token);

        return ApiResponse.success(user, statusCode: response.statusCode);
      }
      return ApiResponse.error('Login failed', statusCode: response.statusCode);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return ApiResponse.error(
          e.response?.data['message'] ?? 'Please verify your email',
          statusCode: 403,
        );
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  // Updated register method
  Future<ApiResponse<User>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;

        final requiresVerification =
            responseData['requiresVerification'] ?? false;

        if (requiresVerification) {
          return ApiResponse.success(
            null,
            rawData: responseData,
            statusCode: response.statusCode,
          );
        } else {
          final userData = responseData['user'];
          final token = responseData['token'];

          final user = User(
            id: userData['id'].toString(),
            firstName: userData['firstName'],
            lastName: userData['lastName'],
            email: userData['email'],
            phone: userData['phone'],
            token: token,
          );

          setAuthToken(token);

          return ApiResponse.success(
            user,
            rawData: responseData,
            statusCode: response.statusCode,
          );
        }
      }
      return ApiResponse.error(
        'Registration failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<User>> verifyOTP(String email, String otp) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyRegistration, // Changed from verifyOTP
        data: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final userData = response.data['user'];
        final token = response.data['token'];

        final user = User(
          id: userData['id'].toString(),
          firstName: userData['firstName'],
          lastName: userData['lastName'],
          email: userData['email'],
          phone: userData['phone'],
          token: token,
        );

        setAuthToken(token);

        return ApiResponse.success(user, statusCode: response.statusCode);
      }
      return ApiResponse.error(
        response.data['message'] ?? 'OTP verification failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        return ApiResponse.error(
          e.response!.data['message'],
          statusCode: e.response?.statusCode,
        );
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

// Resend registration OTP
  Future<ApiResponse<void>> resendOTP(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.resendRegistrationOTP, // Changed from resendOTP
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null, statusCode: response.statusCode);
      }
      return ApiResponse.error(
        response.data['message'] ?? 'Failed to send OTP',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        return ApiResponse.error(
          e.response!.data['message'],
          statusCode: e.response?.statusCode,
        );
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

// Password reset - Request OTP
  Future<ApiResponse<void>> requestPasswordReset(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        response.data?['message'] ?? 'Failed to send reset code',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

// Password reset - Verify OTP
  Future<ApiResponse<String>> verifyResetOTP(String email, String otp) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyResetOTP,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        final resetToken = response.data['resetToken'];
        return ApiResponse.success(resetToken, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        response.data['message'] ?? 'Invalid or expired OTP',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        return ApiResponse.error(
          e.response!.data['message'],
          statusCode: e.response?.statusCode,
        );
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

// Password reset - Reset with verified OTP
  Future<ApiResponse<User>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.resetPassword,
        data: {
          'email': email,
          'resetToken': resetToken,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final token = response.data['token'];

        final user = User(
          id: userData['id'].toString(),
          firstName: userData['firstName'],
          lastName: userData['lastName'],
          email: userData['email'],
          phone: userData['phone'],
          token: token,
        );

        setAuthToken(token);

        return ApiResponse.success(user, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        response.data['message'] ?? 'Failed to reset password',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        return ApiResponse.error(
          e.response!.data['message'],
          statusCode: e.response?.statusCode,
        );
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

// Password reset - Resend OTP
  Future<ApiResponse<void>> resendResetOTP(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.resendResetOTP,
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        response.data['message'] ?? 'Failed to send OTP',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        return ApiResponse.error(
          e.response!.data['message'],
          statusCode: e.response?.statusCode,
        );
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  // Update other methods to use new ApiResponse constructors
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _dio.post(ApiConstants.logout);
      clearAuthToken();
      return ApiResponse.success(null, statusCode: response.statusCode);
    } on DioException catch (e) {
      clearAuthToken();
      return ApiResponse.error(_handleDioError(e),
          statusCode: e.response?.statusCode);
    } catch (e) {
      clearAuthToken();
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<void>> deleteAccount() async {
    try {
      final response = await _dio.delete(ApiConstants.deleteAccount);
      clearAuthToken();
      return ApiResponse.success(null, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data?['message'] ?? _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        if (token != null) {
          setAuthToken(token);
        }
        return ApiResponse.success(response.data,
            statusCode: response.statusCode);
      }

      return ApiResponse.error(
        response.data['message'] ?? 'Failed to change password',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e),
          statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<Order>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post(
        ApiConstants.orders,
        data: orderData,
      );

      if (response.statusCode == 201 && response.data['order'] != null) {
        final order = Order.fromMap(response.data['order']);
        return ApiResponse.success(
          order,
          statusCode: response.statusCode,
          rawData: {
            'firstOrderDiscountApplied': response.data['firstOrderDiscountApplied'] ?? false,
            'discountAmount': response.data['discountAmount'],
          },
        );
      }
      return ApiResponse.error('Failed to create order: Invalid response',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      if (e.response != null) {
        return ApiResponse.error(
          'Failed to create order: ${e.response?.data['message'] ?? e.message}',
          statusCode: e.response?.statusCode,
        );
      }
      return ApiResponse.error('Network error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred: $e');
    }
  }

  /// Check whether the current mobile user is eligible for the first-order 20% discount.
  Future<Map<String, dynamic>> checkFirstOrderDiscount(String deviceId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.orders}/first-order-discount/check',
        queryParameters: {'deviceId': deviceId},
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      return {'eligible': false};
    } catch (_) {
      return {'eligible': false};
    }
  }

  Future<ApiResponse<List<Order>>> getOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.orders,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['orders'] ?? [];
        final orders = data.map((json) => Order.fromMap(json)).toList();
        return ApiResponse.success(orders, statusCode: response.statusCode);
      }
      return ApiResponse.error('Failed to fetch orders',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e),
          statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<Order>> getOrder(String id) async {
    try {
      // Add timestamp to prevent caching
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final url = '${ApiConstants.orders}/$id?_t=$timestamp';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        if (response.data == null || response.data['order'] == null) {
          return ApiResponse.error('No order found in response',
              statusCode: response.statusCode);
        }
        // Log raw API response for debugging
        print(
            '📡 API Response - Raw status: ${response.data['order']['status']}, UpdatedAt: ${response.data['order']['updatedAt']}');
        final order = Order.fromMap(response.data['order']);
        print(
            '📡 API Response - Parsed status: ${order.status}, UpdatedAt: ${order.updatedAt}');
        return ApiResponse.success(order, statusCode: response.statusCode);
      }
      final errorMessage = response.data?['message'] ?? 'Unknown error';
      return ApiResponse.error(
        'Failed to fetch order: ${response.statusCode} - $errorMessage',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Error fetching order: $e');
    }
  }
// Add these methods to your ApiService class

// Future<ApiResponse<void>> requestPasswordReset(String email) async {
//   try {
//     final response = await _dio.post(
//       ApiConstants.forgotPassword,
//       data: {
//         'email': email,
//       },
//     );

//     if (response.statusCode == 200) {
//       return ApiResponse.success(null, statusCode: response.statusCode);
//     }

//     return ApiResponse.error(
//       response.data?['message'] ?? 'Failed to send reset code',
//       statusCode: response.statusCode,
//     );
//   } on DioException catch (e) {
//     return ApiResponse.error(
//       _handleDioError(e),
//       statusCode: e.response?.statusCode,
//     );
//   } catch (e) {
//     ('Request password reset error: $e');
//     return ApiResponse.error('Unexpected error occurred');
//   }
// }

// Future<ApiResponse<String>> verifyResetOTP(String email, String otp) async {
//   try {
//     final response = await _dio.post(
//       ApiConstants.verifyResetOTP,
//       data: {
//         'email': email,
//         'otp': otp,
//       },
//     );

//     if (response.statusCode == 200) {
//       final resetToken = response.data['resetToken'];
//       return ApiResponse.success(resetToken, statusCode: response.statusCode);
//     }

//     return ApiResponse.error(
//       response.data['message'] ?? 'Invalid or expired OTP',
//       statusCode: response.statusCode,
//     );
//   } on DioException catch (e) {
//     if (e.response?.data != null && e.response!.data['message'] != null) {
//       return ApiResponse.error(
//         e.response!.data['message'],
//         statusCode: e.response?.statusCode,
//       );
//     }
//     return ApiResponse.error(_handleDioError(e));
//   } catch (e) {
//     debugPrint('Verify reset OTP error: $e');
//     return ApiResponse.error('Unexpected error occurred');
//   }
// }

// Future<ApiResponse<User>> resetPassword({
//   required String email,
//   required String resetToken,
//   required String newPassword,
//   required String confirmPassword,
// }) async {
//   try {
//     final response = await _dio.post(
//       ApiConstants.resetPassword,
//       data: {
//         'email': email,
//         'resetToken': resetToken,
//         'newPassword': newPassword,
//         'confirmPassword': confirmPassword,
//       },
//     );

//     if (response.statusCode == 200) {
//       final userData = response.data['user'];
//       final token = response.data['token'];

//       final user = User(
//         id: userData['id'].toString(),
//         firstName: userData['firstName'],
//         lastName: userData['lastName'],
//         email: userData['email'],
//         phone: userData['phone'],
//         token: token,
//       );

//       setAuthToken(token);

//       return ApiResponse.success(user, statusCode: response.statusCode);
//     }

//     return ApiResponse.error(
//       response.data['message'] ?? 'Failed to reset password',
//       statusCode: response.statusCode,
//     );
//   } on DioException catch (e) {
//     if (e.response?.data != null && e.response!.data['message'] != null) {
//       return ApiResponse.error(
//         e.response!.data['message'],
//         statusCode: e.response?.statusCode,
//       );
//     }
//     return ApiResponse.error(_handleDioError(e));
//   } catch (e) {
//     debugPrint('Reset password error: $e');
//     return ApiResponse.error('Unexpected error occurred');
//   }
// }

// Future<ApiResponse<void>> resendResetOTP(String email) async {
//   try {
//     final response = await _dio.post(
//       ApiConstants.resendResetOTP,
//       data: {
//         'email': email,
//       },
//     );

//     if (response.statusCode == 200) {
//       return ApiResponse.success(null, statusCode: response.statusCode);
//     }

//     return ApiResponse.error(
//       response.data['message'] ?? 'Failed to send OTP',
//       statusCode: response.statusCode,
//     );
//   } on DioException catch (e) {
//     if (e.response?.data != null && e.response!.data['message'] != null) {
//       return ApiResponse.error(
//         e.response!.data['message'],
//         statusCode: e.response?.statusCode,
//       );
//     }
//     return ApiResponse.error(_handleDioError(e));
//   } catch (e) {
//     debugPrint('Resend reset OTP error: $e');
//     return ApiResponse.error('Unexpected error occurred');
//   }
// }

  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.patch(
        ApiConstants.profile,
        data: userData,
      );
      if (response.statusCode == 200) {
        final user = User.fromMap(response.data['user']);
        return ApiResponse.success(user, statusCode: response.statusCode);
      }
      return ApiResponse.error('Failed to update profile',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e),
          statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getPlaceDetails(
      String placeId) async {
    try {
      final response = await _dio.get(
        '/addresses/place-details',
        queryParameters: {
          'place_id': placeId,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        return ApiResponse.success(response.data['result']);
      }

      return ApiResponse.error(
        response.data['error_message'] ?? 'Failed to fetch place details',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e),
          statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  // Add this method to the ApiService class
  Future<ApiResponse<List<Map<String, dynamic>>>> getAddressAutocomplete(
      String input) async {
    try {
      final response = await _dio.get(
        '/addresses/autocomplete',
        queryParameters: {
          'input': input,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> predictions = response.data['predictions'] ?? [];
        return ApiResponse.success(predictions.cast<Map<String, dynamic>>());
      }

      return ApiResponse.error(
        response.data['message'] ?? 'Failed to fetch autocomplete suggestions',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e),
          statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<List<DeliveryAddress>>> getSavedAddresses() async {
    try {
      final response = await _dio.get('/addresses');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> addressesJson = response.data['data'];
        final addresses =
            addressesJson.map((json) => DeliveryAddress.fromMap(json)).toList();

        return ApiResponse.success(addresses);
      }

      return ApiResponse.error(
          response.data['message'] ?? 'Failed to load addresses');
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Error loading addresses: ${e.toString()}');
    }
  }

  /// Save a new address
  Future<ApiResponse<DeliveryAddress>> saveAddress(
      Map<String, dynamic> addressData) async {
    try {
      final response = await _dio.post(
        '/addresses',
        data: addressData,
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final address = DeliveryAddress.fromMap(response.data['data']);
        return ApiResponse.success(address);
      }

      return ApiResponse.error(
          response.data['message'] ?? 'Failed to save address');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return ApiResponse.error(
            e.response?.data['message'] ?? 'Invalid address data');
      }
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Error saving address: ${e.toString()}');
    }
  }

  /// Update an existing address
  Future<ApiResponse<DeliveryAddress>> updateAddress(
    String addressId,
    Map<String, dynamic> addressData,
  ) async {
    try {
      final response = await _dio.put(
        '/addresses/$addressId',
        data: addressData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final address = DeliveryAddress.fromMap(response.data['data']);
        return ApiResponse.success(address);
      }

      return ApiResponse.error(
          response.data['message'] ?? 'Failed to update address');
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Error updating address: ${e.toString()}');
    }
  }

  /// Delete an address
  Future<ApiResponse<void>> deleteAddress(String addressId) async {
    try {
      final response = await _dio.delete('/addresses/$addressId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(
          response.data['message'] ?? 'Failed to delete address');
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Error deleting address: ${e.toString()}');
    }
  }

  /// Set an address as default
  Future<ApiResponse<DeliveryAddress>> setDefaultAddress(
      String addressId) async {
    try {
      final response = await _dio.patch('/addresses/$addressId/default');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final address = DeliveryAddress.fromMap(response.data['data']);
        return ApiResponse.success(address);
      }

      return ApiResponse.error(
          response.data['message'] ?? 'Failed to set default address');
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(
          'Error setting default address: ${e.toString()}');
    }
  }

  /// Validate address coordinates
  Future<ApiResponse<Map<String, dynamic>>> validateAddress(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _dio.post(
        '/addresses/validate',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResponse.success(response.data['data']);
      }

      return ApiResponse.error(
          response.data['message'] ?? 'Address validation failed');
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Error validating address: ${e.toString()}');
    }
  }

// Add these methods to your ApiService class

  // FCM Token Management
  Future<ApiResponse<void>> updateFCMToken({
    required String fcmToken,
    String? deviceId,
    String? platform,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/fcm-token',
        data: {
          'fcmToken': fcmToken,
          'deviceId': deviceId ?? 'default',
          'platform': platform ?? (kIsWeb ? 'web' : 'mobile'),
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        response.data['message'] ?? 'Failed to update FCM token',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<void>> removeFCMToken({String? deviceId}) async {
    try {
      final response = await _dio.delete(
        '/auth/fcm-token',
        data: {
          'deviceId': deviceId ?? 'default',
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        response.data['message'] ?? 'Failed to remove FCM token',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<void>> testNotification() async {
    try {
      final response = await _dio.post('/auth/test-notification');

      if (response.statusCode == 200) {
        return ApiResponse.success(null, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        response.data['message'] ?? 'Failed to send test notification',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        if (error.response?.data != null) {
          final message = error.response!.data['message'];
          if (message != null) return message;
        }
        return 'Server error occurred (${error.response?.statusCode})';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.unknown:
        return 'Network error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred';
    }
  }
}

class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;
  final int? statusCode;
  final Map<String, dynamic>? rawData;

  ApiResponse.success(this.data, {this.rawData, this.statusCode})
      : error = null,
        isSuccess = true;

  ApiResponse.error(this.error, {this.statusCode})
      : data = null,
        rawData = null,
        isSuccess = false;
}
