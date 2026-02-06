import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/content_provider.dart';
import '../../main_wrapper.dart';

// app launch screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // animation controllers
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // initializes animations and starts data loading
  @override
  void initState() {
    super.initState();
    
    // setup animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // fade in animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    // scale up animation
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    // start animations
    _controller.forward();
    _navigateToHome();
  }

  // loads initial data and navigates to main screen
  void _navigateToHome() async {
    try {
      // wait for auth session restoration
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      int retryCount = 0;
      while (authProvider.isLoading && retryCount < 20) {
        await Future.delayed(const Duration(milliseconds: 100));
        retryCount++;
      }

      // fetch products and content concurrently
      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      final contentProvider = Provider.of<ContentProvider>(context, listen: false);
      
      final fetchFuture = productsProvider.fetchProducts();
      final contentFuture = contentProvider.fetchContent();
      
      // minimum splash display time
      final waitFuture = Future.delayed(const Duration(milliseconds: 1500));
      
      // wait for all data to load
      await Future.wait([
        fetchFuture.timeout(const Duration(seconds: 10), onTimeout: () {}), 
        contentFuture.timeout(const Duration(seconds: 10), onTimeout: () {}),
        waitFuture
      ]);

      // navigate to main app
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainWrapper()),
        );
      }
    } catch (e) {
      // navigate even if data fetch fails
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainWrapper()),
        );
      }
    }
  }

  // cleanup animation controller
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // builds animated splash screen ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // app logo
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
                    // app title
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
                    // app tagline
                    const Text(
                      'UNTAMED • TIMELESS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // loading indicator
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
          },
        ),
      ),
    );
  }
}
