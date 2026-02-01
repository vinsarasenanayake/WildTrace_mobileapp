import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/navigation_provider.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/section_title.dart';
import '../widgets/common/quantity_selector.dart';
import '../widgets/cards/photographer_card.dart';
import '../widgets/cards/product_card.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import 'cart_screen.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

// Product Details Screen
class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key, 
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

// Product Details State
class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String _selectedSize = '12 x 18 in';
  int _quantity = 1;
  double? _currentPrice;
  bool _isPriceLoading = false;
  Product? _fullProduct;
  bool _isLoadingDetails = true;
  final List<String> _sizes = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.product.price;
    
    // Parse sizes from options
    if (widget.product.options != null && widget.product.options!['frames'] != null) {
      final List frames = widget.product.options!['frames'];
      for (var frame in frames) {
        if (frame['size'] != null) {
          _sizes.add(frame['size'].toString());
        }
      }
    }
    
    // Fallback if no sizes in options
    if (_sizes.isEmpty) {
      _sizes.addAll(['12 x 18 in', '18 x 24 in', '24 x 36 in', '40 x 60 in']);
    }

    _selectedSize = _sizes.first;
    
    // Initial fetch for default size
    _fetchPrice(_selectedSize);
    
    // Fetch full product details (photographer info, etc.)
    _fetchFullDetails();
  }

  Future<void> _fetchFullDetails() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final details = await _apiService.fetchProductDetails(widget.product.id, token: authProvider.token);
      if (mounted && details != null) {
        setState(() {
          _fullProduct = details;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingDetails = false);
    }
  }

  Future<void> _showLoginRequiredAlert() async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: 'Authentication Required',
      message: 'Please login to add items to your cart or favorites.',
      okLabel: 'LOGIN',
      cancelLabel: 'LATER',
      isDestructiveAction: false,
    );

    if (result == OkCancelResult.ok && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _fetchPrice(String size) async {
    setState(() => _isPriceLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final newPrice = await _apiService.getProductPrice(
        widget.product.id, 
        size,
        token: authProvider.token
      );
      
      if (mounted) {
        setState(() {
          if (newPrice != null) {
            _currentPrice = newPrice;
          }
          _isPriceLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isPriceLoading = false);
    }
  }

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

  // Helper Methods
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
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
        child: widget.product.imageUrl.startsWith('http')
          ? Image.network(
              widget.product.imageUrl, 
              fit: BoxFit.cover, 
              errorBuilder: (_,__,___) => Container(color: Colors.grey[900])
            )
          : Image.asset(
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
          _isPriceLoading 
            ? const SizedBox(
                height: 44, 
                width: 44,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2ECC71)),
                ),
              )
            : Text(
                '\$${(_currentPrice ?? widget.product.price).toStringAsFixed(2)}', 
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
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  if (!auth.isAuthenticated) {
                    _showLoginRequiredAlert();
                    return;
                  }

                  cartProvider.addToCart(
                    widget.product, 
                    quantity: _quantity, 
                    size: _selectedSize, 
                    price: _currentPrice
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.product.title} added to cart'),
                      action: SnackBarAction(
                        label: 'VIEW CART', 
                        onPressed: () {
                          // Close product details and switch to Cart tab to keep bottom nav visible
                          Navigator.pop(context);
                          Provider.of<NavigationProvider>(context, listen: false).setSelectedIndex(2);
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
      onTap: () {
        if (_selectedSize != size) {
          setState(() => _selectedSize = size);
          _fetchPrice(size);
        }
      },
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
    return Consumer2<FavoritesProvider, AuthProvider>(
      builder: (context, favoritesProvider, authProvider, child) {
        final isLiked = favoritesProvider.isFavorite(widget.product.id);
        return InkWell(
          onTap: () {
            if (!authProvider.isAuthenticated) {
              _showLoginRequiredAlert();
              return;
            }
            favoritesProvider.toggleFavorite(widget.product);
          },
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

  Widget _buildPhotographerProfile() {
    final product = _fullProduct ?? widget.product;
    return PhotographerCard(
      imagePath: product.authorImage != null && product.authorImage!.startsWith('http') 
          ? product.authorImage! 
          : 'assets/images/teammember1.jpg',
      name: product.author,
      role: product.profession ?? 'WILDLIFE PHOTOGRAPHER',
      quote: product.quote ?? 'Nature doesn\'t need a filter, it just needs a witness.',
      achievement: product.achievement ?? 'CANON AMBASSADOR',
      badgeText: 'DJMPC WINNER',
    );
  }

  Widget _buildSimilarWorks(Color textColor) {
    return Consumer2<ProductsProvider, FavoritesProvider>(
      builder: (context, productsProvider, favoritesProvider, child) {
        // 1. Get products from the same category (excluding current)
        final List<Product> sameCategory = productsProvider.products
            .where((p) => p.category == widget.product.category && p.id != widget.product.id)
            .toList();

        // 2. If we have less than 4, get other products to fill the slots
        final List<Product> similar = [...sameCategory];
        if (similar.length < 4) {
          final otherProducts = productsProvider.products
              .where((p) => p.id != widget.product.id && !similar.any((s) => s.id == p.id))
              .toList();
          
          similar.addAll(otherProducts.take(4 - similar.length));
        }

        final displayItems = similar.take(4).toList();

        if (displayItems.isEmpty) return const SizedBox();

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
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                final p = displayItems[index];
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
