class ApiConstants {
  // Base URL - Replace with your actual API URL
  static const String baseUrl = 'https://soleybackend.vercel.app/api/v1';
  // For production: static const String baseUrl = 'https://your-api-domain.com/api/v1';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
    static const String changePassword = '/auth/change-password';
  static const String verifyOTP = '/auth/verify-otp';
  static const String resendOTP = '/auth/resend-otp';
  static const String resendResetOTP='/auth/resend-reset-otp';
  static const String verifyResetOTP='/auth/verify-reset-otp';
  static const String resendVerification = '/auth/resend-verification';
  static const String verifyEmail = '/auth/verify-email';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
   static const String verifyRegistration = '/auth/verify-registration';
  static const String resendRegistrationOTP = '/auth/resend-registration-otp';
  
  // User endpoints
  static const String profile = '/auth/profile';
  static const String updateProfile = '/user/profile';
  static const String addresses = '/user/addresses';
  
  // Food categories
  static const String categories = '/categories';
  
  // Food items
  static const String foodItems = '/food-items';
  static const String featuredItems = '/food-items/featured';
  static const String popularItems = '/food-items/popular';
  
  // Cart endpoints (if stored on server)
  static const String cart = '/cart';
  static const String addToCart = '/cart/add';
  static const String updateCart = '/cart/update';
  static const String removeFromCart = '/cart/remove';
  static const String clearCart = '/cart/clear';
  
  // Order endpoints
  static const String orders = '/orders';
  static const String orderHistory = '/orders/history';
  static const String orderStatus = '/orders/status';
  
  // Payment endpoints
  static const String payment = '/payment';
  static const String paymentMethods = '/payment/methods';
  static const String processPayment = '/payment/process';
  
  // Location endpoints
  static const String branches = '/branches';
  static const String deliveryZones = '/delivery-zones';
  
  // Miscellaneous
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  
  // File upload
  static const String uploadImage = '/upload/image';
  
  // WebSocket endpoints (if using real-time features)
  static const String socketUrl = 'ws://localhost:3000';
  // For production: static const String socketUrl = 'wss://your-api-domain.com';
  
  // Request timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}