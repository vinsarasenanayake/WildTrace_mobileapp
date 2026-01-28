// ============================================================================
// IMPORTS
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import 'product_details_screen.dart';
import '../widgets/cards/product_card.dart';

// ============================================================================
// FAVOURITES SCREEN
// ============================================================================
class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

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
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, child) {
              final favorites = favoritesProvider.favorites;
              
              if (favorites.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(textColor),
                );
              }
              
              return SliverPadding(
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
                      final product = favorites[index];
                      return ProductCard(
                        imageUrl: product.imageUrl,
                        category: product.category,
                        title: product.title,
                        author: product.author,
                        price: '\$${product.price.toStringAsFixed(2)}',
                        isLiked: true,
                        onLikeToggle: () => favoritesProvider.toggleFavorite(product),
                        onTap: () {
                           Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product))
                           );
                        },
                      );
                    },
                    childCount: favorites.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No favorites yet.', 
            style: GoogleFonts.inter(
              fontSize: 14, 
              color: Colors.grey.shade500, 
              fontWeight: FontWeight.w500
            )
          ),
          const SizedBox(height: 8),
          Text(
            'Start exploring and save items you love!', 
            style: GoogleFonts.inter(
              fontSize: 12, 
              color: Colors.grey.shade400
            )
          ),
        ],
      ),
    );
  }
}




