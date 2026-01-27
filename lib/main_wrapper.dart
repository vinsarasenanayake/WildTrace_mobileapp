import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/home_screen.dart';
import 'screens/gallery_screen.dart';

// Main Screen Wrapper for Navigation
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
          return const Scaffold(body: Center(child: Text("Cart Screen")));
        case 3:
          return const Scaffold(body: Center(child: Text("Profile Screen")));
        default:
          return const HomeScreen();
      }
    }

    return getBody();
  }
}
