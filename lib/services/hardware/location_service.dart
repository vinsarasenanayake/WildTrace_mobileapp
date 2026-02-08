import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<Map<String, String>?> getCurrentAddress() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied forever");
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;

      String street = place.street ?? '';
      String subLocality = place.subLocality ?? '';
      String locality = place.locality ?? '';
      
      List<String> addressParts = [];
      if (street.isNotEmpty) addressParts.add(street);
      if (subLocality.isNotEmpty && subLocality != street && subLocality != locality) addressParts.add(subLocality);

      String address = addressParts.join(', ');
      String city = locality;
      String postalCode = place.postalCode ?? '';
      String country = place.country ?? '';

      return {
        "address": address,
        "city": city,
        "postalCode": postalCode,
        "country": country,
      };
    }
    return null;
  }
}
