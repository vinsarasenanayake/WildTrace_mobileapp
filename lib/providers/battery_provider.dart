import 'dart:async';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';

// manages device battery state
class BatteryProvider with ChangeNotifier {
  final Battery _battery = Battery();
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.full;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  Timer? _batteryLevelTimer;

  int get batteryLevel => _batteryLevel;
  BatteryState get batteryState => _batteryState;
  bool get isBatteryLow => _batteryLevel < 20;

  BatteryProvider() {
    _initBattery();
  }

  // sets up battery listeners and initial state
  void _initBattery() async {
    // get initial level
    try {
      _batteryLevel = await _battery.batteryLevel;
    } catch (_) {
      _batteryLevel = 100;
    }

    // listen to state changes (charging, full, discharging)
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((BatteryState state) async {
      _batteryState = state;
      // level might change with state
      final level = await _battery.batteryLevel;
      if (_batteryLevel != level) {
        _batteryLevel = level;
      }
      notifyListeners();
    });

    // periodic level check for accuracy when discharging
    _batteryLevelTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      try {
        final level = await _battery.batteryLevel;
        if (_batteryLevel != level) {
          _batteryLevel = level;
          notifyListeners();
        }
      } catch (_) {}
    });

    notifyListeners();
  }

  @override
  void dispose() {
    _batteryStateSubscription?.cancel();
    _batteryLevelTimer?.cancel();
    super.dispose();
  }
}
