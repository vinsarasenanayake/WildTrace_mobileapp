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
              Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade900,
                  child: const Icon(Icons.broken_image, color: Colors.white24),
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: const Color(0xFF2ECC71),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BY ${author.toUpperCase()}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: Colors.white.withOpacity(0.2), 
                      height: 1, 
                      thickness: 1
                    ),
                    const SizedBox(height: 16),
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
                            const SizedBox(height: 4),
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
