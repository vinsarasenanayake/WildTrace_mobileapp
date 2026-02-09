import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/sync_controller.dart';
import '../widgets/cards/card_widgets.dart';
import 'checkout_screen.dart';
import '../widgets/common/common_widgets.dart';
import '../../controllers/navigation_controller.dart';
import '../../utilities/alert_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../../main_wrapper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Initialize state and fetch cart data
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthController>(context, listen: false);
      if (authProvider.token != null) {
        Provider.of<CartController>(
          context,
          listen: false,
        ).fetchCart(authProvider.token!);
      }
    });
  }

  // Build ui for cart screen
  @override
  Widget build(BuildContext context) {
    return Consumer<CartController>(
      builder: (context, cartProvider, child) {
        final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final Color textColor = isDarkMode
            ? Colors.white
            : const Color(0xFF1B4332);
        final cartItems = cartProvider.items;
        final authProvider = Provider.of<AuthController>(context);
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        final padding = MediaQuery.of(context).padding;
        final double sidePadding =
            (padding.left > padding.right ? padding.left : padding.right) +
            20.0;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: isDarkMode
                  ? Colors.black
                  : const Color(0xFFF9FBF9),
              body: SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  onRefresh: () async {
                    final authProvider = Provider.of<AuthController>(
                      context,
                      listen: false,
                    );
                    if (authProvider.token != null) {
                      await Provider.of<SyncController>(context, listen: false)
                          .syncPendingActions(authProvider.token!);
                      await cartProvider.fetchCart(authProvider.token!);
                    }
                  },
                  color: const Color(0xFF27AE60),
                  child: CustomScrollView(
                    physics: (isLandscape && authProvider.token == null)
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
                      if (cartItems.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(context, cartProvider),
                        )
                      else
                        ..._buildCartSlivers(
                          context,
                          cartProvider,
                          textColor,
                          isLandscape,
                          sidePadding,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Build UI for empty cart or unauthenticated state
  Widget _buildEmptyState(BuildContext context, CartController cartProvider) {
    final authProvider = Provider.of<AuthController>(context, listen: false);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final padding = MediaQuery.of(context).padding;
    final double sidePadding =
        (padding.left > padding.right ? padding.left : padding.right) + 24.0;

    if (authProvider.token == null) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sidePadding,
          vertical: isLandscape ? 4.0 : 24.0,
        ),
        child: Column(
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
              'Sign in to view your cart items, manage orders, and checkout faster.',
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
                      fontSize: 13,
                      verticalPadding: 16,
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
                      fontSize: 13,
                      verticalPadding: 16,
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
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    ),
                    type: CustomButtonType.secondary,
                    fontSize: 13,
                    verticalPadding: 18,
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
                    fontSize: 13,
                    verticalPadding: 18,
                  ),
                ],
              ),
            SizedBox(height: isLandscape ? 10 : 30),
            _buildFooter(),
            SizedBox(height: isLandscape ? 10 : 20),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 220,
            child: CustomButton(
              text: 'EXPLORE GALLERY',
              type: CustomButtonType.secondary,
              onPressed: () {
                Provider.of<NavigationController>(
                  context,
                  listen: false,
                ).setSelectedIndex(1);
              },
            ),
          ),
          const SizedBox(height: 30),
          _buildFooter(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Build sliver widgets for the cart item list
  List<Widget> _buildCartSlivers(
    BuildContext context,
    CartController cartProvider,
    Color textColor,
    bool isLandscape,
    double sidePadding,
  ) {
    final cartItems = cartProvider.items;

    if (isLandscape) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              left: sidePadding,
              right: sidePadding,
              top: 0,
              bottom: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SectionTitle(
                  title: 'YOUR SELECTION',
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Collectors Cart',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sidePadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: cartItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CartItemCard(
                          image: item.product.imageUrl,
                          category: item.product.category,
                          title: item.product.title,
                          price: item.price ?? item.product.price,
                          quantity: item.quantity,
                          size: item.size,
                          onIncrement: () =>
                              cartProvider.incrementQuantity(item),
                          onDecrement: () =>
                              cartProvider.decrementQuantity(item),
                          onDelete: () {
                            if (item.id != null) {
                              cartProvider.removeFromCart(item.id!);
                            }
                          },
                          onDismissed: () {
                            if (item.id != null) {
                              final cartItemId = item.id!;
                              final productName = item.product.title;
                              cartProvider.removeFromCart(cartItemId);


                              AlertService.showSuccess(
                                context: context,
                                title: 'Item Removed',
                                text: '$productName removed from cart',
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildSummaryCard(context, cartProvider),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: _buildFooter(),
          ),
        ),
      ];
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(
            left: sidePadding,
            right: sidePadding,
            top: 0,
            bottom: 8.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SectionTitle(
                title: 'YOUR SELECTION',
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Collectors Cart',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: sidePadding),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index.isOdd) return const SizedBox(height: 16);
            final itemIndex = index ~/ 2;
            final item = cartItems[itemIndex];

            return CartItemCard(
              image: item.product.imageUrl,
              category: item.product.category,
              title: item.product.title,
              price: item.price ?? item.product.price,
              quantity: item.quantity,
              size: item.size,
              onIncrement: () => cartProvider.incrementQuantity(item),
              onDecrement: () => cartProvider.decrementQuantity(item),
              onDelete: () {
                if (item.id != null) {
                  cartProvider.removeFromCart(item.id!);
                }
              },
              onDismissed: () {
                if (item.id != null) {
                  final cartItemId = item.id!;
                  final productName = item.product.title;
                  cartProvider.removeFromCart(cartItemId);


                  AlertService.showSuccess(
                    context: context,
                    title: 'Item Removed',
                    text: '$productName removed from cart',
                  );
                }
              },
            );
          }, childCount: cartItems.length * 2 - 1),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sidePadding,
            vertical: 20.0,
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildSummaryCard(context, cartProvider),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: _buildFooter(),
        ),
      ),
    ];
  }

  // Build the order summary and action buttons
  Widget _buildSummaryCard(BuildContext context, CartController cartProvider) {
    return OrderSummaryCard(
      title: 'Cart Summary',
      totalLabel: 'ORDER TOTAL',
      totalValue: '\$${cartProvider.total.toStringAsFixed(0)}',
      primaryButtonLabel: 'PROCEED TO CHECKOUT',
      isPrimaryEnabled: true,
      primaryButtonOnTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CheckoutScreen()),
        );
      },
      secondaryButtonLabel: 'CLEAR CART',
      secondaryButtonOnTap: () {
        AlertService.showConfirmation(
          context: context,
          title: 'Clear Cart',
          text: 'Are you sure you want to remove all items?',
          confirmBtnText: 'YES',
          cancelBtnText: 'NO',
          onConfirm: () {
            Navigator.pop(context);
            cartProvider.clearCart();
          },
          onCancel: () => Navigator.pop(context),
        );
      },
      isSecondaryOutlined: true,
    );
  }

  // Build the copyright footer
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Copyright © 2026 ',
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
}
