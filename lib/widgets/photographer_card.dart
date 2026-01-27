import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PhotographerCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String role;
  final String quote;

  const PhotographerCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.role,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
            stops: const [0.4, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            // Award Badge Header
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'NWPY WINNER',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            // Main Profile Details
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36, // Slightly larger to match image
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  role.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: const Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Photographer Inspiration
                Container(
                  padding: const EdgeInsets.only(left: 16),
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: Color(0xFF2ECC71), width: 2)),
                  ),
                  child: Text(
                    '"$quote"',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  'CANON AMBASSADOR',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
