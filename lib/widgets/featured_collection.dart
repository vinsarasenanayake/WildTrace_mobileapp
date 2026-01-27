import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'featured_item.dart';
class FeaturedCollection extends StatefulWidget {
  final List<Map<String, String>> items;

  const FeaturedCollection({
    super.key,
    required this.items,
  });

  @override
  State<FeaturedCollection> createState() => _FeaturedCollectionState();
}
class _FeaturedCollectionState extends State<FeaturedCollection> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0, initialPage: 1000);
    _currentIndex = 1000 % widget.items.length;
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(duration: const Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      color: isDarkMode ? const Color(0xFF1B1B1B) : const Color(0xFFF9FBF9),
      child: Column(
        children: [
          Text('FEATURED COLLECTION', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: const Color(0xFF2ECC71))),
          const SizedBox(height: 12),
          Text('Famous Wildlife\nEditions', textAlign: TextAlign.center, style: GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic, color: isDarkMode ? Colors.white : const Color(0xFF1B4332), height: 1.1)),
          const SizedBox(height: 40),
          _buildSlideshow(),
          const SizedBox(height: 30),
          _buildIndicators(),
        ],
      ),
    );
  }
  Widget _buildSlideshow() {
    return Container(
      height: 500,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index % widget.items.length),
          itemBuilder: (context, index) {
            final item = widget.items[index % widget.items.length];
            return FeaturedItem(
              imageUrl: item['image'] ?? '',
              category: item['category'] ?? '',
              title: item['title'] ?? '',
              location: item['location'] ?? '',
              price: item['price'] ?? '',
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.items.length, (index) {
        final bool isActive = _currentIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: isActive ? 32 : 8,
          decoration: BoxDecoration(color: isActive ? const Color(0xFF2ECC71) : Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
        );
      }),
    );
  }
}
