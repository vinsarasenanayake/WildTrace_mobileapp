import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'controllers/navigation_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/favorites_controller.dart';
import 'controllers/products_controller.dart';
import 'controllers/orders_controller.dart';
import 'controllers/content_controller.dart';
import 'controllers/hardware_controller.dart';

import 'utilities/app_theme.dart';
import 'views/screens/splash_screen.dart';

// entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // setup env
  await dotenv.load(fileName: ".env");

  // payment config
  try {
    Stripe.publishableKey = (dotenv.env['STRIPE_KEY'] ?? '').trim();
    await Stripe.instance.applySettings();
  } catch (e) {
    debugPrint('Stripe initialization failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        // providers
        ChangeNotifierProvider(
          create: (_) => NavigationController(),
        ),
        ChangeNotifierProvider(create: (_) => AuthController()),
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
          update: (_, auth, orders) =>
              orders!..updateToken(auth.token, auth.currentUser?.id),
        ),
        ChangeNotifierProvider(
          create: (_) => ContentController()..fetchContent(),
        ),
        ChangeNotifierProvider(create: (_) => HardwareController()),
      ],
      child: const WildTraceApp(),
    ),
  );
}

// root widget
class WildTraceApp extends StatelessWidget {
  const WildTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wild Trace',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
