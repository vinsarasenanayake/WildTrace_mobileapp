import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:battery_plus/battery_plus.dart';
import '../../../controllers/battery_controller.dart';

// widget to display battery percentage and low battery warnings
class BatteryStatusIndicator extends StatelessWidget {
  const BatteryStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BatteryController>(
      builder: (context, batteryProvider, child) {
        final level = batteryProvider.batteryLevel;
        final state = batteryProvider.batteryState;
        final bool isCharging = state == BatteryState.charging;
        // suppress low battery warning/colors if charging
        final bool isLow = batteryProvider.isBatteryLow && !isCharging;
        
        // icon logic
        IconData batteryIcon = isCharging ? Icons.battery_charging_full : Icons.battery_full;
        if (!isCharging) {
          if (level < 20) batteryIcon = Icons.battery_alert;
          else if (level < 40) batteryIcon = Icons.battery_3_bar;
          else if (level < 70) batteryIcon = Icons.battery_5_bar;
        }

        return Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // battery percentage display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLow ? Colors.red : Colors.white24,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      batteryIcon,
                      size: 10,
                      color: isLow ? Colors.red : Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Battery: $level%',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: isLow ? Colors.red : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // low battery warning message (fixed height to prevent layout jumps)
              SizedBox(
                height: 24, // Reserve space
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isLow
                      ? Padding(
                          key: const ValueKey('warning'),
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 10),
                                const SizedBox(width: 4),
                                Text(
                                  'Battery Low – some features limited',
                                  style: GoogleFonts.inter(
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
