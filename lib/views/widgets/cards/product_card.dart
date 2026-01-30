import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String category;
  final String title;
  final String author;
  final String price;
  final VoidCallback? onTap;
  final bool isLiked;
  final VoidCallback? onLikeToggle;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.author,
    required this.price,
    this.onTap,
    this.isLiked = false,
    this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl.startsWith('http') 
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  cacheWidth: 800, // Optimize image decoding for smoother scrolling
                  gaplessPlayback: true, // Prevent flickering
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined, color: Colors.white24, size: 32),
                    ),
                  ),
                )
              : Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  cacheWidth: 800,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined, color: Colors.white24, size: 32),
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0), // Reduced from 20
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9, // Reduced from 10
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: const Color(0xFF2ECC71),
                      ),
                    ),
                    const SizedBox(height: 6), // Reduced from 8
                    Text(
                      title,
                      maxLines: 1, // Added maxLines to prevent wrap overflow
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20, // Reduced from 22
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2), // Reduced from 4
                    Text(
                      'BY ${author.toUpperCase()}',
                      style: GoogleFonts.inter(
                        fontSize: 9, // Reduced from 10
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12), // Reduced from 16
                    Divider(
                      color: Colors.white.withOpacity(0.2), 
                      height: 1, 
                      thickness: 1
                    ),
                    const SizedBox(height: 12), // Reduced from 16
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STARTING PRICE :',
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 2), // Reduced from 4
                            Text(
                              price,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: onLikeToggle,
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                            color: isLiked ? const Color(0xFFE11D48) : Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

