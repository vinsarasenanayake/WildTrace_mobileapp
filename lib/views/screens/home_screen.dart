import 'dart:async';
import 'package:quickalert/quickalert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product.dart';
import '../../utils/responsive_helper.dart';
import 'journey_screen.dart';
import 'product_details_screen.dart';
import 'login_screen.dart';
import '../widgets/common/section_title.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/cards/product_card.dart';
import '../widgets/common/wild_trace_hero.dart';
import '../widgets/common/battery_status_indicator.dart';

// main home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  // builds the main application landing page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // immersive entry banner
                _buildHero(context),
                // high-value product showcase
                const FeaturedCollection(),
                // philosophical and background content
                const BehindTheLens(),
              ],
            ),
          ),
          // battery hardware status overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: const BatteryStatusIndicator(),
          ),
        ],
      ),
    );
  }

  // helper widget for the immersive welcome experience
  Widget _buildHero(BuildContext context) {
    return WildTraceHero(
      imagePath: 'assets/images/heroimageh1.jpg',
      title: 'THE HOME',
      mainText1: 'WILD',
      mainText2: 'TRACE',
      mainFontSize: 72,
      description: 'Fine-art wildlife photography',
      descriptionFontSize: 16,
      height: MediaQuery.of(context).size.height * 0.9,
      // initiates shopping navigation
      footer: CustomButton(
        text: 'EXPLORE COLLECTION',
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
  // controllers for product carousel
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  // restricts unauthorized favorite actions
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
              // dismiss feedback
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
              // primary redirection
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

  // initializes the infinite scroll carousel
  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0, initialPage: 1000);
  }

  // manages timer disposal to prevent memory leaks
  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // manages automated carousel progression
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

  // builds the high-priced product showcase
  @override
  Widget build(BuildContext context) {
    // design tokens based on theme and orientation
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isLandscape = ResponsiveHelper.isLandscape(context);
    final padding = ResponsiveHelper.getScreenPadding(context);
    
    // synchronizes with product and authentication state
    return Consumer3<ProductsProvider, FavoritesProvider, AuthProvider>(
      builder: (context, productsProvider, favoritesProvider, authProvider, child) {
        // selects top-tier products for the showcase
        final allProducts = List<Product>.from(productsProvider.products); 
        allProducts.sort((a, b) => b.price.compareTo(a.price)); 
        final featuredItems = allProducts.take(5).toList();
        
        // triggers autoplay sequence
        if (_timer == null && featuredItems.isNotEmpty) {
           _currentIndex = 1000 % featuredItems.length;
           _startAutoPlay(featuredItems.length);
        }

        if (featuredItems.isEmpty) return const SizedBox();

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: isLandscape ? 30 : 40, horizontal: padding.left),
          color: isDarkMode ? const Color(0xFF1B1B1B) : const Color(0xFFF9FBF9),
          child: Column(
            children: [
              // section branding
              Text(
                'FEATURED COLLECTION', 
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: const Color(0xFF27AE60))
              ),
              const SizedBox(height: 12),
              // adaptive heading
              Builder(
                builder: (context) {
                  final isLandscape = ResponsiveHelper.isLandscape(context);
                  return Text(
                    isLandscape ? 'Famous Wildlife Editions' : 'Famous Wildlife\nEditions', 
                    textAlign: TextAlign.center, 
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36, 
                      fontWeight: FontWeight.w400, 
                      fontStyle: FontStyle.italic, 
                      color: isDarkMode ? Colors.white : const Color(0xFF1B4332), 
                      height: 1.1
                    )
                  );
                }
              ),
              SizedBox(height: isLandscape ? 24 : 40),
              // main interaction point
              _buildSlideshow(featuredItems, isLandscape, favoritesProvider, authProvider),
              SizedBox(height: isLandscape ? 20 : 30),
              // progression feedback
              _buildIndicators(featuredItems.length),
            ],
          ),
        );
      }
    );
  }

  // builds the singular product carousel viewport
  Widget _buildSlideshow(List<Product> items, bool isLandscape, FavoritesProvider favoritesProvider, AuthProvider authProvider) {
    final double slideshowHeight = isLandscape ? 280 : 500;
    final double marginHorizontal = isLandscape ? 40 : 24;
    
    return Container(
      height: slideshowHeight,
      margin: EdgeInsets.symmetric(horizontal: marginHorizontal),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        // manages interactive flipping of products
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index % items.length),
          itemBuilder: (context, index) {
            final item = items[index % items.length];
            final isFavorite = favoritesProvider.isFavorite(item.id);
            
            return ProductCard(
              imageUrl: item.imageUrl,
              category: item.category,
              title: item.title,
              author: item.author,
              price: '\$${item.price.toStringAsFixed(2)}',
              isLiked: isFavorite,
              onLikeToggle: () {
                // requires verification for mutation
                if (authProvider.token == null) {
                  _showLoginRequiredAlert();
                } else {
                  favoritesProvider.toggleFavorite(item, token: authProvider.token);
                }
              },
              onTap: () {
                 // navigates to deep product detail
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

  // builds visual pagination dots
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
            color: isActive ? const Color(0xFF27AE60) : Colors.grey.withOpacity(0.3), 
            borderRadius: BorderRadius.circular(4)
          ),
        );
      }),
    );
  }
}

