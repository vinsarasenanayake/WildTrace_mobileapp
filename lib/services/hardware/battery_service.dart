import 'package:battery_plus/battery_plus.dart';

// battery service
class BatteryService {
  final Battery _battery = Battery();

  // get info
  Future<Map<String, dynamic>> getBatteryInfo() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;

    return {'level': level, 'state': state};
  }

  // stream state changes
  Stream<BatteryState> get onBatteryStateChanged {
    return _battery.onBatteryStateChanged;
  }
}
