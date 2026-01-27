import 'package:flutter/material.dart';

// --- Shared App Bar ---
class WildAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WildAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1B4332),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        child: SizedBox(
          height: preferredSize.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 32,
                errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.pets, color: Colors.white, size: 24),
              ),
              ElevatedButton(
                onPressed: () {}, // No logic yet
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D8C5B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
