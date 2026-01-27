import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/navigation_provider.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Collection State
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  final List<Map<String, String>> _collectionItems = [
    {
      'image': 'assets/images/owl.jpg', 
      'category': 'BIRDS',
      'title': 'Owl in Twilight',
      'location': 'YALA NATIONAL PARK',
      'year': '2020',
      'price': '\$140.00',
    },
    {
      'image': 'assets/images/product2.jpg',
      'category': 'REPTILES',
      'title': 'Green Serpent',
      'location': 'SINHARAJA RAINFOREST',
      'year': '2021',
      'price': '\$120.00',
    },
    {
      'image': 'assets/images/product3.jpg',
      'category': 'MAMMALS',
      'title': 'Elephant Walk',
      'location': 'AMBOSELI RESERVE',
      'year': '2019',
      'price': '\$340.00',
    },
    {
      'image': 'assets/images/product4.jpg',
      'category': 'MARINE',
      'title': 'Coral Reefs',
      'location': 'GREAT BARRIER REEF',
      'year': '2022',
      'price': '\$220.00',
    },
     {
      'image': 'assets/images/product1.jpg',
      'category': 'BIRDS',
      'title': 'Kingfisher Dive',
      'location': 'TARANGIRE',
      'year': '2020',
      'price': '\$180.00',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0, initialPage: 1000);
    _currentIndex = 1000 % _collectionItems.length;
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
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _timer?.cancel();
  }

  void _restartAutoPlay() {
    _stopAutoPlay();
    _startAutoPlay();
  }
  
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF9FBF9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHomeHero(context),
            _buildFeaturedCollection(context),
            _buildBehindTheLens(context),
          ],
        ),
      ),
      bottomNavigationBar: const WildBottomNavBar(),
    );
  }

  // Hero Section
  Widget _buildHomeHero(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/heroimageh1.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF0F1E26),
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image, color: Colors.white54),
            ),
          ),
          
          Container(
            color: Colors.black.withOpacity(0.35),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 150),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2ECC71), 
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'WILDLIFE PHOTOGRAPHY GALLERY',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                Text(
                  'WILD',
                  style: GoogleFonts.inter(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 0.9,
                    letterSpacing: -1.5,
                  ),
                ),
                Text(
                  'TRACE',
                  style: GoogleFonts.inter(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2ECC71), 
                    height: 0.9,
                    letterSpacing: -1.5,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  '“WILDLIFE. UNTAMED. TIMELESS.”',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Fine-art wildlife photographs captured in the wild, available as prints.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const SizedBox(height: 50),

                ElevatedButton(
                  onPressed: () {
                    final nav = context.read<NavigationProvider>();
                    nav.setSelectedIndex(1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'VIEW GALLERY',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const Spacer(), 

                Column(
                  children: [
                    Text(
                      'SCROLL TO EXPLORE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white.withOpacity(0.7),
                      size: 24,
                    ),
                    const SizedBox(height: 110),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Featured Collection Section
  Widget _buildFeaturedCollection(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      color: isDarkMode ? const Color(0xFF1B1B1B) : const Color(0xFFF9FBF9),
      child: Column(
        children: [
          Text(
            'FEATURED COLLECTION',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: const Color(0xFF2ECC71),
            ),
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
              height: 1.1,
            ),
          ),
          const SizedBox(height: 40),

          Container(
            height: 400,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index % _collectionItems.length;
                      });
                    },
                    itemBuilder: (context, index) {
                      final itemIndex = index % _collectionItems.length;
                      final item = _collectionItems[itemIndex];

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            item['image'] ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey.shade900,
                              child: const Icon(Icons.image, color: Colors.white24, size: 50),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 24, height: 2, color: const Color(0xFF2ECC71)),
                                    const SizedBox(width: 12),
                                    Text(
                                      item['category'] ?? '',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF2ECC71),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ],
                                ),

                                const Spacer(),

                                Text(
                                  item['title'] ?? '',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  '${item['location']?.toUpperCase()} • ${item['price'] ?? ''}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.8),
                                    letterSpacing: 1.0,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                IntrinsicWidth(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'VIEW PRINT',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 2.5,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(height: 3, color: const Color(0xFF2ECC71)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_collectionItems.length, (index) {
              final bool isActive = _currentIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                height: 8,
                width: isActive ? 32 : 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF2ECC71)
                      : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Behind The Lens Section
  Widget _buildBehindTheLens(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    const Color accentGreen = Color(0xFF2ECC71);

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 1, color: accentGreen.withOpacity(0.5)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'BEHIND THE LENS',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: accentGreen,
                  ),
                ),
              ),
              Container(width: 40, height: 1, color: accentGreen.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Capturing the\nUntamed Spirit.',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 42,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: textColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.6,
                color: textColor.withOpacity(0.8),
              ),
              children: [
                const TextSpan(
                  text: 'Every photograph in this gallery is captured ethically in the wild without disturbing the dignity of the animal. When you acquire a WildTrace print, you are supporting the preservation of these magnificent creatures—\n',
                ),
                TextSpan(
                  text: '10% of every sale is donated directly to wildlife conservation efforts.',
                  style: TextStyle(
                    color: accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/team.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Text(
            'OUR PHOTOGRAPHERS ARE FEATURED IN',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: textColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 40),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLogo('assets/images/natgeo.png', 90, 'https://www.nationalgeographic.com/'), 
              _buildLogo('assets/images/bbcearth.jpg', 50, 'https://www.bbcearth.com/'), 
              _buildLogo('assets/images/nhmwpy.jpg', 80, 'https://www.nhm.ac.uk/wpy'), 
            ],
          ),
          const SizedBox(height: 60),
          OutlinedButton(
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Scaffold(body: Center(child: Text("Journey Screen")))),
               );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: textColor.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LEARN MORE ABOUT OUR JOURNEY',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: textColor,
                  ),
                ),
                  const SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 14, color: textColor),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLogo(String assetPath, double width, String url) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Image.asset(
        assetPath,
        width: width,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
      ),
    );
  }
}

