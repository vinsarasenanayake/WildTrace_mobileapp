import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/hardware_controller.dart';

class BatteryStatusIndicator extends StatelessWidget {
  const BatteryStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HardwareController>(
      builder: (context, hw, child) {
        if (hw.batteryLevel == -1) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha((0.6 * 255).round()),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withAlpha((0.2 * 255).round()),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hw.batteryIcon,
                color: hw.batteryColor,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                '${hw.batteryLevel}%${hw.isCharging ? " (Charging)" : ""}',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
