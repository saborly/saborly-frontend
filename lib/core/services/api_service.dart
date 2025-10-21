import 'dart:io';
import 'package:Saborly/shared/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:Saborly/core/constant/api_constants.dart';
import 'package:Saborly/shared/models/order.dart';
import '../../shared/models/food_item.dart';
import '../../shared/models/food_category.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  String? _authToken;
  String _currentLanguage = 'es'; // Default language


  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Language': _currentLanguage,
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        
        // ✅ CRITICAL: Always include current language in BOTH header and query
        options.headers['X-Language'] = _currentLanguage;
        options.queryParameters['lang'] = _currentLanguage;
        
     
        handler.next(options);
      },
      onResponse: (response, handler) {
       
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
  }// Add this to your lib/core/services/api_service.dart

/// Refresh authentication token
Future<ApiResponse<String>> refreshToken() async {
  try {
    if (_authToken == null) {
      return ApiResponse.error('No token available for refresh');
    }

    if (kDebugMode) print('🔄 Calling refresh-token endpoint...');

    final response = await _dio.post(
      ApiConstants.refreshToken,
      // Auth token is already in header via interceptor
    );

    if (response.statusCode == 200) {
      final newToken = response.data['token'];
      
      if (newToken != null && newToken.isNotEmpty) {
        setAuthToken(newToken);
        
        if (kDebugMode) {
          print('✅ Token refreshed - new token received');
        }
        
        return ApiResponse.success(newToken, statusCode: response.statusCode);
      }
      
      return ApiResponse.error('No token in response', statusCode: response.statusCode);
    }

    return ApiResponse.error(
      response.data['message'] ?? 'Token refresh failed',
      statusCode: response.statusCode,
    );
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      if (kDebugMode) print('❌ Token invalid - user needs to login');
      return ApiResponse.error('Token invalid - login required', statusCode: 401);
    }
    
    if (kDebugMode) print('❌ Refresh error: ${e.message}');
    
    return ApiResponse.error(
      _handleDioError(e),
      statusCode: e.response?.statusCode,
    );
  } catch (e) {
    if (kDebugMode) print('❌ Unexpected refresh error: $e');
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
            .map((json) => FoodCategory.fromMap(json, currentLanguage: _currentLanguage))
            .toList();
        
     
        
        return ApiResponse.success(categories, statusCode: response.statusCode);
      }
      return ApiResponse.error('Failed to fetch categories', statusCode: response.statusCode);
    } on DioException catch (e) {
   
      return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
    } catch (e) {
     
      return ApiResponse.error('Unexpected error occurred');
    }
  }
  
  /// ✅ FIXED: Get food items with current language
 // Add this to your ApiService.getFoodItems() to debug

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
          .map((json) => FoodItem.fromMap(json, currentLanguage: _currentLanguage))
          .toList();
      
    
      
      return ApiResponse.success(items, statusCode: response.statusCode);
    }
    return ApiResponse.error('Failed to fetch food items', statusCode: response.statusCode);
  } on DioException catch (e) {
  
    return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
  } catch (e) {
   
    return ApiResponse.error('Unexpected error occurred: $e');
  }
}
  /// ✅ FIXED: Get single food item with current language
  Future<ApiResponse<FoodItem>> getFoodItem(String id) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.foodItems}/$id',
        queryParameters: {
          'lang': _currentLanguage,
        },
      );

      if (response.statusCode == 200) {
        final item = FoodItem.fromMap(
          response.data['item'],
          currentLanguage: _currentLanguage,
        );
        return ApiResponse.success(item, statusCode: response.statusCode);
      }
      return ApiResponse.error('Failed to fetch food item', statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
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

        final requiresVerification = responseData['requiresVerification'] ?? false;

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
      return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
    } catch (e) {
      clearAuthToken();
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
        return ApiResponse.success(response.data, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        response.data['message'] ?? 'Failed to change password',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
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
        return ApiResponse.success(order, statusCode: response.statusCode);
      }
      return ApiResponse.error('Failed to create order: Invalid response', statusCode: response.statusCode);
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
      return ApiResponse.error('Failed to fetch orders', statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<Order>> getOrder(String id) async {
    try {
      final url = '${ApiConstants.orders}/$id';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        if (response.data == null || response.data['order'] == null) {
          return ApiResponse.error('No order found in response', statusCode: response.statusCode);
        }
        final order = Order.fromMap(response.data['order']);
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
//     debugPrint('Request password reset error: $e');
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
      return ApiResponse.error('Failed to update profile', statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }
Future<ApiResponse<Map<String, dynamic>>> getPlaceDetails(String placeId) async {
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
    return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
  } catch (e) {
    return ApiResponse.error('Unexpected error occurred');
  }
}
  // Add this method to the ApiService class
Future<ApiResponse<List<Map<String, dynamic>>>> getAddressAutocomplete(String input) async {
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
    return ApiResponse.error(_handleDioError(e), statusCode: e.response?.statusCode);
  } catch (e) {
    return ApiResponse.error('Unexpected error occurred');
  }
} Future<ApiResponse<List<DeliveryAddress>>> getSavedAddresses() async {
    try {
      final response = await _dio.get('/addresses');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> addressesJson = response.data['data'];
        final addresses = addressesJson
            .map((json) => DeliveryAddress.fromMap(json))
            .toList();
        
        return ApiResponse.success(addresses);
      }
      
      return ApiResponse.error(
        response.data['message'] ?? 'Failed to load addresses'
      );
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Error loading addresses: ${e.toString()}');
    }
  }

  /// Save a new address
  Future<ApiResponse<DeliveryAddress>> saveAddress(Map<String, dynamic> addressData) async {
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
        response.data['message'] ?? 'Failed to save address'
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return ApiResponse.error(
          e.response?.data['message'] ?? 'Invalid address data'
        );
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
        response.data['message'] ?? 'Failed to update address'
      );
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
        response.data['message'] ?? 'Failed to delete address'
      );
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Error deleting address: ${e.toString()}');
    }
  }

  /// Set an address as default
  Future<ApiResponse<DeliveryAddress>> setDefaultAddress(String addressId) async {
    try {
      final response = await _dio.patch('/addresses/$addressId/default');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final address = DeliveryAddress.fromMap(response.data['data']);
        return ApiResponse.success(address);
      }
      
      return ApiResponse.error(
        response.data['message'] ?? 'Failed to set default address'
      );
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Error setting default address: ${e.toString()}');
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
        response.data['message'] ?? 'Address validation failed'
      );
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
          'platform': platform ?? Platform.operatingSystem,
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