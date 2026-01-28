// --- Imports ---
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_button.dart';
import '../widgets/product_card.dart';

// --- Screen ---
class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  static const List<Map<String, dynamic>> _favouriteItems = [
    {
      'image': 'assets/images/product1.jpg',
      'category': 'Butterflies',
      'title': 'Blue Morpho Flight',
      'author': 'Kumara Senanayake',
      'price': '\$110.00',
    },
    {
      'image': 'assets/images/product2.jpg',
      'category': 'Birds',
      'title': 'Scarlet Macaw Portrait',
      'author': 'Ravi Shanker',
      'price': '\$135.00',
    },
    {
      'image': 'assets/images/product3.jpg',
      'category': 'Mammals',
      'title': 'Leopard Gaze',
      'author': 'Jehan Cummings',
      'price': '\$450.00',
    },
    {
      'image': 'assets/images/product5.jpg',
      'category': 'Reptiles',
      'title': 'Green Vine Snake',
      'author': 'Amal Perera',
      'price': '\$95.00',
    },
  ];

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            floating: true,
            snap: true,
            pinned: false,
            toolbarHeight: 40,
            automaticallyImplyLeading: false,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.transparent,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: textColor,
                  size: 20,
                ),
              ),
            ),
            centerTitle: true,
            title: Text(
              'Favourites',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: textColor,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _favouriteItems[index];
                  return ProductCard(
                    imageUrl: item['image']!,
                    category: item['category']!,
                    title: item['title']!,
                    author: item['author']!,
                    price: item['price']!,
                    isLiked: true,
                    onTap: () {},
                  );
                },
                childCount: _favouriteItems.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

