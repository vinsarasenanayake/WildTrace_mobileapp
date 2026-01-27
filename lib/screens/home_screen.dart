import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/home_hero.dart';
import '../widgets/behind_the_lens.dart';
import '../widgets/featured_collection.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  final List<Map<String, String>> _collectionItems = const [
    {'image': 'assets/images/product14.jpg', 'category': 'BIRDS', 'title': 'Owl in Twilight', 'location': 'YALA NATIONAL PARK', 'year': '2020', 'price': '\$140.00'},
    {'image': 'assets/images/product2.jpg', 'category': 'REPTILES', 'title': 'Green Serpent', 'location': 'SINHARAJA RAINFOREST', 'year': '2021', 'price': '\$120.00'},
    {'image': 'assets/images/product3.jpg', 'category': 'MAMMALS', 'title': 'Elephant Walk', 'location': 'AMBOSELI RESERVE', 'year': '2019', 'price': '\$340.00'},
    {'image': 'assets/images/product4.jpg', 'category': 'MARINE', 'title': 'Coral Reefs', 'location': 'GREAT BARRIER REEF', 'year': '2022', 'price': '\$220.00'},
    {'image': 'assets/images/product1.jpg', 'category': 'BIRDS', 'title': 'Kingfisher Dive', 'location': 'TARANGIRE', 'year': '2020', 'price': '\$180.00'},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF9FBF9),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Home',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HomeHero(),
            FeaturedCollection(items: _collectionItems),
            const BehindTheLens(),
          ],
        ),
      ),
    );
  }
}
