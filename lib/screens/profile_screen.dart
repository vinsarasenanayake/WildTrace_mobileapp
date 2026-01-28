// --- Imports ---
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';
import 'favourites_screen.dart';
import 'edit_profile_screen.dart';
import 'wallet_screen.dart';
import '../widgets/dashboard_card.dart';

// --- Screen ---
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    const Color accentGreen = Color(0xFF2ECC71);
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              floating: true,
              snap: true,
              pinned: false,
              toolbarHeight: 40,
              automaticallyImplyLeading: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(textColor, accentGreen),
                    const SizedBox(height: 40),
                    _buildDashboard(context),
                    const SizedBox(height: 40),
                    _buildLogoutButton(context),
                    const SizedBox(height: 30),
                    _buildFooter(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods ---
  Widget _buildHeader(Color textColor, Color accentGreen) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accentGreen, width: 2)),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade800,
              child: Text('V', style: GoogleFonts.playfairDisplay(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Vinsara Senanayake', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text('vinsara@example.com', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DASHBOARD', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Colors.grey.shade500)),
        const SizedBox(height: 16),
        DashboardCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Order History',
          subtitle: 'View your past purchases',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryScreen())),
        ),
        const SizedBox(height: 16),
        DashboardCard(
          icon: Icons.favorite_border,
          title: 'Favourites',
          subtitle: 'Your curated wishlist',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavouritesScreen())),
        ),
        const SizedBox(height: 16),
        DashboardCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Wallet',
          subtitle: 'Payment methods & balance',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletScreen())),
        ),
        const SizedBox(height: 16),
        DashboardCard(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          subtitle: 'Update your personal info',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: BorderSide(color: Colors.red.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFF351010),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20, color: Colors.red.shade400),
            const SizedBox(width: 8),
            Text('LOGOUT', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.red.shade400)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Copyright © 2026 ', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade600)),
        Text('WILDTRACE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF2ECC71))),
        Text('. All Rights Reserved.', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}


