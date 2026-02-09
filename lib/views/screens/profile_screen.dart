import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'order_history_screen.dart';
import 'favourites_screen.dart';
import 'edit_profile_screen.dart';
import '../widgets/cards/card_widgets.dart';
import '../widgets/common/common_widgets.dart';
import '../../main_wrapper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Build ui for profile screen
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode
        ? Colors.black
        : const Color(0xFFF9FBF9);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    const Color accentGreen = Color(0xFF27AE60);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final padding = MediaQuery.of(context).padding;
    final sidePadding =
        (padding.left > padding.right ? padding.left : padding.right) + 24.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Consumer<AuthController>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          final initials = user?.name.isNotEmpty == true
              ? user!.name[0].toUpperCase()
              : 'U';

          return SafeArea(
            bottom: false,
            child: Stack(
              children: [
                CustomScrollView(
                  physics: (isLandscape && !authProvider.isAuthenticated)
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: sidePadding,
                          vertical: isLandscape ? 4.0 : 24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (authProvider.isAuthenticated) ...[
                              _buildHeader(
                                textColor,
                                accentGreen,
                                initials,
                                user?.name ?? '',
                                user?.email ?? '',
                              ),
                              const SizedBox(height: 40),
                              _buildDashboard(context),
                              const SizedBox(height: 40),
                              _buildLogoutButton(context, authProvider),
                            ] else ...[
                              _buildGuestView(context, textColor),
                            ],
                            SizedBox(height: isLandscape ? 10 : 30),
                            _buildFooter(context),
                            SizedBox(height: isLandscape ? 10 : 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build user profile header with avatar
  Widget _buildHeader(
    Color textColor,
    Color accentGreen,
    String initials,
    String name,
    String email,
  ) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentGreen, width: 2),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade800,
              child: Text(
                initials,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          if (email.isNotEmpty)
            Text(
              email,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  // Build profile actions dashboard
  Widget _buildDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DASHBOARD',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 16),
        DashboardCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Order History',
          subtitle: 'View your past purchases',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
          ),
        ),
        const SizedBox(height: 16),
        DashboardCard(
          icon: Icons.favorite_border,
          title: 'Favourites',
          subtitle: 'Your curated wishlist',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavouritesScreen()),
          ),
        ),
        const SizedBox(height: 16),
        DashboardCard(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          subtitle: 'Update your personal info',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
          ),
        ),
      ],
    );
  }

  // Build logout action button
  Widget _buildLogoutButton(BuildContext context, AuthController authProvider) {
    return CustomButton(
      text: 'LOGOUT',
      icon: Icons.logout_rounded,
      onPressed: () {
        authProvider.logout();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      },
      backgroundColor: const Color(0xFF351010),
      foregroundColor: Colors.red.shade400,
      verticalPadding: 18,
      fontSize: 12,
    );
  }

  // Build copyright footer
  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Copyright © ${DateTime.now().year} ',
          style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade600),
        ),
        InkWell(
          onTap: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainWrapper()),
            (route) => false,
          ),
          child: Text(
            'WILDTRACE',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF27AE60),
            ),
          ),
        ),
        Text(
          '. All Rights Reserved.',
          style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // Build ui for unauthenticated users
  Widget _buildGuestView(BuildContext context, Color textColor) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Column(
      children: [
        SizedBox(height: isLandscape ? 0 : 60),
        Icon(
          Icons.lock_outline,
          size: isLandscape ? 40 : 64,
          color: Colors.grey.withAlpha((0.3 * 255).round()),
        ),
        SizedBox(height: isLandscape ? 12 : 24),
        Text(
          'Personalize Your Experience',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: isLandscape ? 18 : 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: isLandscape ? 8 : 12),
        Text(
          'Sign in to view your order history, manage favorites, and checkout faster.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey,
            height: 1.5,
          ),
        ),
        SizedBox(height: isLandscape ? 20 : 40),
        if (isLandscape)
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'SIGN IN NOW',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  ),
                  type: CustomButtonType.secondary,
                  verticalPadding: 16,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'REGISTER NOW',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  ),
                  type: CustomButtonType.ghost,
                  verticalPadding: 16,
                  fontSize: 13,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              CustomButton(
                text: 'SIGN IN NOW',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ),
                type: CustomButtonType.secondary,
                verticalPadding: 18,
                fontSize: 13,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'REGISTER NOW',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                ),
                type: CustomButtonType.ghost,
                verticalPadding: 18,
                fontSize: 13,
              ),
            ],
          ),
      ],
    );
  }
}
