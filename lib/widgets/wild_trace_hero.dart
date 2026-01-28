// ============================================================================
// IMPORTS
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================================
// WILD TRACE HERO WIDGET - Reusable Hero Section
// ============================================================================
class WildTraceHero extends StatelessWidget {
  final String imagePath;
  final String? title;
  final String mainText1;
  final String mainText2;
  final String description;
  final String? description2;
  final String? subtitleQuote;
  final double? height;
  final double mainFontSize;
  final double mainLetterSpacing1;
  final double mainLetterSpacing2;
  final Widget? footer;

  const WildTraceHero({
    super.key,
    required this.imagePath,
    this.title,
    required this.mainText1,
    required this.mainText2,
    required this.description,
    this.description2,
    this.subtitleQuote,
    this.height,
    this.mainFontSize = 48,
    this.mainLetterSpacing1 = -1.0,
    this.mainLetterSpacing2 = -1.0,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height ?? screenHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0F1E26)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (title != null) ...[
                  Text(
                    title!.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF2ECC71),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  mainText1,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: mainFontSize,
                    fontWeight: FontWeight.w900,
                    height: 0.9,
                    letterSpacing: mainLetterSpacing1,
                  ),
                ),
                Text(
                  mainText2,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF2ECC71),
                    fontSize: mainFontSize,
                    fontWeight: FontWeight.w900,
                    height: 0.9,
                    letterSpacing: mainLetterSpacing2,
                  ),
                ),
                if (subtitleQuote != null) ...[
                  const SizedBox(height: 48),
                  Text(
                    subtitleQuote!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      fontStyle: FontStyle.italic, 
                      color: Colors.white, 
                      letterSpacing: 0.5
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: subtitleQuote != null ? FontWeight.w300 : FontWeight.normal,
                  ),
                ),
                if (description2 != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    description2!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
                if (footer != null) ...[
                  const SizedBox(height: 60),
                  footer!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
