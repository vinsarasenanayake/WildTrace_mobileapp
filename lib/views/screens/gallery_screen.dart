import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive_helper.dart';
import '../widgets/common/wild_trace_hero.dart';
import '../widgets/cards/product_card.dart';
import '../widgets/common/custom_button.dart';
import 'product_details_screen.dart';
import 'login_screen.dart';
import 'package:quickalert/quickalert.dart';
import '../widgets/common/battery_status_indicator.dart';

// main product gallery
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // global keys for UI control
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _filterKey = GlobalKey();
  
  // page and layout state
  int _currentPage = 1;
  final int _pageSize = 9;
  bool _showFiltersInLandscape = false; 

  // restricts access to member-only interactions
  Future<void> _showLoginRequiredAlert() async {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Authentication Required',
      text: 'Please login to add items to your cart or favorites.',
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      titleColor: isDarkMode ? Colors.white : Colors.black,
      textColor: isDarkMode ? Colors.white70 : Colors.black87,
      showConfirmBtn: false,
      showCancelBtn: false,
      widget: Column(
        children: [
          const SizedBox(height: 24),
          Row(
            children: [
              // rejection option
              Expanded(
                child: CustomButton(
                  text: 'LATER',
                  fontSize: 10,
                  verticalPadding: 12,
                  backgroundColor: isDarkMode ? Colors.grey.withOpacity(0.2) : Colors.grey.shade200,
                  foregroundColor: isDarkMode ? Colors.white : Colors.grey.shade800,
                  onPressed: () {
                    Navigator.pop(context); 
                  },
                ),
              ),
              const SizedBox(width: 12),
              // authentication redirection
              Expanded(
                child: CustomButton(
                  text: 'LOGIN',
                  fontSize: 10,
                  verticalPadding: 12,
                  backgroundColor: const Color(0xFF3498DB), 
                  foregroundColor: Colors.white,
                  onPressed: () {
                    Navigator.pop(context); 
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
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

  // builds the main gallery interface with state synchronization
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // consumes multiple providers for product and user state
    return Consumer3<ProductsProvider, FavoritesProvider, AuthProvider>(
      builder: (context, productsProvider, favoritesProvider, authProvider, child) {
        final products = productsProvider.filteredProducts;

        // calculates pagination offsets
        final int start = (_currentPage - 1) * _pageSize;
        // ensures page index validity after filter changes
        if (start >= products.length && _currentPage > 1) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted) setState(() => _currentPage = 1);
           });
        }
        
        final int end = (start + _pageSize < products.length) ? start + _pageSize : products.length;
        final pageItems = products.isNotEmpty ? products.sublist(
          start.clamp(0, products.length), 
          end.clamp(0, products.length)
        ) : [];

        return Stack(
          children: [
            Scaffold(
              key: _scaffoldKey,
              drawer: _buildFilterDrawer(context, isDarkMode, productsProvider),
              backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
              body: RefreshIndicator(
                onRefresh: () async {
                  await productsProvider.fetchProducts();
                  if (authProvider.token != null) {
                    await favoritesProvider.fetchFavorites(authProvider.token!);
                  }
                },
                color: const Color(0xFF27AE60),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHero()),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildFilterTrigger(isDarkMode),
                          if (products.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Text(
                                    'No products found.',
                                    style: GoogleFonts.inter(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 20),
                                  CustomButton(
                                    text: 'REFRESH GALLERY',
                                    onPressed: () => productsProvider.fetchProducts(),
                                    type: CustomButtonType.secondary,
                                    isFullWidth: false,
                                  ),
                                ],
                              ),
                            )
                          else 
                            _buildGrid(pageItems, favoritesProvider),
                          if (products.isNotEmpty)
                            _buildPagination(isDarkMode, end < products.length),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 20,
              child: const BatteryStatusIndicator(),
            ),
          ],
        );
      },
    );
  }

  // builds the visual marquee for the gallery
  Widget _buildHero() {
    return const WildTraceHero(
      imagePath: 'assets/images/heroimagegallery.jpg',
      title: 'THE GALLERY',
      mainText1: 'BRING THE',
      mainText2: 'WILD HOME',
      description: 'Explore our curated collection of fine art wildlife photography.',
      verticalAlignment: MainAxisAlignment.center,
    );
  }

  // scrolls the viewport to position filter controls at the top
  void _scrollToFilters() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_filterKey.currentContext != null) {
        final RenderBox? renderBox = _filterKey.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = _scrollController.position;
          final targetOffset = renderBox.localToGlobal(Offset.zero, ancestor: null).dy;
          final scrollOffset = position.pixels + targetOffset - 100; // maintains visibility offset
          
          _scrollController.animateTo(
            scrollOffset.clamp(position.minScrollExtent, position.maxScrollExtent),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutSine,
          );
        }
      }
    });
  }

  // manages the display and interaction of filter entry points
  Widget _buildFilterTrigger(bool isDarkMode) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    if (isLandscape) {
      // provides inline horizontal controls for wide screens
      return Consumer<ProductsProvider>(
        builder: (context, provider, child) {
          final Color txtColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
          final Color accentGreen = const Color(0xFF27AE60);
          
          if (_showFiltersInLandscape) {
            // renders expanded horizontal filter toolbar
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFEEEEEE),
                border: Border(
                  bottom: BorderSide(color: txtColor.withOpacity(0.1), width: 1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // photographer selection
                  Expanded(
                    child: _buildHorizontalFilterItem(
                      'PHOTOGRAPHER',
                      provider.selectedAuthor,
                      provider.authors,
                      (val) {
                        provider.setAuthor(val!);
                        setState(() => _currentPage = 1);
                      },
                      txtColor,
                      accentGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // theme/category selection
                  Expanded(
                    child: _buildHorizontalFilterItem(
                      'CATEGORY',
                      provider.selectedCategory,
                      provider.categories,
                      (val) {
                        provider.setCategory(val!);
                        setState(() => _currentPage = 1);
                      },
                      txtColor,
                      accentGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // sorting configuration
                  Expanded(
                    child: _buildHorizontalFilterItem(
                      'SORT BY',
                      provider.sortOption,
                      ['Latest Arrivals', 'Price: Low to High', 'Price: High to Low', 'Name: A-Z'],
                      (val) => provider.setSortOption(val!),
                      txtColor,
                      accentGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // reset all modifications
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        provider.clearFilters();
                        setState(() {
                          _currentPage = 1;
                          _showFiltersInLandscape = false;
                        });
                      },
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: txtColor.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'CLEAR',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: txtColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // provides concise access button
            return Padding(
              key: _filterKey,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showFiltersInLandscape = true;
                  });
                },
                child: Row(
                  children: [
                    Icon(Icons.tune, size: 20, color: txtColor),
                    const SizedBox(width: 8),
                    Text(
                      'FILTERS',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: txtColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      );
    } else {
      // provides mobile-optimized drawer trigger
      return Padding(
        key: _filterKey,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: InkWell(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Row(
            children: [
              Icon(Icons.tune, size: 20, color: isDarkMode ? Colors.white : const Color(0xFF1B4332)),
              const SizedBox(width: 8),
              Text(
                'FILTERS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: isDarkMode ? Colors.white : const Color(0xFF1B4332),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // builds a singular horizontal dropdown for landscape filtering
  Widget _buildHorizontalFilterItem(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
    Color txtColor,
    Color labelColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: txtColor.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(8),
            color: txtColor.withOpacity(0.05),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : options.first,
              isExpanded: true,
              dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
              icon: Icon(Icons.keyboard_arrow_down, size: 16, color: txtColor),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: txtColor,
              ),
              items: options.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(
                    opt,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 11),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // builds the dedicated drawer for comprehensive filtering in portrait mode
  Widget _buildFilterDrawer(BuildContext context, bool isDarkMode, ProductsProvider provider) {
    final Color txtColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    final Color accentGreen = const Color(0xFF27AE60);

    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drawer header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'FILTERS',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: txtColor,
                ),
              ),
            ),
            Divider(height: 1, color: txtColor.withOpacity(0.1)),
            // vertical list of filter options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _drawerFilterItem(
                    'PHOTOGRAPHER', 
                    provider.selectedAuthor, 
                    provider.authors,
                    (val) {
                      provider.setAuthor(val!);
                      setState(() => _currentPage = 1);
                    },
                    txtColor, 
                    accentGreen
                  ),
                  const SizedBox(height: 32),
                  _drawerFilterItem(
                    'CATEGORY', 
                    provider.selectedCategory, 
                    provider.categories,
                    (val) {
                      provider.setCategory(val!);
                      setState(() => _currentPage = 1);
                    },
                    txtColor, 
                    accentGreen
                  ),
                  const SizedBox(height: 32),
                  _drawerFilterItem(
                    'SORT BY', 
                    provider.sortOption, 
                    ['Latest Arrivals', 'Price: Low to High', 'Price: High to Low', 'Name: A-Z'],
                    (val) => provider.setSortOption(val!),
                    txtColor, 
                    accentGreen
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: txtColor.withOpacity(0.1)),
            // reset mechanism
            Padding(
              padding: const EdgeInsets.all(24),
              child: InkWell(
                onTap: () {
                  provider.clearFilters();
                  setState(() => _currentPage = 1);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: txtColor.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'CLEAR FILTERS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: txtColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // builds a vertical filter selector for the side drawer
  Widget _drawerFilterItem(String label, String value, List<String> options, ValueChanged<String?> onChanged, Color txtColor, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: txtColor.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(12),
            color: txtColor.withOpacity(0.05),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : options.first,
              isExpanded: true,
              dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
              icon: Icon(Icons.keyboard_arrow_down, size: 20, color: txtColor),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: txtColor,
              ),
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // builds a responsive grid of product cards
  Widget _buildGrid(List<dynamic> pageItems, FavoritesProvider favoritesProvider) {
    final isLandscape = ResponsiveHelper.isLandscape(context);
    final crossAxisCount = isLandscape ? 3 : 1; 
    final spacing = ResponsiveHelper.getSpacing(context, portrait: 24);
    final padding = ResponsiveHelper.getScreenPadding(context);
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: padding,
          child: GridView.builder(
            padding: EdgeInsets.zero, 
            shrinkWrap: true, 
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing, 
              crossAxisSpacing: isLandscape ? spacing : 0,
              childAspectRatio: isLandscape ? 0.85 : 0.8
            ),
            itemCount: pageItems.length,
            itemBuilder: (context, index) {
              final p = pageItems[index];
              final isFavorite = favoritesProvider.isFavorite(p.id);
              
              return ProductCard(
                imageUrl: p.imageUrl, 
                category: p.category, 
                title: p.title, 
                author: p.author, 
                price: '\$${p.price.toStringAsFixed(2)}',
                isLiked: isFavorite,
                onLikeToggle: () {
                  // verifies authentication before state mutation
                  if (authProvider.token == null) {
                    _showLoginRequiredAlert();
                  } else {
                    favoritesProvider.toggleFavorite(p, token: authProvider.token);
                  }
                },
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p))),
              );
            },
          ),
        );
      },
    );
  }

  // builds the pagination control toolbar
  Widget _buildPagination(bool isDarkMode, bool hasNext) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageBtn('PREV', _currentPage > 1, () {
            setState(() => _currentPage--);
            _scrollToFilters();
          }),
          const SizedBox(width: 20),
          Text(
            'PAGE $_currentPage', 
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500)
          ),
          const SizedBox(width: 20),
          _pageBtn('NEXT', hasNext, () {
            setState(() => _currentPage++);
            _scrollToFilters();
          }),
        ],
      ),
    );
  }

  // builds a singular pagination button with active/disabled states
  Widget _pageBtn(String label, bool active, VoidCallback onTap) {
    final Color color = Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1B4332);
    return InkWell(
      onTap: active ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: active ? color.withOpacity(0.3) : color.withOpacity(0.1)), 
          borderRadius: BorderRadius.circular(30)
        ),
        child: Text(
          label, 
          style: GoogleFonts.inter(
            fontSize: 11, 
            fontWeight: FontWeight.bold, 
            color: active ? color : color.withOpacity(0.3)
          )
        ),
      ),
    );
  }

  // cleans up scroll listeners
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

