import 'package:Saborly/shared/widgets/notification_permission_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:Saborly/core/constant/app_colors.dart';
import 'package:Saborly/core/constant/app_strings.dart';
import 'package:Saborly/core/services/notification_service.dart';
import 'package:Saborly/core/services/language_service.dart';
import 'package:Saborly/features/providers/auth_proveder.dart';
import 'package:Saborly/features/providers/cart_provider.dart';
import 'package:Saborly/features/providers/checkout_provider.dart';
import 'package:Saborly/features/providers/home_provider.dart';
import 'package:Saborly/features/providers/location_provider.dart';
import 'package:Saborly/features/providers/men_provider.dart';
import 'package:Saborly/features/providers/notification_provider.dart';
import 'package:Saborly/features/providers/offer_provider.dart';
import 'package:Saborly/features/providers/order_provider.dart';
import 'package:Saborly/features/providers/payment_provider.dart';
import 'package:Saborly/firebase_options.dart';
import 'package:Saborly/shared/models/notification_model.dart';
import 'core/routes/app_routes.dart';
import 'core/services/api_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize local notifications in background isolate
    final FlutterLocalNotificationsPlugin localNotifications =
        FlutterLocalNotificationsPlugin();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'order_updates',
      'Order Updates',
      description: 'Notifications about your order status',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    final androidPlugin =
        localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(androidChannel);
    }

    // Show notification - handle both notification field and data-only messages
    final notification = message.notification;
    final data = message.data;

    String title;
    String body;

    if (notification != null) {
      title = notification.title ?? data['title'] ?? 'New Notification';
      body = notification.body ?? data['body'] ?? 'You have a new notification';
    } else if (data.isNotEmpty) {
      // Handle data-only messages
      title = data['title'] ?? data['notificationTitle'] ?? 'New Notification';
      body = data['body'] ??
          data['notificationBody'] ??
          data['message'] ??
          'You have a new notification';
    } else {
      return; // No notification or data to show
    }

    const androidDetails = AndroidNotificationDetails(
      'order_updates',
      'Order Updates',
      channelDescription: 'Notifications about your order status',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: data.toString(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // CRITICAL: Register background handler BEFORE Firebase initialization
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();

  // Initialize API Service first
  ApiService().initialize();

  // Initialize Language Service and sync everything
  final languageService = LanguageService(prefs);
  final currentLang = languageService.currentLanguage;

  // Sync AppStrings with saved language
  AppStrings.setLanguage(currentLang);

  // Sync API service with saved language
  ApiService().setLanguage(currentLang);

  final cartProvider = CartProvider();
  await cartProvider.initialize();

  // 5. Notification Provider (create **once**)
  final notificationProvider = NotificationProvider()..initialize();

  // 6. Notification Service (singleton) – bind the provider **now**
  final notificationService = NotificationService();
  await notificationService.initialize(); // no permission request
  NotificationService.instance.attachProvider(notificationProvider);

  // 7. UI orientation (mobile only)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  // 8. Run the app
  runApp(FoodKingApp(
    prefs: prefs,
    cartProvider: cartProvider,
    notificationService: notificationService,
    languageService: languageService,
    notificationProvider: notificationProvider, // <-- pass it
  ));
}

class FoodKingApp extends StatefulWidget {
  final SharedPreferences prefs;
  final CartProvider cartProvider;
  final NotificationService notificationService;
  final LanguageService languageService;
  final NotificationProvider notificationProvider;
  const FoodKingApp({
    super.key,
    required this.prefs,
    required this.cartProvider,
    required this.notificationService,
    required this.languageService,
    required this.notificationProvider,
  });

  @override
  State<FoodKingApp> createState() => _FoodKingAppState();
}

class _FoodKingAppState extends State<FoodKingApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  NotificationProvider? _notificationProvider;
  bool _notificationDialogScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.languageService.addListener(_onLanguageChanged);

    // Schedule notification dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleNotificationDialog();
    });
  }

  Future<void> _scheduleNotificationDialog() async {
    if (_notificationDialogScheduled) return;
    _notificationDialogScheduled = true;

    // Wait a bit for the app to load
    await Future.delayed(const Duration(seconds: 3));

    final notificationService = NotificationService();
    final shouldShow = await notificationService.shouldShowPermissionDialog();

    if (!shouldShow || !mounted) return;

    final navigatorState = navigatorKey.currentState;
    if (navigatorState == null) return;

    final navigatorContext = navigatorKey.currentContext;
    if (navigatorContext == null || !navigatorContext.mounted) return;

    final route = DialogRoute<void>(
      context: navigatorContext,
      builder: (BuildContext dialogContext) => NotificationPermissionDialog(
        onAllow: () async {
          Navigator.of(dialogContext).pop();

          final granted =
              await notificationService.requestPermissionWithDialog();

          if (granted && navigatorContext.mounted) {
            ScaffoldMessenger.of(navigatorContext).showSnackBar(
              const SnackBar(
                content: Text(
                    '✅ Notifications enabled! You\'ll receive order updates.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        onDeny: () {
          Navigator.of(dialogContext).pop();

          if (navigatorContext.mounted) {
            ScaffoldMessenger.of(navigatorContext).showSnackBar(
              const SnackBar(
                content:
                    Text('You can enable notifications later in settings.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
      barrierDismissible: false,
      barrierColor: const Color(0x80000000),
      barrierLabel: 'Dismiss',
      settings: const RouteSettings(name: 'notification_permission_dialog'),
    );

    navigatorState.push<void>(route);
  }

  @override
  void dispose() {
    widget.languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {
        AppStrings.setLanguage(widget.languageService.currentLanguage);
      });
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
                // Inside FoodKingApp.build() – replace the whole NotificationProvider entry:

                ChangeNotifierProvider<NotificationProvider>.value(
                  value: widget
                      .notificationProvider, // <-- use the one from main()
                ),
                ChangeNotifierProxyProvider<LanguageService, HomeProvider>(
                  create: (_) {
                    final homeProvider = HomeProvider();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      homeProvider.initializeIfNeeded(
                          widget.languageService.currentLanguage);
                    });
                    return homeProvider;
                  },
                  update: (_, languageService, homeProvider) {
                    homeProvider?.setLanguage(languageService.currentLanguage);
                    return homeProvider ?? HomeProvider();
                  },
                ),
                ChangeNotifierProxyProvider<LanguageService, MenuProvider>(
                  create: (_) => MenuProvider(),
                  update: (_, languageService, menuProvider) {
                    menuProvider?.setLanguage(languageService.currentLanguage);
                    return menuProvider ?? MenuProvider();
                  },
                ),
                ChangeNotifierProxyProvider<LanguageService, OffersProvider>(
                  create: (_) => OffersProvider(),
                  update: (_, languageService, offersProvider) {
                    offersProvider
                        ?.setLanguage(languageService.currentLanguage);
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
                      Locale('fr', ''),
                    ],
                    localeResolutionCallback: (deviceLocale, supportedLocales) {
                      final userLocale = languageService.locale;
                      for (var supportedLocale in supportedLocales) {
                        if (supportedLocale.languageCode ==
                            userLocale.languageCode) {
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
      cardTheme: CardThemeData(
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
