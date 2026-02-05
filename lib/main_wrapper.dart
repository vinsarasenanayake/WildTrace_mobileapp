import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/navigation_provider.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/gallery_screen.dart';
import 'views/screens/cart_screen.dart';
import 'views/screens/profile_screen.dart';
import 'views/widgets/common/bottom_nav_bar.dart';

// Application wrapper
class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    
    // Switch between screens
    Widget getBody() {
      switch (navProvider.selectedIndex) {
        case 0:
          return const HomeScreen();
        case 1:
          return const GalleryScreen();
        case 2:
          return const CartScreen();
        case 3:
          return const ProfileScreen();
        default:
          return const HomeScreen();
      }
    }
    
    return Scaffold(
      body: getBody(),
      bottomNavigationBar: const WildTraceBottomNavBar(),
    );
  }
}
