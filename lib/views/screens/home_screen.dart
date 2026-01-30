// Imports
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/products_provider.dart';
import '../../models/product.dart';
import 'journey_screen.dart';
import 'product_details_screen.dart';
import '../widgets/common/section_title.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/cards/featured_item_card.dart';
import '../widgets/common/wild_trace_hero.dart';

// Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  // Build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            const FeaturedCollection(),
            const BehindTheLens(),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  Widget _buildHero(BuildContext context) {
    return WildTraceHero(
      imagePath: 'assets/images/heroimageh1.jpg',
      mainText1: 'WILD',
      mainText2: 'TRACE',
      mainFontSize: 72,
      mainLetterSpacing1: 14.0,
      mainLetterSpacing2: -1.5,
      subtitleQuote: '“WILDLIFE. UNTAMED. TIMELESS.”',
      description: 'Fine-art wildlife photographs captured in the wild, available as prints.',
      height: MediaQuery.of(context).size.height * 0.9,
      footer: CustomButton(
        text: 'VIEW GALLERY',
        onPressed: () => context.read<NavigationProvider>().setSelectedIndex(1),
        type: CustomButtonType.secondary,
        isFullWidth: false,
        fontSize: 12,
        verticalPadding: 16,
      ),
    );
  }

}

// Featured Collection Widget
class FeaturedCollection extends StatefulWidget {
  const FeaturedCollection({super.key});

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
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay(int itemCount) {
    _timer?.cancel();
    if (itemCount > 0) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients) {
          _pageController.nextPage(duration: const Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        // Get featured items (first 5 for now)
        final featuredItems = productsProvider.products.take(5).toList();
        
        // Start autoplay if not started and we have items
        if (_timer == null && featuredItems.isNotEmpty) {
           _currentIndex = 1000 % featuredItems.length;
           _startAutoPlay(featuredItems.length);
        }

        if (featuredItems.isEmpty) return const SizedBox();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          color: isDarkMode ? const Color(0xFF1B1B1B) : const Color(0xFFF9FBF9),
          child: Column(
            children: [
              Text(
                'FEATURED COLLECTION', 
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: const Color(0xFF2ECC71))
              ),
              const SizedBox(height: 12),
              Text(
                'Famous Wildlife\nEditions', 
                textAlign: TextAlign.center, 
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36, 
                  fontWeight: FontWeight.w400, 
                  fontStyle: FontStyle.italic, 
                  color: isDarkMode ? Colors.white : const Color(0xFF1B4332), 
                  height: 1.1
                )
              ),
              const SizedBox(height: 40),
              _buildSlideshow(featuredItems),
              const SizedBox(height: 30),
              _buildIndicators(featuredItems.length),
            ],
          ),
        );
      }
    );
  }

  Widget _buildSlideshow(List<Product> items) {
    return Container(
      height: 500,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index % items.length),
          itemBuilder: (context, index) {
            final item = items[index % items.length];
            return FeaturedItemCard(
              imageUrl: item.imageUrl,
              category: item.category,
              title: item.title,
              location: item.location?.toUpperCase() ?? 'WILDERNESS',
              price: '\$${item.price.toStringAsFixed(2)}',
              onTap: () {
                 Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: item))
                 );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool isActive = (_currentIndex % count) == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: isActive ? 32 : 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2ECC71) : Colors.grey.withOpacity(0.3), 
            borderRadius: BorderRadius.circular(4)
          ),
        );
      }),
    );
  }
}

// Behind The Lens Widget
class BehindTheLens extends StatelessWidget {
  const BehindTheLens({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    const Color accentGreen = Color(0xFF2ECC71);
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          _buildSmallHeader(accentGreen),
          const SizedBox(height: 24),
          _buildMainHeading(textColor),
          const SizedBox(height: 24),
          _buildDescription(textColor, accentGreen),
          const SizedBox(height: 40),
          _buildTeamImage(),
          const SizedBox(height: 60),
          _buildFeaturedBanner(textColor),
          const SizedBox(height: 40),
          _buildLogos(),
          const SizedBox(height: 60),
          _buildJourneyButton(context, textColor),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSmallHeader(Color accentGreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 40, height: 1, color: accentGreen.withOpacity(0.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'BEHIND THE LENS',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: accentGreen),
          ),
        ),
        Container(width: 40, height: 1, color: accentGreen.withOpacity(0.5)),
      ],
    );
  }

  Widget _buildMainHeading(Color textColor) {
    return Text(
      'Capturing the\nUntamed Spirit.',
      textAlign: TextAlign.center,
      style: GoogleFonts.playfairDisplay(fontSize: 42, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic, color: textColor, height: 1.1),
    );
  }

  Widget _buildDescription(Color textColor, Color accentGreen) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.inter(fontSize: 15, height: 1.6, color: textColor.withOpacity(0.8)),
        children: [
          const TextSpan(text: 'Every photograph in this gallery is captured ethically in the wild without disturbing the dignity of the animal. When you acquire a WildTrace print, you are supporting the preservation of these magnificent creatures—\n'),
          TextSpan(text: '10% of every sale is donated directly to wildlife conservation efforts.', style: TextStyle(color: accentGreen, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTeamImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.asset('assets/images/team.jpg', fit: BoxFit.cover)),
    );
  }

  Widget _buildFeaturedBanner(Color textColor) {
    return Text(
      'OUR PHOTOGRAPHERS ARE FEATURED IN',
      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: textColor.withOpacity(0.5)),
    );
  }

  Widget _buildLogos() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLogo('assets/images/natgeo.png', 90, 'https://www.nationalgeographic.com/'), 
        _buildLogo('assets/images/bbcearth.jpg', 50, 'https://www.bbcearth.com/'), 
        _buildLogo('assets/images/nhmwpy.jpg', 80, 'https://www.nhm.ac.uk/wpy'), 
      ],
    );
  }

  Widget _buildLogo(String assetPath, double width, String url) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      child: Image.asset(
        assetPath,
        width: width,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Color(0xFF9E9E9E)),
      ),
    );
  }

  Widget _buildJourneyButton(BuildContext context, Color textColor) {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const JourneyScreen()));
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: textColor.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('LEARN MORE ABOUT OUR JOURNEY', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: textColor)),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 14, color: textColor),
        ],
      ),
    );
  }
}
