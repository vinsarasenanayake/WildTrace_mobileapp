import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/featured_item.dart';
import '../widgets/home_hero.dart';
import '../widgets/behind_the_lens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  // Collection Mock Data
  final List<Map<String, String>> _collectionItems = [
    {'image': 'assets/images/product14.jpg', 'category': 'BIRDS', 'title': 'Owl in Twilight', 'location': 'YALA NATIONAL PARK', 'year': '2020', 'price': '\$140.00'},
    {'image': 'assets/images/product2.jpg', 'category': 'REPTILES', 'title': 'Green Serpent', 'location': 'SINHARAJA RAINFOREST', 'year': '2021', 'price': '\$120.00'},
    {'image': 'assets/images/product3.jpg', 'category': 'MAMMALS', 'title': 'Elephant Walk', 'location': 'AMBOSELI RESERVE', 'year': '2019', 'price': '\$340.00'},
    {'image': 'assets/images/product4.jpg', 'category': 'MARINE', 'title': 'Coral Reefs', 'location': 'GREAT BARRIER REEF', 'year': '2022', 'price': '\$220.00'},
    {'image': 'assets/images/product1.jpg', 'category': 'BIRDS', 'title': 'Kingfisher Dive', 'location': 'TARANGIRE', 'year': '2020', 'price': '\$180.00'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0, initialPage: 1000);
    _currentIndex = 1000 % _collectionItems.length;
    _startAutoPlay(); // Start slideshow
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

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF9FBF9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HomeHero(), // Hero Section Widget
            _buildFeaturedCollection(context), // Horizontal Slideshow
            const BehindTheLens(), // Info Section Widget
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCollection(BuildContext context) {
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
          _buildSlideshow(), // Paged content
          const SizedBox(height: 30),
          _buildIndicators(), // Dots
        ],
      ),
    );
  }

  Widget _buildSlideshow() {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index % _collectionItems.length),
          itemBuilder: (context, index) {
            final item = _collectionItems[index % _collectionItems.length];
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
      children: List.generate(_collectionItems.length, (index) {
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
