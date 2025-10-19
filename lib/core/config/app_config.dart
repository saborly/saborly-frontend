class AppConfig {
  static const String appName = 'Saborely';
  static const String appVersion = '1.0.0';
  static const String baseUrl = 'https://soleybackend.vercel.app/api/v1';
  static const String imageBaseUrl = 'https://soleybackend.vercel.app/api/v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const double deliveryFee = 0;
  static const double taxRate = 0;
  static const String stripePublishableKey ='pk_test_51RPM9TRrTfHc97PXAZ5IxGY6vtzWCsIwJIMhZNEVjkrwVUNJPuSuHX24yEG9Rtfc7wC91ekp3n4qaFuEWFAQiec3006UoRdV6G';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
}
