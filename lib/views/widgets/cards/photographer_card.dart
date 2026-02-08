import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/common_widgets.dart';

class PhotographerCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String role;
  final String quote;
  final String achievement;
  final String? badgeText;
  final String? fallbackAsset;

  const PhotographerCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.role,
    required this.quote,
    required this.achievement,
    this.badgeText,
    this.fallbackAsset,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      height: isLandscape ? 320 : 520,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imagePath.startsWith('assets/')
            ? Image.asset(imagePath, fit: BoxFit.cover)
            : CachedImage(
                imageUrl: imagePath,
                fit: BoxFit.cover,
                errorWidget: fallbackAsset != null 
                  ? Image.asset(fallbackAsset!, fit: BoxFit.cover)
                  : null,
              ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withAlpha((0.9 * 255).round()),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isLandscape ? 16 : 24),
            child: Stack(
              children: [
            if (badgeText != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLandscape ? 12 : 16,
                    vertical: isLandscape ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText!,
                    style: GoogleFonts.inter(
                      fontSize: isLandscape ? 9 : 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: isLandscape ? 24 : 36,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: isLandscape ? 4 : 8),
                Text(
                  role.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: isLandscape ? 8 : 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: const Color(0xFF27AE60),
                  ),
                ),
                SizedBox(height: isLandscape ? 12 : 24),
                Container(
                  padding: EdgeInsets.only(left: isLandscape ? 12 : 16),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: const Color(0xFF27AE60),
                        width: isLandscape ? 1.5 : 2,
                      ),
                    ),
                  ),
                  child: Text(
                    '"$quote"',
                    style: GoogleFonts.inter(
                      fontSize: isLandscape ? 11 : 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withAlpha((0.9 * 255).round()),
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: isLandscape ? 16 : 32),
                Text(
                  achievement.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: isLandscape ? 8 : 10,
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
        ],
      ),
    );
}
}
