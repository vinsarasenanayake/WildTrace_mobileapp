import 'dart:async';
import 'package:light/light.dart';

// light service
class LightService {
  final Light _light = Light();

  // get current light
  Future<double> getCurrentLight() async {
    try {
      // Use a timeout to ensure we don't block indefinitely waiting for the first value
      final int lux = await _light.lightSensorStream.first.timeout(
        const Duration(seconds: 2),
        onTimeout: () => 0,
      );
      return lux.toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  // stream light changes
  Stream<double> get onLightChanged {
    // Map the int stream to double
    return _light.lightSensorStream.map((event) => event.toDouble());
  }
}
