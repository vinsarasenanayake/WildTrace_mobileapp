import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeaturedItemCard extends StatelessWidget {
  final String imageUrl;
  final String category;
  final String title;
  final String location;
  final String price;
  final VoidCallback onTap;

  const FeaturedItemCard({
    super.key,
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.location,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imageUrl,
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
                      category.toUpperCase(),
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
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 42,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${location.toUpperCase()} • $price',
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
      ),
    );
  }
}

