import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/products_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/content_controller.dart';
import '../../controllers/hardware_controller.dart';
import '../../main_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Initialize state and start navigation timer
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // Preload data and navigate to main application
  void _navigateToHome() async {
    try {
      final authProvider = Provider.of<AuthController>(context, listen: false);
      int retryCount = 0;
      while (authProvider.isLoading && retryCount < 20) {
        await Future.delayed(const Duration(milliseconds: 100));
        retryCount++;
      }

      Provider.of<HardwareController>(context, listen: false).initHardware();

      final productsProvider = Provider.of<ProductsController>(context, listen: false);
      final contentProvider = Provider.of<ContentController>(context, listen: false);
      
      final fetchFuture = productsProvider.fetchProducts();
      final contentFuture = contentProvider.fetchContent();
      
      final waitFuture = Future.delayed(const Duration(milliseconds: 1000));
      
      await Future.wait([
        fetchFuture.timeout(const Duration(seconds: 10), onTimeout: () {}), 
        contentFuture.timeout(const Duration(seconds: 10), onTimeout: () {}),
        waitFuture
      ]);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      }
    }
  }

  // Build ui for splash screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 120,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.pets,
                color: Colors.white,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'WILD TRACE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'UNTAMED • TIMELESS',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Color(0xFF2D8C5B),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
