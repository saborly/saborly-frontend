class AppConstants {
  // Storage Keys
  static const String userBox = 'user_box';
  static const String cartBox = 'cart_box';
  static const String settingsBox = 'settings_box';
  
  // Hive Keys
  static const String userKey = 'user';
  static const String isLoggedInKey = 'is_logged_in';
  static const String cartItemsKey = 'cart_items';
  static const String selectedAddressKey = 'selected_address';
  static const String themeKey = 'theme';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String menuEndpoint = '/menu';
  static const String ordersEndpoint = '/orders';
  static const String categoriesEndpoint = '/categories';
  
  // Image Paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderPath = 'assets/images/placeholder.png';
  
  // Lottie Animations
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String emptyCartAnimation = 'assets/animations/empty_cart.json';
  static const String successAnimation = 'assets/animations/success.json';
  
  // Regex Patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
}
