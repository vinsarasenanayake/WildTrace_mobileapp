import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/home_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_nav_bar.dart';
class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
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
