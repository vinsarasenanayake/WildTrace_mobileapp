// ============================================================================
// IMPORTS
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/products_provider.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/section_title.dart';
import '../widgets/common/quantity_selector.dart';
import '../widgets/cards/photographer_card.dart';
import '../widgets/cards/product_card.dart';

// ============================================================================
// PRODUCT DETAILS SCREEN
// ============================================================================
class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key, 
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

// ============================================================================
// PRODUCT DETAILS STATE
// ============================================================================
class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String _selectedSize = '12 x 18 in';
  int _quantity = 1;
  final List<String> _sizes = ['12 x 18 in', '18 x 24 in', '24 x 36 in', '40 x 60 in'];

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
        elevation: 0, 
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
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
        title: Text(
          widget.product.title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
        child: Column(
          children: [
            _buildHeading(textColor),
            const SizedBox(height: 48),
            _buildMainImage(),
            const SizedBox(height: 48),
            _buildPurchaseOptions(isDarkMode, textColor),
            const SizedBox(height: 48),
            _buildStory(textColor),
            const SizedBox(height: 48),
            _buildPhotographerProfile(),
            const SizedBox(height: 60),
            _buildSimilarWorks(textColor),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods ---
  Widget _buildHeading(Color textColor) {
    return Column(
      children: [
        SectionTitle(title: widget.product.category, mainAxisAlignment: MainAxisAlignment.center),
        const SizedBox(height: 16),
        Text(
          widget.product.title, 
          textAlign: TextAlign.center, 
          style: GoogleFonts.playfairDisplay(
            color: textColor, 
            fontSize: 48, 
            fontStyle: FontStyle.italic, 
            height: 1.1
          )
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _meta('BY ${widget.product.author.toUpperCase()}'),
            const SizedBox(width: 16),
            Container(
              width: 4, 
              height: 4, 
              decoration: const BoxDecoration(
                color: Color(0xFF2ECC71), 
                shape: BoxShape.circle
              )
            ),
            const SizedBox(width: 16),
            _meta(widget.product.location?.toUpperCase() ?? 'WILDERNESS'),
          ],
        ),
      ],
    );
  }
  
  Widget _meta(String text) => Text(
    text, 
    style: GoogleFonts.inter(
      fontSize: 10, 
      fontWeight: FontWeight.bold, 
      letterSpacing: 1.5, 
      color: Colors.grey.shade500
    )
  );

  Widget _buildMainImage() {
    return Container(
      height: 400,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32), 
        child: Image.asset(
          widget.product.imageUrl, 
          fit: BoxFit.cover, 
          errorBuilder: (_,__,___) => Container(color: Colors.grey[900])
        )
      ),
    );
  }

  Widget _buildPurchaseOptions(bool isDarkMode, Color textColor) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, 
        borderRadius: BorderRadius.circular(32), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MUSEUM GRADE PRINT', 
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)
          ),
          const SizedBox(height: 8),
          Text(
            '\$${widget.product.price.toStringAsFixed(2)}', 
            style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold, color: textColor)
          ),
          const SizedBox(height: 32),
          Text(
            'SELECT SIZE', 
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)
          ),
          const SizedBox(height: 12),
          GridView.count(
            padding: EdgeInsets.zero, 
            crossAxisCount: 2, 
            shrinkWrap: true, 
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5, 
            mainAxisSpacing: 12, 
            crossAxisSpacing: 12,
            children: _sizes.map((s) => _sizeBtn(s, isDarkMode)).toList(),
          ),
          const SizedBox(height: 32),
          Text(
            'QUANTITY', 
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)
          ),
          const SizedBox(height: 16),
          Row(children: [
            QuantitySelector(
              quantity: _quantity, 
              onIncrement: () => setState(() => _quantity++), 
              onDecrement: () { if (_quantity > 1) setState(() => _quantity--); }
            ),
            const SizedBox(width: 24),
            Text(
              '$_quantity Items', 
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)
            ),
          ]),
          const SizedBox(height: 32),
          Row(children: [
            Expanded(
              child: CustomButton(
                text: 'ADD TO CART', 
                onPressed: () {
                  cartProvider.addToCart(widget.product, quantity: _quantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.product.title} added to cart'),
                      action: SnackBarAction(
                        label: 'VIEW CART', 
                        onPressed: () {
                          // Note: Ideally use navigation provider to switch tabs or push cart screen
                          Navigator.pop(context); // Go back to gallery (or wherever)
                        }
                      ),
                    )
                  );
                }, 
                type: CustomButtonType.secondary
              )
            ),
            const SizedBox(width: 16),
            _favBtn(),
          ]),
        ],
      ),
    );
  }

  Widget _sizeBtn(String size, bool isDarkMode) {
    final bool sel = size == _selectedSize;
    return InkWell(
      onTap: () => setState(() => _selectedSize = size),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF2ECC71).withOpacity(0.1) : Colors.transparent, 
          border: Border.all(
            color: sel ? const Color(0xFF2ECC71) : Colors.grey.withOpacity(0.2)
          ), 
          borderRadius: BorderRadius.circular(12)
        ),
        child: Text(
          size, 
          style: GoogleFonts.inter(
            fontSize: 12, 
            fontWeight: FontWeight.bold, 
            color: sel ? const Color(0xFF2ECC71) : (isDarkMode ? Colors.white : Colors.black)
          )
        ),
      ),
    );
  }

  Widget _favBtn() {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isLiked = favoritesProvider.isFavorite(widget.product.id);
        return InkWell(
          onTap: () => favoritesProvider.toggleFavorite(widget.product),
          child: Container(
            width: 56, 
            height: 56, 
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)), 
              borderRadius: BorderRadius.circular(16)
            ), 
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border, 
              color: isLiked ? const Color(0xFFE11D48) : Colors.grey.shade400
            )
          ),
        );
      }
    );
  }

  Widget _buildStory(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Behind the Lens', color: textColor),
        const SizedBox(height: 24),
        Text(
          widget.product.description ?? "Every photograph in our collection is a testament to the untamed beauty of the natural world, captured with patience and respect.", 
          style: GoogleFonts.inter(fontSize: 14, height: 1.8, color: Colors.grey.shade600)
        ),
        const SizedBox(height: 24),
        GridView.count(
          padding: EdgeInsets.zero, 
          crossAxisCount: 2, 
          shrinkWrap: true, 
          physics: const NeverScrollableScrollPhysics(), 
          childAspectRatio: 3.0,
          children: [
            _stat('APERTURE', 'f/5.6', textColor), 
            _stat('SHUTTER', '1/4000s', textColor), 
            _stat('ISO', '800', textColor), 
            _stat('FOCAL', '85mm', textColor)
          ],
        ),
      ],
    );
  }
  
  Widget _stat(String l, String v, Color c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, 
    children: [
      Text(l, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade400)), 
      Text(v, style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: c))
    ]
  );

  Widget _buildPhotographerProfile() => PhotographerCard(
    imagePath: 'assets/images/teammember1.jpg',
    name: widget.product.author,
    role: 'FOUNDER & LEAD',
    quote: 'Nature doesn\'t need a filter, it just needs a witness.',
    achievement: 'CANON AMBASSADOR',
    badgeText: 'DJMPC WINNER',
  );

  Widget _buildSimilarWorks(Color textColor) {
    return Consumer2<ProductsProvider, FavoritesProvider>(
      builder: (context, productsProvider, favoritesProvider, child) {
        // Filter products by same category, excluding current product
        final similar = productsProvider.products.where((p) => 
          p.category == widget.product.category && p.id != widget.product.id
        ).take(4).toList();

        if (similar.isEmpty) return const SizedBox();

        return Column(
          children: [
            Text(
              'Similar Artifacts', 
              style: GoogleFonts.playfairDisplay(fontSize: 26, fontStyle: FontStyle.italic, color: textColor)
            ),
            const SizedBox(height: 32),
            GridView.builder(
              padding: EdgeInsets.zero, 
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                mainAxisSpacing: 24, 
                crossAxisSpacing: 16, 
                childAspectRatio: 0.7
              ),
              itemCount: similar.length,
              itemBuilder: (context, index) {
                final p = similar[index];
                return ProductCard(
                  imageUrl: p.imageUrl,
                  category: p.category,
                  title: p.title,
                  author: p.author,
                  price: '\$${p.price.toStringAsFixed(2)}',
                  isLiked: favoritesProvider.isFavorite(p.id),
                  onLikeToggle: () => favoritesProvider.toggleFavorite(p),
                  onTap: () => Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p))
                  ),
                );
              },
            ),
          ],
        );
      }
    );
  }
}




