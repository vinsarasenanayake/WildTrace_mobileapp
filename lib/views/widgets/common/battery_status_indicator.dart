import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/battery_provider.dart';

// widget to display battery percentage and low battery warnings
class BatteryStatusIndicator extends StatelessWidget {
  const BatteryStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BatteryProvider>(
      builder: (context, batteryProvider, child) {
        final level = batteryProvider.batteryLevel;
        final isLow = batteryProvider.isBatteryLow;
        
        // icon logic
        IconData batteryIcon = Icons.battery_full;
        if (level < 20) batteryIcon = Icons.battery_alert;
        else if (level < 40) batteryIcon = Icons.battery_3_bar;
        else if (level < 70) batteryIcon = Icons.battery_5_bar;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // battery percentage display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isLow ? Colors.red : Colors.white24,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    batteryIcon,
                    size: 14,
                    color: isLow ? Colors.red : Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Battery: $level%',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isLow ? Colors.red : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // low battery warning message
            if (isLow)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Battery Low – some features limited',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
