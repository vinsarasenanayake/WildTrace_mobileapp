import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import '../services/hardware/battery_service.dart';
import '../services/hardware/location_service.dart';
import '../services/hardware/light_service.dart';

// hardware controller
class HardwareController extends ChangeNotifier {

  // constants
  static const int batteryHigh = 80;
  static const int batteryMedium = 60;
  static const int batteryLow = 40;
  static const int batteryCritical = 20;

  static const double lightSunny = 1000;
  static const double lightBright = 100;
  static const double lightTwilight = 10;
  static const double lightDark = 500; // for color threshold

  final BatteryService _batteryService = BatteryService();
  final LocationService _locationService = LocationService();
  final LightService _lightService = LightService();

  // state
  int _batteryLevel = -1;
  BatteryState _batteryState = BatteryState.unknown;
  bool _isDetectingLocation = false;
  double _luxValue = 0;

  // subscriptions
  StreamSubscription<BatteryState>? _batterySubscription;
  StreamSubscription<double>? _lightSubscription;


  // getters
  int get batteryLevel => _batteryLevel;
  BatteryState get batteryState => _batteryState;
  bool get isCharging => _batteryState == BatteryState.charging;
  bool get isDetectingLocation => _isDetectingLocation;
  double get luxValue => _luxValue;

  IconData get batteryIcon {
    if (isCharging) return Icons.battery_charging_full;
    if (_batteryLevel >= batteryHigh) return Icons.battery_full;
    if (_batteryLevel >= batteryMedium) return Icons.battery_6_bar;
    if (_batteryLevel >= batteryLow) return Icons.battery_4_bar;
    if (_batteryLevel >= batteryCritical) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  Color get batteryColor {
    if (isCharging) return Colors.greenAccent;
    if (_batteryLevel <= batteryCritical) return Colors.redAccent;
    return Colors.white;
  }

  IconData get lightIcon {
    if (_luxValue > lightSunny) return Icons.wb_sunny;
    if (_luxValue > lightBright) return Icons.light_mode;
    if (_luxValue > lightTwilight) return Icons.wb_twilight;
    return Icons.nightlight_round;
  }

  Color get lightColor {
    if (_luxValue > lightDark) return Colors.orangeAccent;
    if (_luxValue > 50) return Colors.yellowAccent;
    return Colors.lightBlueAccent;
  }


  HardwareController();

  // init hardware
  void initHardware() async {
    try {
      await updateBattery();
    } catch (_) {}

    _batterySubscription = _batteryService.onBatteryStateChanged.listen(
      (state) {
        _batteryState = state;
        updateBattery();
      },
      onError: (_) {
        // handle stream error gracefully
        _batteryState = BatteryState.unknown;
        notifyListeners();
      },
    );

    _lightSubscription = _lightService.onLightChanged.listen(
      (lux) {
        _luxValue = lux;
        notifyListeners();
      },
      onError: (_) {
        // handle stream error gracefully
        _luxValue = 0;
        notifyListeners();
      },
    );
  }

  // update battery
  Future<void> updateBattery() async {
    try {
      final info = await _batteryService.getBatteryInfo();
      _batteryLevel = info['level'] as int;
      _batteryState = info['state'] as BatteryState;
      notifyListeners();
    } catch (_) {}
  }

  // detect location
  Future<Map<String, String>?> detectLocation() async {
    _isDetectingLocation = true;
    notifyListeners();
    
    try {
      final addressData = await _locationService.getCurrentAddress().timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw Exception('Location request timed out'),
      );
      return addressData;
    } finally {
      _isDetectingLocation = false;
      notifyListeners();
    }
  }



  @override
  void dispose() {
    _batterySubscription?.cancel();
    _lightSubscription?.cancel();
    super.dispose();
  }
}
