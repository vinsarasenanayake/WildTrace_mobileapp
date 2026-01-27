import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/product_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/wildtrace_back_button.dart';
class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    final List<Map<String, dynamic>> favouriteItems = [
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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const WildTraceBackButton(),
        centerTitle: true,
        title: Text(
          'Favourites',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: textColor,
          ),
        ),
      ),
      bottomNavigationBar: const WildTraceBottomNavBar(),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: favouriteItems.length,
        itemBuilder: (context, index) {
          final item = favouriteItems[index];
          return ProductCard(
            type: ProductCardType.standard,
            imageUrl: item['image'],
            category: item['category'],
            title: item['title'],
            author: item['author'],
            price: item['price'],
            isLiked: true,
            onLikeToggle: () {},
            onTap: () {},
          );
        },
      ),
    );
  }
}
