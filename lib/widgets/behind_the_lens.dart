import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// Section Introducing The Ethics & Team
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
          _buildSmallHeader(accentGreen), // Section Title
          const SizedBox(height: 24),
          _buildMainHeading(textColor), // Large Quote
          const SizedBox(height: 24),
          _buildDescription(textColor, accentGreen), // Text Content
          const SizedBox(height: 40),
          _buildTeamImage(), // visual
          const SizedBox(height: 60),
          _buildFeaturedBanner(textColor), // Partners Title
          const SizedBox(height: 40),
          _buildLogos(), // Partners Logos
          const SizedBox(height: 60),
          _buildJourneyButton(context, textColor), // Navigation to about
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
      onPressed: () {}, // Journey Action
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
