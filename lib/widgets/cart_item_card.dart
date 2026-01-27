import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'quantity_selector.dart';

// Reusable Cart Item Display
class CartItemCard extends StatelessWidget {
  final String image;
  final String category;
  final String title;
  final double price;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;
  final VoidCallback? onDismissed;

  const CartItemCard({
    super.key,
    required this.image,
    required this.category,
    required this.title,
    required this.price,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    const Color accentGreen = Color(0xFF2ECC71);

    return Dismissible(
      key: Key(title + image),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade900,
                    child: const Icon(Icons.broken_image, color: Colors.white24),
                  ),
                ),
              ),
            ),
            
            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: accentGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: onDelete,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${price.toInt()} / unit',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${(price * quantity).toInt()}',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        QuantitySelector(
                          quantity: quantity,
                          onIncrement: onIncrement,
                          onDecrement: onDecrement,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