// philosophical and team narrative section
class BehindTheLens extends StatelessWidget {
  const BehindTheLens({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    const Color accentGreen = Color(0xFF27AE60);
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.isLandscape(context) ? 40 : 60, 
        horizontal: 24
      ),
      child: Column(
        children: [
          // section category header
          _buildSmallHeader(accentGreen),
          const SizedBox(height: 24),
          // primary section heading
          _buildMainHeading(textColor),
          const SizedBox(height: 24),
          // ethical mission statement
          _buildDescription(textColor, accentGreen),
          const SizedBox(height: 40),
          // workforce visual
          _buildTeamImage(),
          const SizedBox(height: 60),
          // media recognition banner
          _buildFeaturedBanner(textColor),
          const SizedBox(height: 40),
          // external validation logos
          _buildLogos(),
          const SizedBox(height: 60),
          // narrative exit navigation
          _buildJourneyButton(context, textColor),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // builds section title with decorative lines
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

  // builds main artistic heading
  Widget _buildMainHeading(Color textColor) {
    return Builder(
      builder: (context) {
        final isLandscape = ResponsiveHelper.isLandscape(context);
        return Text(
          isLandscape ? 'Capturing the Untamed Spirit.' : 'Capturing the\nUntamed Spirit.',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(fontSize: 42, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic, color: textColor, height: 1.1),
        );
      }
    );
  }

  // builds ethical and charity related information
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

  // builds workforce showcase
  Widget _buildTeamImage() {
    return Builder(
      builder: (context) {
        final isLandscape = ResponsiveHelper.isLandscape(context);
        return Container(
          height: isLandscape ? 200 : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.asset('assets/images/team.jpg', fit: BoxFit.cover)),
        );
      }
    );
  }

  // builds contextual labels for media logos
  Widget _buildFeaturedBanner(Color textColor) {
    return Text(
      'OUR PHOTOGRAPHERS ARE FEATURED IN',
      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: textColor.withOpacity(0.5)),
    );
  }

  // builds interactive social validation logos
  Widget _buildLogos() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildLogo('assets/images/natgeo.png', 100, 50, 'https://www.nationalgeographic.com/'), 
        _buildLogo('assets/images/bbcearth.jpg', 100, 50, 'https://www.bbcearth.com/'), 
        _buildLogo('assets/images/nhmwpy.jpg', 100, 50, 'https://www.nhm.ac.uk/wpy'), 
      ],
    );
  }

  // builds a singular external link logo
  Widget _buildLogo(String assetPath, double width, double height, String url) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        // navigates to external web reference
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Color(0xFF9E9E9E)),
        ),
      ),
    );
  }

  // builds CTA for philosophical deep dive
  Widget _buildJourneyButton(BuildContext context, Color textColor) {
    return OutlinedButton(
      onPressed: () {
        // navigates to narrative journey screen
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

