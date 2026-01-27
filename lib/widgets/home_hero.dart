import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
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
          Container(color: Colors.black.withOpacity(0.35)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 150),
                _buildBadge(),
                const SizedBox(height: 50),
                _buildTitle(),
                const SizedBox(height: 30),
                _buildSubtitle(),
                const SizedBox(height: 50),
                _buildCTA(context),
                const Spacer(), 
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF2ECC71), shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(
            'WILDLIFE PHOTOGRAPHY GALLERY',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text('WILD', style: GoogleFonts.inter(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.white, height: 0.9, letterSpacing: 18.0)),
        Text('TRACE', style: GoogleFonts.inter(fontSize: 72, fontWeight: FontWeight.w900, color: const Color(0xFF2ECC71), height: 0.9, letterSpacing: -1.5)),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Column(
      children: [
        Text(
          '“WILDLIFE. UNTAMED. TIMELESS.”',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.white, letterSpacing: 0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'Fine-art wildlife photographs captured in the wild, available as prints.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w300),
        ),
      ],
    );
  }
  Widget _buildCTA(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.read<NavigationProvider>().setSelectedIndex(1),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text('VIEW GALLERY', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }
}
