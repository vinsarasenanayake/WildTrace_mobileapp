import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../providers/navigation_provider.dart';
import '../../../../providers/cart_provider.dart';

// main app navigation bar
class WildTraceBottomNavBar extends StatelessWidget {
  const WildTraceBottomNavBar({super.key});

  // builds bottom navigation bar with cart badge
  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // color palette
    final Color backgroundColor = isDarkMode ? Colors.black : const Color(0xFFBFBFBF);
    final Color selectedColor = isDarkMode ? const Color(0xFF27AE60) : const Color(0xFF1B4332);
    final Color unselectedColor = isDarkMode ? Colors.white.withOpacity(0.5) : Colors.grey.shade600;

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          child: SafeArea(
            top: false, 
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
              ),
              child: BottomNavigationBar(
                currentIndex: navProvider.selectedIndex,
                onTap: (index) {
                  navProvider.setSelectedIndex(index);
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                enableFeedback: false,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: selectedColor,
                unselectedItemColor: unselectedColor,
                showUnselectedLabels: true,
                selectedLabelStyle: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 2.0, 
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 2.0,
                ),
                items: [
                   const BottomNavigationBarItem(
                     icon: Padding(
                       padding: EdgeInsets.only(top: 6),
                       child: Icon(Icons.home_rounded, size: 24),
                     ), 
                     label: 'Home'
                   ),
                   const BottomNavigationBarItem(
                     icon: Padding(
                       padding: EdgeInsets.only(top: 6),
                       child: Icon(Icons.photo_library_rounded, size: 24),
                     ), 
                     label: 'Gallery'
                   ),
                   BottomNavigationBarItem(
                     icon: Padding(
                       padding: const EdgeInsets.only(top: 6),
                       child: Badge(
                         isLabelVisible: cartProvider.itemCount > 0,
                         label: Text(cartProvider.itemCount.toString()),
                         backgroundColor: const Color(0xFFE11D48),
                         child: const Icon(Icons.shopping_cart_rounded, size: 24),
                       ),
                     ), 
                     label: 'Cart'
                   ),
                   const BottomNavigationBarItem(
                     icon: Padding(
                       padding: EdgeInsets.only(top: 6),
                       child: Icon(Icons.person_rounded, size: 24),
                     ), 
                     label: 'Profile'
                   ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
