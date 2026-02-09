import 'package:battery_plus/battery_plus.dart';

class BatteryService {
  final Battery _battery = Battery();

  // Get current battery level and state
  Future<Map<String, dynamic>> getBatteryInfo() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;

    return {'level': level, 'state': state};
  }

  Stream<BatteryState> get onBatteryStateChanged {
    return _battery.onBatteryStateChanged;
  }
}
