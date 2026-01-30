// Imports
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';
import '../widgets/common/wild_trace_hero.dart';
import '../widgets/cards/product_card.dart';
import 'product_details_screen.dart';

// Gallery Screen
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

// Gallery Screen State
class _GalleryScreenState extends State<GalleryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _filterKey = GlobalKey();
  
  int _currentPage = 1;
  final int _pageSize = 9;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Consume providers
    return Consumer3<ProductsProvider, FavoritesProvider, AuthProvider>(
      builder: (context, productsProvider, favoritesProvider, authProvider, child) {
        final products = productsProvider.filteredProducts;

        // Pagination logic
        final int start = (_currentPage - 1) * _pageSize;
        // Reset page if filtered results are less than current page start
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

        return Scaffold(
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
            color: const Color(0xFF2ECC71),
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
                              ElevatedButton(
                                onPressed: () => productsProvider.fetchProducts(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2ECC71),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('REFRESH GALLERY'),
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
        );
      },
    );
  }

  // Helper Methods
  Widget _buildHero() {
    return const WildTraceHero(
      imagePath: 'assets/images/heroimagegallery.jpg',
      title: 'THE GALLERY',
      mainText1: 'BRING THE',
      mainText2: 'WILD HOME',
      description: 'Explore our curated collection of fine art wildlife photography.',
    );
  }

  void _scrollToFilters() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_filterKey.currentContext != null) {
        final RenderBox? renderBox = _filterKey.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = _scrollController.position;
          final targetOffset = renderBox.localToGlobal(Offset.zero, ancestor: null).dy;
          final scrollOffset = position.pixels + targetOffset - 100; // 100px padding from top
          
          _scrollController.animateTo(
            scrollOffset.clamp(position.minScrollExtent, position.maxScrollExtent),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutSine,
          );
        }
      }
    });
  }

  Widget _buildFilterTrigger(bool isDarkMode) {
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

  Widget _buildFilterDrawer(BuildContext context, bool isDarkMode, ProductsProvider provider) {
    final Color txtColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    final Color accentGreen = const Color(0xFF2ECC71);

    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

  Widget _buildGrid(List<dynamic> pageItems, FavoritesProvider favoritesProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: GridView.builder(
        padding: EdgeInsets.zero, 
        shrinkWrap: true, 
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, 
          mainAxisSpacing: 24, 
          childAspectRatio: 0.8
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
            onLikeToggle: () => favoritesProvider.toggleFavorite(p),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p))),
          );
        },
      ),
    );
  }

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
