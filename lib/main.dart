// lib/main.dart - FIXED initialization

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soely/core/constant/app_colors.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/services/notification_service.dart';
import 'package:soely/core/services/language_service.dart';
import 'package:soely/features/providers/auth_proveder.dart';
import 'package:soely/features/providers/cart_provider.dart';
import 'package:soely/features/providers/checkout_provider.dart';
import 'package:soely/features/providers/home_provider.dart';
import 'package:soely/features/providers/location_provider.dart';
import 'package:soely/features/providers/men_provider.dart';
import 'package:soely/features/providers/offer_provider.dart';
import 'package:soely/features/providers/order_provider.dart';
import 'package:soely/features/providers/payment_provider.dart';
import 'package:soely/firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'core/services/api_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  
  final prefs = await SharedPreferences.getInstance();
  
  // ✅ CRITICAL: Initialize API Service first
  ApiService().initialize();
  
  // ✅ CRITICAL: Initialize Language Service and sync everything
  final languageService = LanguageService(prefs);
  final currentLang = languageService.currentLanguage;
  
  // Sync AppStrings with saved language
  AppStrings.setLanguage(currentLang);
  
  // Sync API service with saved language
  ApiService().setLanguage(currentLang);
  
 
  
  final cartProvider = CartProvider();
  await cartProvider.initialize();
  
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
  
  runApp(FoodKingApp(
    prefs: prefs,
    cartProvider: cartProvider,
    notificationService: notificationService,
    languageService: languageService,
  ));
}

class FoodKingApp extends StatefulWidget {
  final SharedPreferences prefs;
  final CartProvider cartProvider;
  final NotificationService notificationService;
  final LanguageService languageService;
  
  const FoodKingApp({
    super.key,
    required this.prefs,
    required this.cartProvider,
    required this.notificationService,
    required this.languageService,
  });

  @override
  State<FoodKingApp> createState() => _FoodKingAppState();
}

class _FoodKingAppState extends State<FoodKingApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupNotificationHandlers();
    
    // ✅ Listen to language changes and update UI
    widget.languageService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    widget.languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  /// ✅ CRITICAL: Force rebuild when language changes
  void _onLanguageChanged() {
    if (mounted) {
      setState(() {
        // This forces MaterialApp to rebuild with new locale
        AppStrings.setLanguage(widget.languageService.currentLanguage);
      });
    }
  }

  void _setupNotificationHandlers() {
    widget.notificationService.onNotificationReceived = (data) {
      _handleNotificationData(data);
    };
    
    widget.notificationService.onNotificationTapped = (data) {
      _handleNotificationNavigation(data);
    };
  }
  
  void _handleNotificationData(Map<String, dynamic> data) {
    final type = data['type'];
    
    switch (type) {
      case 'order_update':
    
        break;
      case 'new_order':
        break;
      default:
    }
  }
  
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'];
    final context = navigatorKey.currentContext;
    
    if (context == null) {
      return;
    }
    
    switch (type) {
      case 'order_update':
        final orderId = data['orderId'];
        if (orderId != null) {
          Navigator.of(context).pushNamed('/order-details', arguments: orderId);
        }
        break;
      case 'new_order':
        Navigator.of(context).pushNamed('/orders');
        break;
      case 'promotion':
        Navigator.of(context).pushNamed('/home');
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Size designSize;
        if (kIsWeb) {
          if (constraints.maxWidth < 600) {
            designSize = const Size(390, 844);
          } else if (constraints.maxWidth < 1200) {
            designSize = const Size(768, 1024);
          } else {
            designSize = const Size(1920, 1080);
          }
        } else {
          designSize = const Size(390, 844);
        }
        
        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => AuthProvider(widget.prefs)..checkAuthStatus(),
                ),
                ChangeNotifierProvider<CartProvider>.value(
                  value: widget.cartProvider,
                ),
                ChangeNotifierProvider<LanguageService>.value(
                  value: widget.languageService,
                ),
               ChangeNotifierProxyProvider<LanguageService, HomeProvider>(
      create: (_) {
        final homeProvider = HomeProvider();
        // Initialize immediately with current language
        WidgetsBinding.instance.addPostFrameCallback((_) {
          homeProvider.initializeIfNeeded(widget.languageService.currentLanguage);
        });
        return homeProvider;
      },
      update: (_, languageService, homeProvider) {
        homeProvider?.setLanguage(languageService.currentLanguage);
        return homeProvider ?? HomeProvider();
      },
    ),
    
    // ✅ FIXED: Initialize MenuProvider with current language
    ChangeNotifierProxyProvider<LanguageService, MenuProvider>(
      create: (_) => MenuProvider(),
      update: (_, languageService, menuProvider) {
        menuProvider?.setLanguage(languageService.currentLanguage);
        return menuProvider ?? MenuProvider();
      },
    ),
    
    // ✅ CRITICAL: Initialize OffersProvider with current language
    // It will use the API language that was set by HomeProvider
    ChangeNotifierProxyProvider<LanguageService, OffersProvider>(
      create: (_) => OffersProvider(),
      update: (_, languageService, offersProvider) {
        offersProvider?.setLanguage(languageService.currentLanguage);
        return offersProvider ?? OffersProvider();
      },
    ),
                ChangeNotifierProvider(create: (_) => OrderProvider()),
                ChangeNotifierProvider(create: (_) => LocationProvider()),
                ChangeNotifierProvider(create: (_) => CheckoutProvider()),
                ChangeNotifierProvider(create: (_) => PaymentProvider()),
              ],
              child: Consumer<LanguageService>(
                builder: (context, languageService, _) {
                  return MaterialApp.router(
                    title: AppStrings.appName,
                    debugShowCheckedModeBanner: false,
                    theme: _buildThemeData(),
                    
                    // ✅ CRITICAL: Use language service's locale
                    locale: languageService.locale,
                    
                    localizationsDelegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    
                    supportedLocales: const [
                      Locale('en', ''),
                      Locale('es', ''),
                      Locale('ca', ''),
                      Locale('ar', ''),
                    ],
                    
                    localeResolutionCallback: (deviceLocale, supportedLocales) {
                      final userLocale = languageService.locale;
                      for (var supportedLocale in supportedLocales) {
                        if (supportedLocale.languageCode == userLocale.languageCode) {
                          return userLocale;
                        }
                      }
                      return const Locale('es', '');
                    },
                    
                    routerConfig: AppRoutes.router,
                    builder: (context, child) {
                      return Directionality(
                        textDirection: languageService.textDirection,
                        child: AppBackButtonHandler(
                          child: child ?? const SizedBox(),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
  
  ThemeData _buildThemeData() {
    return ThemeData(
      primarySwatch: Colors.pink,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textDark,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: GoogleFonts.robotoTextTheme().apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          textStyle: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textLight,
          fontSize: 14.sp,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
      useMaterial3: true,
    );
  }
}

class AppBackButtonHandler extends StatelessWidget {
  final Widget child;
  
  const AppBackButtonHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {},
      child: child,
    );
  }
}