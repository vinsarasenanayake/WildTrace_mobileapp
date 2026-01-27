import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/product_card.dart';

// Gallery Screen
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _selectedPhotographer = 'All Photographers';
  String _selectedCategory = 'All Collections';
  String _selectedSort = 'Latest Arrivals';

  int _currentPage = 1;
  final int _itemsPerPage = 9;
  
  final List<Map<String, String>> _allProducts = List.generate(18, (index) {
    final categories = ['REPTILES', 'BIRDS', 'MAMMALS', 'MARINE'];
    final titles = [
      'Emerald Green Tree Python', 
      'Kingfisher Dive', 
      'Elephant Walk', 
      'Coral Reefs',
      'Leopard Stare',
      'Lion Pride'
    ];
    final images = [
      'assets/images/owl.jpg',
      'assets/images/product2.jpg',
      'assets/images/product3.jpg',
      'assets/images/product4.jpg',
      'assets/images/product1.jpg',
      'assets/images/owl.jpg',
    ];

    return {
      'id': '$index',
      'image': images[index % images.length],
      'category': categories[index % categories.length],
      'title': titles[index % titles.length],
      'author': 'VINSARA SENANAYAKE',
      'price': '\$${(65 + index * 10)}.00',
    };
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? Colors.black : const Color(0xFFF9FBF9);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);

    final int startIndex = (_currentPage - 1) * _itemsPerPage;
    final int endIndex = (startIndex + _itemsPerPage < _allProducts.length) 
        ? startIndex + _itemsPerPage 
        : _allProducts.length;
    final List<Map<String, String>> displayedProducts = _allProducts.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            _buildFilterTab(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, 
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: displayedProducts.length,
                itemBuilder: (context, index) {
                  final product = displayedProducts[index];
                  return ProductCard(
                    imageUrl: product['image']!,
                    category: product['category']!,
                    title: product['title']!,
                    author: product['author']!,
                    price: product['price']!,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPaginationButton(
                    context, 
                    label: 'PREV', 
                    isActive: _currentPage > 1,
                    onTap: () {
                      if (_currentPage > 1) {
                        setState(() {
                          _currentPage--;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'PAGE $_currentPage OF 2',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 20),
                  _buildPaginationButton(
                    context, 
                    label: 'NEXT', 
                    isActive: endIndex < _allProducts.length,
                    onTap: () {
                      if (endIndex < _allProducts.length) {
                        setState(() {
                          _currentPage++;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

    );
  }

  Widget _buildPaginationButton(BuildContext context, {required String label, required bool isActive, required VoidCallback onTap}) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);

    return InkWell(
      onTap: isActive ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive ? textColor.withOpacity(0.3) : textColor.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isActive ? textColor : textColor.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/heroimagegallery.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF0F1E26),
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image, color: Colors.white24, size: 50),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'THE GALLERY',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF2ECC71),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'BRING THE',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -1.0,
                  ),
                ),
                Text(
                  'WILD HOME',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF2ECC71),
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "Explore our curated collection of fine art wildlife photography, capturing the fleeting beauty of nature's most untamed moments.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final Color barBackground = isDarkMode 
        ? const Color(0xFF1E1E1E) 
        : Colors.white;
    
    final Color labelColor = isDarkMode 
        ? Colors.grey.shade500 
        : Colors.grey.shade500;
        
    final Color valueColor = isDarkMode 
        ? Colors.white 
        : const Color(0xFF1B4332);
        
    final Color borderColor = isDarkMode 
        ? Colors.white.withOpacity(0.1) 
        : Colors.grey.shade200;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: barBackground,
          borderRadius: BorderRadius.circular(32), 
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildFilterRow(
              label: 'PHOTOGRAPHER:',
              value: _selectedPhotographer,
              labelColor: labelColor,
              valueColor: valueColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: borderColor),
            ),
            _buildFilterRow(
              label: 'CATEGORY:',
              value: _selectedCategory,
              labelColor: labelColor,
              valueColor: valueColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: borderColor),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterRow(
                  label: 'SORT BY:',
                  value: _selectedSort,
                  labelColor: labelColor,
                  valueColor: valueColor,
                  isCompact: true,
                ),
                TextButton(
                   onPressed: () {
                     setState(() {
                       _selectedPhotographer = 'All Photographers';
                       _selectedCategory = 'All Collections';
                     });
                   },
                   style: TextButton.styleFrom(
                     padding: EdgeInsets.zero,
                     minimumSize: Size.zero,
                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                   ),
                   child: Text(
                     'CLEAR FILTERS',
                     style: GoogleFonts.inter(
                       fontSize: 10,
                       fontWeight: FontWeight.bold,
                       letterSpacing: 1.0,
                       color: Colors.grey.shade400,
                     ),
                   ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterRow({
    required String label,
    required String value,
    required Color labelColor,
    required Color valueColor,
    bool isCompact = false,
  }) {
    return InkWell(
      onTap: () {},
      child: Row(
        mainAxisAlignment: isCompact ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                  letterSpacing: 1.0,
                ),
              ),
              if (isCompact) ...[
                const SizedBox(width: 8),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ]
            ],
          ),
          
          if (!isCompact)
            Row(
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: valueColor,
                ),
              ],
            )
          else 
             Padding(
               padding: const EdgeInsets.only(left: 4),
               child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: valueColor,
                ),
             ),
        ],
      ),
    ); 
  }
}
