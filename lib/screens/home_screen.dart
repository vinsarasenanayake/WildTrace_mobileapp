import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/app_bar.dart';
import '../widgets/bottom_nav_bar.dart';

// --- Home Screen Shell ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: const WildAppBar(),
      body: const Placeholder(), 
      bottomNavigationBar: const WildBottomNavBar(),
    );
  }
}
