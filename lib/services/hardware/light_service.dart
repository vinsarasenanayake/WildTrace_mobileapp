import 'dart:async';
import 'package:light/light.dart';

class LightService {
  final Light _light = Light();

  // Get current ambient light intensity in lux
  Future<double> getCurrentLight() async {
    try {
      final int lux = await _light.lightSensorStream.first.timeout(
        const Duration(seconds: 2),
        onTimeout: () => 0,
      );
      return lux.toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  Stream<double> get onLightChanged {
    return _light.lightSensorStream.map((event) => event.toDouble());
  }
}
