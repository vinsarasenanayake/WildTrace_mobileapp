// --- Imports ---
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/wild_trace_hero.dart';
import '../widgets/section_title.dart';
import 'product_details_screen.dart';
import '../widgets/product_card.dart';

// --- Screen ---
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

// --- State ---
class _GalleryScreenState extends State<GalleryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _filterKey = GlobalKey();
  String _author = 'All Photographers', _category = 'All Collections', _sort = 'Latest Arrivals';
  int _currentPage = 1;
  final int _pageSize = 9;
  final List<Map<String, String>> _items = [
    {'id': '2', 'image': 'assets/images/product2.jpg', 'category': 'MARINE', 'title': 'Clownfish Haven', 'author': 'Vinsara Senanayake', 'price': '\$80.00'},
    {'id': '3', 'image': 'assets/images/product3.jpg', 'category': 'MAMMALS', 'title': 'Lion Portrait', 'author': 'Vinsara Senanayake', 'price': '\$120.00'},
    {'id': '4', 'image': 'assets/images/product4.jpg', 'category': 'INSECTS', 'title': 'Blue Butterfly', 'author': 'Vinsara Senanayake', 'price': '\$55.00'},
    {'id': '5', 'image': 'assets/images/product5.jpg', 'category': 'BIRDS', 'title': 'Scarlet Macaw', 'author': 'Vinsara Senanayake', 'price': '\$90.00'},
    {'id': '6', 'image': 'assets/images/product6.jpg', 'category': 'REPTILES', 'title': 'Red-Eyed Tree Frog', 'author': 'Vinsara Senanayake', 'price': '\$70.00'},
    {'id': '7', 'image': 'assets/images/product7.jpg', 'category': 'FLORA', 'title': 'Purple Orchid', 'author': 'Vinsara Senanayake', 'price': '\$45.00'},
    {'id': '8', 'image': 'assets/images/product8.jpg', 'category': 'MAMMALS', 'title': 'African Elephant', 'author': 'Vinsara Senanayake', 'price': '\$150.00'},
    {'id': '9', 'image': 'assets/images/product9.jpg', 'category': 'BIRDS', 'title': 'Kingfisher Dive', 'author': 'Vinsara Senanayake', 'price': '\$110.00'},
    {'id': '10', 'image': 'assets/images/product10.jpg', 'category': 'REPTILES', 'title': 'Komodo Dragon', 'author': 'Vinsara Senanayake', 'price': '\$130.00'},
    {'id': '11', 'image': 'assets/images/product11.jpg', 'category': 'MARINE', 'title': 'Sea Turtle', 'author': 'Vinsara Senanayake', 'price': '\$95.00'},
    {'id': '12', 'image': 'assets/images/product12.jpg', 'category': 'MAMMALS', 'title': 'Leopard Drag', 'author': 'Vinsara Senanayake', 'price': '\$140.00'},
    {'id': '13', 'image': 'assets/images/product13.jpg', 'category': 'MACRO', 'title': 'Autumn Leaves', 'author': 'Vinsara Senanayake', 'price': '\$60.00'},
    {'id': '14', 'image': 'assets/images/product14.jpg', 'category': 'BIRDS', 'title': 'Little Owl', 'author': 'Vinsara Senanayake', 'price': '\$85.00'},
    {'id': '15', 'image': 'assets/images/product15.jpg', 'category': 'LANDSCAPE', 'title': 'Baobab Sunset', 'author': 'Vinsara Senanayake', 'price': '\$100.00'},
    {'id': '16', 'image': 'assets/images/product16.jpg', 'category': 'AMPHIBIANS', 'title': 'Blue Dart Frog', 'author': 'Vinsara Senanayake', 'price': '\$75.00'},
    {'id': '17', 'image': 'assets/images/product17.jpg', 'category': 'MAMMALS', 'title': 'Giraffe Gaze', 'author': 'Vinsara Senanayake', 'price': '\$115.00'},
    {'id': '18', 'image': 'assets/images/product18.jpg', 'category': 'MARINE', 'title': 'Coral Reef Life', 'author': 'Vinsara Senanayake', 'price': '\$105.00'},
  ];

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final int start = (_currentPage - 1) * _pageSize;
    final int end = (start + _pageSize < _items.length) ? start + _pageSize : _items.length;
    final List<Map<String, String>> pageItems = _items.sublist(start, end);

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildFilterDrawer(isDarkMode),
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildHero()),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildFilterTrigger(isDarkMode),
                _buildGrid(pageItems),
                _buildPagination(isDarkMode, end < _items.length),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Methods ---
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

  Widget _buildFilterDrawer(bool isDarkMode) {
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
                    _author, 
                    ['All Photographers', 'Vinsara Senanayake', 'Kumara Senanayake'],
                    (val) => setState(() => _author = val!),
                    txtColor, 
                    accentGreen
                  ),
                  const SizedBox(height: 32),
                  _drawerFilterItem(
                    'CATEGORY', 
                    _category, 
                    ['All Collections', 'MARINE', 'MAMMALS', 'INSECTS', 'BIRDS', 'REPTILES', 'FLORA', 'MACRO', 'LANDSCAPE', 'AMPHIBIANS'],
                    (val) => setState(() => _category = val!),
                    txtColor, 
                    accentGreen
                  ),
                  const SizedBox(height: 32),
                  _drawerFilterItem(
                    'SORT BY', 
                    _sort, 
                    ['Latest Arrivals', 'Price: Low to High', 'Price: High to Low'],
                    (val) => setState(() => _sort = val!),
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
                onTap: () => setState(() {
                  _author = 'All Photographers';
                  _category = 'All Collections';
                  _sort = 'Latest Arrivals';
                  Navigator.pop(context);
                }),
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
              value: value,
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

  Widget _buildGrid(List<Map<String, String>> pageItems) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: GridView.builder(
        padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, mainAxisSpacing: 24, childAspectRatio: 0.8),
        itemCount: pageItems.length,
        itemBuilder: (context, index) {
          final p = pageItems[index];
          return ProductCard(
            imageUrl: p['image']!, category: p['category']!, title: p['title']!, author: p['author']!, price: p['price']!,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(title: p['title']!, category: p['category']!, author: p['author']!, price: p['price']!, imageUrl: p['image']!))),
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
          Text('PAGE $_currentPage OF 2', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
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
        decoration: BoxDecoration(border: Border.all(color: active ? color.withOpacity(0.3) : color.withOpacity(0.1)), borderRadius: BorderRadius.circular(30)),
        child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: active ? color : color.withOpacity(0.3))),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// --- Widgets ---

