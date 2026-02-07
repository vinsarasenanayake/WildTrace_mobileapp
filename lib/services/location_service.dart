import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Handles device location
class LocationService {
  // Fetches human-readable address
  Future<Map<String, String>?> getCurrentAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verify location services
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    try {
      // Get precise position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 25),
        ),
      );

      try {
        // Reverse geocode coordinates
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        ).timeout(const Duration(seconds: 15));

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          
          String thoroughfare = place.thoroughfare ?? '';
          String subThoroughfare = place.subThoroughfare ?? '';
          String streetDetail = place.street ?? '';
          String finalAddress = '';
          
          // Determine best address string
          if (streetDetail.isNotEmpty && !streetDetail.contains('+')) {
            finalAddress = streetDetail;
          } else if (thoroughfare.isNotEmpty) {
            finalAddress = subThoroughfare.isNotEmpty ? '$subThoroughfare, $thoroughfare' : thoroughfare;
          } else {
            finalAddress = (place.name != null && place.name!.isNotEmpty) ? place.name! : streetDetail;
          }

          String postalCode = place.postalCode ?? '';
          String city = place.locality ?? '';

          // Fix for Moratuwa region
          if (city.toLowerCase().contains('moratuwa') && (postalCode == '10100' || postalCode.isEmpty)) {
            postalCode = '10400';
          }

          return {
            'address': finalAddress,
            'city': city,
            'postalCode': postalCode,
            'country': place.country ?? 'Sri Lanka',
          };
        }
      } catch (geocodingError) {
        // Fallback on failure
        return {
          'address': 'Selected Location',
          'city': 'Detected',
          'postalCode': '-----',
          'country': 'Sri Lanka',
        };
      }
    } catch (e) {
      rethrow; 
    }
    return null;
  }
}
