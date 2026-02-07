// ============================================================================
// Main application entry point for WildTrace platform.
// ============================================================================

// Core Flutter and utility imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Controllers
import 'controllers/navigation_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/favorites_controller.dart';
import 'controllers/products_controller.dart';
import 'controllers/orders_controller.dart';
import 'controllers/content_controller.dart';
import 'controllers/battery_controller.dart';

// Screens
import 'views/screens/splash_screen.dart';

// App initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup environment
  await dotenv.load(fileName: ".env");
  
  // Configure payments
  Stripe.publishableKey = dotenv.get('STRIPE_PUBLISHABLE_KEY');
  await Stripe.instance.applySettings();

  runApp(
    MultiProvider(
      providers: [
        // State management controllers
        ChangeNotifierProvider(create: (_) => NavigationController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => BatteryController()),
        ChangeNotifierProxyProvider<AuthController, FavoritesController>(
          create: (_) => FavoritesController(),
          update: (_, auth, favorites) => favorites!..updateToken(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthController, CartController>(
          create: (_) => CartController(),
          update: (_, auth, cart) => cart!..updateToken(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthController, ProductsController>(
          create: (_) => ProductsController(),
          update: (_, auth, products) => products!..updateToken(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthController, OrdersController>(
          create: (_) => OrdersController(),
          update: (_, auth, orders) => orders!..updateToken(auth.token, auth.currentUser?.id),
        ),
        ChangeNotifierProvider(create: (_) => ContentController()..fetchContent()),
      ],
      child: const WildTraceApp(),
    ),
  );
}

// Main application widget
class WildTraceApp extends StatelessWidget {
  const WildTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wild Trace',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      // Light theme settings
      theme: ThemeData(
        useMaterial3: true,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        primaryColor: const Color(0xFF1B4332),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4332),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            elevation: 0,
          ).copyWith(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ).copyWith(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ).copyWith(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ).copyWith(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ),
      ),
      // Dark theme settings
      darkTheme: ThemeData(
        useMaterial3: true,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        primaryColor: const Color(0xFF1B4332),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4332),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            elevation: 0,
          ).copyWith(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ).copyWith(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ).copyWith(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ).copyWith(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ),
      ),
      home: const SplashScreen(),
      scrollBehavior: const NoGlowScrollBehavior(),
    );
  }
}

// Scroll behavior configuration
class NoGlowScrollBehavior extends ScrollBehavior {
  const NoGlowScrollBehavior();
  
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
