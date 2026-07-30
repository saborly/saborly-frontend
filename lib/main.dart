import 'dart:async';
import 'package:Saborly/core/utils/error_presenter.dart';
import 'package:Saborly/shared/widgets/app_error_widget.dart';
import 'package:Saborly/shared/widgets/notification_permission_dialog.dart';
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
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/routes/app_routes.dart';
import 'core/services/api_service.dart';
// REMOVE the maintenance screen import
// import 'package:Saborly/shared/screens/maintenance_screen.dart';

@pragma('vm:entry-point')
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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

void main() {
  // Global safety net: a single unexpected error anywhere in the app (a bad
  // network response, a null field from a flaky backend, etc.) must not be
  // able to crash the whole app or leave it on a blank/frozen screen.
  // FlutterError.onError covers errors thrown during widget build/layout/
  // paint; runZonedGuarded's error callback covers everything else
  // (unawaited Futures, timers, stream callbacks) that would otherwise
  // become an uncaught, app-terminating zone error.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('⚠️ Flutter error caught (isolated, app continues): ${details.exceptionAsString()}');
  };
  // Swaps Flutter's default red/gray exception screen for an on-brand one —
  // see AppErrorWidget. Debug builds still print the real error above.
  ErrorWidget.builder = (details) => AppErrorWidget(details: details);

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('⚠️ Uncaught platform error caught (isolated, app continues): $error');
    showGenericErrorSnackbar();
    return true; // handled — prevents the engine from treating this as fatal
  };

  runZonedGuarded(_runApp, (error, stack) {
    debugPrint('⚠️ Uncaught zone error caught (isolated, app continues): $error');
    showGenericErrorSnackbar();
  });
}

