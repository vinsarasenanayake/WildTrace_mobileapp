import 'package:flutter/material.dart';
import 'light_indicator.dart';
import 'battery_indicator.dart';

class HardwareStatusRow extends StatelessWidget {
  const HardwareStatusRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        LightStatusIndicator(),
        SizedBox(width: 10),
        BatteryStatusIndicator(),
      ],
    );
  }
}
