import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/products_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../utilities/responsive_helper.dart';
import '../widgets/common/common_widgets.dart';
import '../widgets/cards/card_widgets.dart';
import '../../services/api/index.dart';
import '../../controllers/auth_controller.dart';
import '../screens/login_screen.dart';
import 'package:quickalert/quickalert.dart';
import '../../utilities/alert_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String _selectedSize = '12 x 18 in';
  int _quantity = 1;
  double? _currentPrice;
  bool _isPriceLoading = false;
  Product? _fullProduct;
  final List<String> _sizes = [];
  final ProductApiService _apiService = ProductApiService();

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.product.price;

    // get sizes from options
    if (widget.product.options != null &&
        widget.product.options!['frames'] != null) {
      final List frames = widget.product.options!['frames'];
      for (var frame in frames) {
        if (frame['size'] != null) {
          _sizes.add(frame['size'].toString());
        }
      }
    }

    if (_sizes.isEmpty) {
      _sizes.addAll(['12 x 18 in', '18 x 24 in', '24 x 36 in', '40 x 60 in']);
    }

    _selectedSize = _sizes.first;

    _fetchPrice(_selectedSize);

    _fetchFullDetails();
  }

  Future<void> _fetchFullDetails() async {
    try {
      final authProvider = Provider.of<AuthController>(context, listen: false);
      final details = await _apiService.fetchProductDetails(
        widget.product.id,
        token: authProvider.token,
      );
      if (mounted && details != null) {
        setState(() {
          _fullProduct = details;
        });
      }
    } catch (e) {
    }
  }

  Future<void> _showLoginRequiredAlert() async {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    AlertService.showCustom(
      context: context,
      type: QuickAlertType.warning,
      title: 'Authentication Required',
      text: 'Please login to add items to your cart or favorites.',
      showConfirmBtn: false,
      widget: Column(
        children: [
          SizedBox(height: isLandscape ? 8 : 24),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'LATER',
                  fontSize: 10,
                  verticalPadding: isLandscape ? 8 : 12,
                  backgroundColor: isDarkMode
                      ? Colors.grey.withAlpha((0.2 * 255).round())
                      : Colors.grey.shade200,
                  foregroundColor: isDarkMode
                      ? Colors.white
                      : Colors.grey.shade800,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'LOGIN',
                  fontSize: 10,
                  verticalPadding: isLandscape ? 8 : 12,
                  backgroundColor: const Color(0xFF3498DB),
                  foregroundColor: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double? _calculateLocalPrice(String size) {
    if (widget.product.options != null &&
        widget.product.options!['frames'] != null) {
      final List frames = widget.product.options!['frames'];
      try {
        final frame = frames.firstWhere(
          (f) => f['size'].toString() == size,
          orElse: () => null,
        );
        if (frame != null && frame['price'] != null) {
          return double.tryParse(frame['price'].toString());
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // update price on size change
  Future<void> _fetchPrice(String size) async {
    setState(() => _isPriceLoading = true);

    // check local options first
    final localPrice = _calculateLocalPrice(size);
    if (localPrice != null) {
      if (mounted) {
        setState(() {
          _currentPrice = localPrice;
          _isPriceLoading = false;
        });
      }
      return;
    }

    try {
      final authProvider = Provider.of<AuthController>(context, listen: false);
      final newPrice = await _apiService.getProductPrice(
        widget.product.id,
        size,
        token: authProvider.token,
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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: isDarkMode
          ? Colors.black
          : const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? Colors.black
            : const Color(0xFFF9FBF9),
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
            _buildHeading(textColor, isLandscape),
            SizedBox(height: isLandscape ? 24 : 48),
            isLandscape
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildMainImage(isLandscape)),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildPurchaseOptions(
                          isDarkMode,
                          textColor,
                          isLandscape,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildMainImage(),
                      const SizedBox(height: 48),
                      _buildPurchaseOptions(isDarkMode, textColor),
                    ],
                  ),
            const SizedBox(height: 48),
            isLandscape
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildStory(textColor, isLandscape)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildPhotographerProfile()),
                    ],
                  )
                : Column(
                    children: [
                      _buildStory(textColor),
                      const SizedBox(height: 48),
                      _buildPhotographerProfile(),
                    ],
                  ),
            const SizedBox(height: 60),
            _buildSimilarWorks(textColor, isLandscape),
          ],
        ),
      ),
    );
  }

  Widget _buildHeading(Color textColor, [bool isLandscape = false]) {
    return Column(
      children: [
        SectionTitle(
          title: widget.product.category,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        const SizedBox(height: 16),
        Text(
          widget.product.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            color: textColor,
            fontSize: isLandscape ? 32 : 48,
            fontStyle: FontStyle.italic,
            height: 1.1,
          ),
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
                  color: Color(0xFF27AE60),
                  shape: BoxShape.circle,
                ),
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
      color: Colors.grey.shade500,
    ),
  );

  Widget _buildMainImage([bool isLandscape = false]) {
    return Container(
      height: 400,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: CachedImage(
          imageUrl: widget.product.imageUrl,
          fit: BoxFit.cover,
          borderRadius: 32,
        ),
      ),
    );
  }

  Widget _buildPurchaseOptions(
    bool isDarkMode,
    Color textColor, [
    bool isLandscape = false,
  ]) {
    final cartProvider = Provider.of<CartController>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MUSEUM GRADE PRINT',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          _isPriceLoading
              ? const SizedBox(
                  height: 44,
                  width: 44,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF27AE60),
                    ),
                  ),
                )
              : Text(
                  '\$${(_currentPrice ?? widget.product.price).toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
          const SizedBox(height: 32),
          Text(
            'SELECT SIZE',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 12),
          isLandscape
              ? Row(
                  children: _sizes
                      .map(
                        (s) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: _sizeBtn(s, isDarkMode, true),
                          ),
                        ),
                      )
                      .toList(),
                )
              : Builder(
                  builder: (context) {
                    final gridColumns = ResponsiveHelper.getGridCrossAxisCount(
                      context,
                      portrait: 2,
                    );
                    final spacing = ResponsiveHelper.getSpacing(
                      context,
                      portrait: 12,
                    );
                    return GridView.count(
                      padding: EdgeInsets.zero,
                      crossAxisCount: gridColumns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.5,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      children: _sizes
                          .map((s) => _sizeBtn(s, isDarkMode, false))
                          .toList(),
                    );
                  },
                ),
          const SizedBox(height: 32),
          Text(
            'QUANTITY',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              QuantitySelector(
                quantity: _quantity,
                onIncrement: () => setState(() => _quantity++),
                onDecrement: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
              ),
              const SizedBox(width: 24),
              Text(
                '$_quantity Items',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'ADD TO CART',
                  onPressed: () {
                    final auth = Provider.of<AuthController>(
                      context,
                      listen: false,
                    );
                    if (!auth.isAuthenticated) {
                      _showLoginRequiredAlert();
                      return;
                    }

                    cartProvider.addToCart(
                      widget.product,
                      quantity: _quantity,
                      size: _selectedSize,
                    );
                    final bool isDarkMode =
                        Theme.of(context).brightness == Brightness.dark;
                    AlertService.showCustom(
                      context: context,
                      type: QuickAlertType.success,
                      title: 'Added to Cart',
                      text:
                          '${widget.product.title} has been added to your cart.',
                      showConfirmBtn: false,
                      widget: Column(
                        children: [
                          SizedBox(height: isLandscape ? 8 : 24),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: 'CONTINUE',
                                  fontSize: 10,
                                  verticalPadding: isLandscape ? 8 : 12,
                                  backgroundColor: isDarkMode
                                      ? Colors.grey.withAlpha(
                                          (0.2 * 255).round(),
                                        )
                                      : Colors.grey.shade200,
                                  foregroundColor: isDarkMode
                                      ? Colors.white
                                      : Colors.grey.shade800,
                                  onPressed: () {
                                    Navigator.pop(context); 
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  text: 'VIEW CART',
                                  fontSize: 10,
                                  verticalPadding: isLandscape ? 8 : 12,
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  onPressed: () {
                                    final navProvider =
                                        Provider.of<NavigationController>(
                                          context,
                                          listen: false,
                                        );
                                    Navigator.of(
                                      context,
                                    ).popUntil((route) => route.isFirst);
                                    navProvider.setSelectedIndex(2);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  type: CustomButtonType.secondary,
                ),
              ),
              const SizedBox(width: 16),
              _favBtn(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sizeBtn(String size, bool isDarkMode, [bool isSmall = false]) {
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
        padding: isSmall ? const EdgeInsets.symmetric(vertical: 8) : null,
        decoration: BoxDecoration(
          color: sel
              ? const Color(0xFF27AE60).withAlpha((0.1 * 255).round())
              : Colors.transparent,
          border: Border.all(
            color: sel
                ? const Color(0xFF27AE60)
                : Colors.grey.withAlpha((0.2 * 255).round()),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          size,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: isSmall ? 10 : 12,
            fontWeight: FontWeight.bold,
            color: sel
                ? const Color(0xFF27AE60)
                : (isDarkMode ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _favBtn() {
    return Consumer2<FavoritesController, AuthController>(
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
              border: Border.all(
                color: Colors.grey.withAlpha((0.2 * 255).round()),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? const Color(0xFFE11D48) : Colors.grey.shade400,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStory(Color textColor, [bool isLandscape = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Behind the Lens', color: textColor),
        const SizedBox(height: 24),
        Text(
          widget.product.description ??
              "Every photograph in our collection is a testament to the untamed beauty of the natural world, captured with patience and respect.",
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.8,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        Builder(
          builder: (context) {
            final gridColumns = isLandscape
                ? 2
                : ResponsiveHelper.getGridCrossAxisCount(context, portrait: 2);
            final camera =
                widget.product.options?['camera'] as Map<String, dynamic>?;

            return GridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: gridColumns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3.0,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _stat(
                  'APERTURE',
                  (camera?['aperture'] ?? 'f/5.6').toString(),
                  textColor,
                ),
                _stat(
                  'SHUTTER',
                  (camera?['shutter'] ?? '1/4000s').toString(),
                  textColor,
                ),
                _stat('ISO', (camera?['iso'] ?? '800').toString(), textColor),
                _stat(
                  'FOCAL',
                  (camera?['focal'] ?? '85mm').toString(),
                  textColor,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _stat(String l, String v, Color c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        l,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade400,
        ),
      ),
      Text(
        v,
        style: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: c,
        ),
      ),
    ],
  );

  Widget _buildPhotographerProfile() {
    final product = _fullProduct ?? widget.product;
    return PhotographerCard(
      imagePath:
          product.authorImage != null && product.authorImage!.startsWith('http')
          ? product.authorImage!
          : 'assets/images/teammember1.jpg',
      name: product.author,
      role: product.profession ?? 'WILDLIFE PHOTOGRAPHER',
      quote:
          product.quote ??
          'Nature doesn\'t need a filter, it just needs a witness.',
      achievement: product.achievement ?? 'CANON AMBASSADOR',
      badgeText: 'DJMPC WINNER',
    );
  }

  // recommendation logic
  Widget _buildSimilarWorks(Color textColor, [bool isLandscape = false]) {
    return Consumer2<ProductsController, FavoritesController>(
      builder: (context, productsProvider, favoritesProvider, child) {
        final int itemCount = isLandscape ? 6 : 4;

        final List<Product> sameCategory = productsProvider.products
            .where(
              (p) =>
                  p.category == widget.product.category &&
                  p.id != widget.product.id,
            )
            .toList();

        // fills recommendation slots if category proximity is low
        final List<Product> similar = [...sameCategory];
        if (similar.length < itemCount) {
          final otherProducts = productsProvider.products
              .where(
                (p) =>
                    p.id != widget.product.id &&
                    !similar.any((s) => s.id == p.id),
              )
              .toList();

          similar.addAll(otherProducts.take(itemCount - similar.length));
        }

        final displayItems = similar.take(itemCount).toList();

        if (displayItems.isEmpty) return const SizedBox();

        return Column(
          children: [
            Text(
              'Similar Artifacts',
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontStyle: FontStyle.italic,
                color: textColor,
              ),
            ),
            const SizedBox(height: 32),
            Builder(
              builder: (context) {
                final gridColumns = isLandscape
                    ? 3
                    : ResponsiveHelper.getGridCrossAxisCount(
                        context,
                        portrait: 2,
                      );
                final spacing = ResponsiveHelper.getSpacing(
                  context,
                  portrait: 16,
                );
                final aspectRatio = ResponsiveHelper.getGridChildAspectRatio(
                  context,
                  portrait: 0.7,
                );
                return GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridColumns,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: spacing,
                    childAspectRatio: aspectRatio,
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
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsScreen(product: p),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