Future<void> _runApp() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Enable web support
  // flutter config --enable-web
  if (kIsWeb) {
    // Firebase not configured for web — skip to avoid blocking startup
  } else {
    // Mobile-specific initialization
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final prefs = await SharedPreferences.getInstance();

  // FOR TESTING: Clear permission flag to ensure dialog shows
  // prefs.remove('notification_permission_asked');
  
  print('🔍 DEBUG: permission_asked flag: ${prefs.getBool('notification_permission_asked')}');

  // Initialize API Service first
  ApiService().initialize();
  await ApiService().loadBranchFromPrefs();
  await ApiService().loadSelectedLocationFromPrefs();

  // Initialize Language Service and sync everything
  final languageService = LanguageService(prefs);
  final currentLang = languageService.currentLanguage;

  // Sync AppStrings with saved language
  AppStrings.setLanguage(currentLang);

  // Sync API service with saved language
  ApiService().setLanguage(currentLang);

  // 5. Notification Provider (create **once**)
  final notificationProvider = NotificationProvider()..initialize();

  // 6. Notification Service (singleton)
  final notificationService = NotificationService();

  // ✅ Parallelize independent heavy initializations
  final cartProvider = CartProvider();
  await Future.wait([
    cartProvider.initialize(),
    notificationService.initialize(), // no permission request
  ]);
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
  bool _notificationDialogScheduled = false;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    widget.languageService.addListener(_onLanguageChanged);

    // Initialize Firebase Messaging
    _initializeFirebaseMessaging();

    // Schedule notification dialog only for mobile
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scheduleNotificationDialog();
      });
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    if (!kIsWeb) {
      print('🔍 DEBUG: Initializing Firebase Messaging...');
      
      // Configure Firebase Messaging
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      
      // Check current permission status
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      print('🔍 DEBUG: Current notification status: ${settings.authorizationStatus}');
      
      // If the OS-level permission is already authorized, mark the dialog as
      // "asked" so it doesn't get shown again. Don't force it back to false
      // when not authorized - that would overwrite an explicit "not now" from
      // _savePermissionDenied() and make the dialog reappear on every launch.
      final isAuthorized = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (isAuthorized) {
        widget.prefs.setBool('notification_permission_asked', true);
        print('🔍 DEBUG: Saved permission_asked as: true');
      }
    }
  }

  Future<void> _scheduleNotificationDialog() async {
    print('🔍 DEBUG: Schedule notification dialog called');
    
    if (_notificationDialogScheduled || _isDialogShowing) {
      print('🔍 DEBUG: Dialog already scheduled or showing');
      return;
    }
    
    _notificationDialogScheduled = true;

    // Wait for app to be fully loaded - increased delay
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) {
      print('🔍 DEBUG: Widget not mounted');
      return;
    }

    // Check if we should show the dialog
    final shouldShow = await _shouldShowPermissionDialog();
    print('🔍 DEBUG: Should show dialog: $shouldShow');
    
    if (!shouldShow) {
      print('🔍 DEBUG: Not showing dialog - checking why...');
      final permissionAsked = widget.prefs.getBool('notification_permission_asked') ?? false;
      print('🔍 DEBUG: permission_asked in prefs: $permissionAsked');
      
      if (!kIsWeb) {
        final settings = await FirebaseMessaging.instance.getNotificationSettings();
        print('🔍 DEBUG: Current permission status: ${settings.authorizationStatus}');
      }
      return;
    }

    // Set flag to prevent multiple dialogs
    _isDialogShowing = true;

    // Show the dialog
    print('🔍 DEBUG: Showing notification permission dialog...');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final context = AppRoutes.navigatorKey.currentContext;
      if (context == null) {
        print('🔍 DEBUG: Root context is null');
        _isDialogShowing = false;
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return NotificationPermissionDialog(
            onAllow: () async {
              print('🔍 DEBUG: User clicked Allow');
              Navigator.of(dialogContext).pop();
              _isDialogShowing = false;
              await _requestNotificationPermission();
            },
            onDeny: () {
              print('🔍 DEBUG: User clicked Not Now');
              Navigator.of(dialogContext).pop();
              _isDialogShowing = false;
              _savePermissionDenied();
            },
          );
        },
      ).then((_) {
        _isDialogShowing = false;
        print('🔍 DEBUG: Dialog closed');
      });
    });
  }

  Future<bool> _shouldShowPermissionDialog() async {
    print('🔍 DEBUG: Checking if should show dialog...');
    
    // TESTING: Force show dialog - uncomment this line for testing
    // return true;
    
    // Check if user has already been asked
    final permissionAsked = widget.prefs.getBool('notification_permission_asked') ?? false;
    print('🔍 DEBUG: permission_asked from prefs: $permissionAsked');
    
    if (permissionAsked) {
      print('🔍 DEBUG: Already asked for permission');
      return false;
    }

    // Check current permission status
    if (!kIsWeb) {
      try {
        final settings = await FirebaseMessaging.instance.getNotificationSettings();
        final status = settings.authorizationStatus;
        print('🔍 DEBUG: Firebase permission status: $status');
        
        // Show dialog if not determined or denied
        final shouldShow = status == AuthorizationStatus.notDetermined ||
                           status == AuthorizationStatus.denied;
        print('🔍 DEBUG: Should show based on Firebase: $shouldShow');
        return shouldShow;
      } catch (e) {
        print('🔍 DEBUG: Error checking Firebase permissions: $e');
        return true; // Show dialog if error
      }
    }
    
    print('🔍 DEBUG: Web platform, returning true');
    return true; // For web or other platforms
  }

  Future<void> _requestNotificationPermission() async {
    try {
      print('🔍 DEBUG: Requesting notification permission...');

      // Delegate to NotificationService so its internal token state is set
      // and the token gets pushed to the backend immediately - requesting
      // permission via FirebaseMessaging directly here left NotificationService
      // unaware of the token until the next app restart.
      final granted = await NotificationService.instance.requestPermissionWithDialog();

      print('🔍 DEBUG: Permission granted: $granted');

      if (granted) {
        // Show success message
        final context = AppRoutes.navigatorKey.currentContext;
        if (mounted && context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifications enabled successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Permission denied
        print('🔍 DEBUG: Permission denied or provisional');
        final context = AppRoutes.navigatorKey.currentContext;
        if (mounted && context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permission denied. You can enable it in settings.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('🔍 DEBUG: Error requesting notification permission: $e');
      final context = AppRoutes.navigatorKey.currentContext;
      if (mounted && context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to request notification permission'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _savePermissionDenied() {
    print('🔍 DEBUG: Saving permission denied state');
    widget.prefs.setBool('notification_permission_asked', true);
    print('🔍 DEBUG: Saved permission_asked as true (denied)');
    
    final context = AppRoutes.navigatorKey.currentContext;
    if (mounted && context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can enable notifications later in app settings.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
            // REMOVED the maintenance screen check - web will use the same app structure
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
                ChangeNotifierProvider<NotificationProvider>.value(
                  value: widget.notificationProvider,
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
                    final provider = homeProvider ?? HomeProvider();
                    if (provider.currentLanguage != languageService.currentLanguage) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        provider.setLanguage(languageService.currentLanguage);
                      });
                    }
                    return provider;
                  },
                ),
                ChangeNotifierProxyProvider<LanguageService, MenuProvider>(
                  create: (_) => MenuProvider(),
                  update: (_, languageService, menuProvider) {
                    final provider = menuProvider ?? MenuProvider();
                    if (provider.currentLanguage != languageService.currentLanguage) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        provider.setLanguage(languageService.currentLanguage);
                      });
                    }
                    return provider;
                  },
                ),
                ChangeNotifierProxyProvider<LanguageService, OffersProvider>(
                  create: (_) => OffersProvider(),
                  update: (_, languageService, offersProvider) {
                    final provider = offersProvider ?? OffersProvider();
                    if (provider.currentLanguage != languageService.currentLanguage) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        provider.setLanguage(languageService.currentLanguage);
                      });
                    }
                    return provider;
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
                    scaffoldMessengerKey: scaffoldMessengerKey,
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
    final baseTextTheme = GoogleFonts.manropeTextTheme().copyWith(
      displayLarge: GoogleFonts.breeSerif(
        fontSize: 40.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      displayMedium: GoogleFonts.breeSerif(
        fontSize: 34.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      headlineMedium: GoogleFonts.breeSerif(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      titleLarge: GoogleFonts.breeSerif(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textMedium,
      ),
    );

    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textDark,
        surface: AppColors.surface,
        onSurface: AppColors.textDark,
        error: AppColors.error,
        onError: Colors.white,
      ),
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.divider,
      splashColor: AppColors.primary.withOpacity(0.08),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        titleTextStyle: GoogleFonts.breeSerif(
          color: AppColors.textDark,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: baseTextTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          textStyle: GoogleFonts.manrope(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFBF6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        hintStyle: GoogleFonts.manrope(
          color: AppColors.textLight,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shadowColor: AppColors.shadow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
          side: BorderSide(
            color: Colors.white.withOpacity(0.92),
            width: 1.4,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.accentNight,
        contentTextStyle: GoogleFonts.manrope(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(size: 22.sp),
        unselectedIconTheme: IconThemeData(size: 20.sp),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 14,
        selectedLabelStyle: GoogleFonts.manrope(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
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
