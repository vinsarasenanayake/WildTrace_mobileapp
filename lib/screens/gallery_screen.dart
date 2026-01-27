import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // Discovery State
  String _author = 'All Photographers', _category = 'All Collections', _sort = 'Latest Arrivals';
  int _currentPage = 1;
  final int _pageSize = 9;
  
  // Gallery Collection
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

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final int start = (_currentPage - 1) * _pageSize;
    final int end = (start + _pageSize < _items.length) ? start + _pageSize : _items.length;
    final List<Map<String, String>> pageItems = _items.sublist(start, end);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF9FBF9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(), // Full Screen Intro
            _buildFilters(isDarkMode), // Refine Search
            _buildGrid(pageItems), // Photography Display
            _buildPagination(isDarkMode, end < _items.length), // List Controls
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      height: MediaQuery.of(context).size.height, width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/heroimagegallery.jpg', fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: const Color(0xFF0F1E26))),
          Container(color: Colors.black.withOpacity(0.6)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('THE GALLERY', style: GoogleFonts.inter(color: const Color(0xFF2ECC71), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 3.0)),
                const SizedBox(height: 24),
                Text('BRING THE', style: GoogleFonts.inter(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, height: 1.0, letterSpacing: -1.0)),
                Text('WILD HOME', style: GoogleFonts.inter(color: const Color(0xFF2ECC71), fontSize: 48, fontWeight: FontWeight.w900, height: 1.0, letterSpacing: -1.0)),
                const SizedBox(height: 32),
                Text("Explore our curated collection of fine art wildlife photography.", textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 16, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDarkMode) {
    final Color barBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color txtColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    final Color border = isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade200;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: barBg, borderRadius: BorderRadius.circular(32), border: Border.all(color: border), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          children: [
            _filterRow('PHOTOGRAPHER:', _author, txtColor),
            Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: border)),
            _filterRow('CATEGORY:', _category, txtColor),
            Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: border)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _filterRow('SORT BY:', _sort, txtColor, isCompact: true),
                TextButton(onPressed: () => setState(() { _author = 'All'; _category = 'All'; }), child: Text('CLEAR FILTERS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterRow(String label, String value, Color color, {bool isCompact = false}) {
    return InkWell(
      onTap: () {},
      child: Row(
        mainAxisAlignment: isCompact ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.0)),
            if (isCompact) ...[const SizedBox(width: 8), Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color))],
          ]),
          if (!isCompact) Row(children: [Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)), const SizedBox(width: 8), Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: color)])
          else Padding(padding: const EdgeInsets.only(left: 4), child: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: color)),
        ],
      ),
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
          _pageBtn('PREV', _currentPage > 1, () => setState(() => _currentPage--)),
          const SizedBox(width: 20),
          Text('PAGE $_currentPage OF 2', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
          const SizedBox(width: 20),
          _pageBtn('NEXT', hasNext, () => setState(() => _currentPage++)),
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
}
