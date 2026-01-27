import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';

// --- Shared Bottom Navigation ---
class WildBottomNavBar extends StatelessWidget {
  const WildBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    final List<BottomNavigationBarItem> allItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'HOME'),
      const BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'JOURNEY'),
      const BottomNavigationBarItem(icon: Icon(Icons.photo_library_rounded), label: 'GALLERY'),
      const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: 'CART'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'PROFILE'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1B4332),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: navProvider.selectedIndex,
          onTap: (index) => navProvider.setSelectedIndex(index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.greenAccent,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: allItems,
        ),
      ),
    );
  }
}
