import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<Map<String, dynamic>> getLocation() async {
  LocationPermission permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied)
    throw Exception("Location permission denied");

  Position position = await Geolocator.getCurrentPosition();
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

  return {
    'latitude': position.latitude,
    'longitude': position.longitude,
    'address': placemarks.first.street,
  };
}

Future<void> storeUserData(
    String name, String email, String phone, DateTime timestamp) async {
  await FirebaseFirestore.instance.collection('users').add({
    'name': name,
    'email': email,
    'phone': phone,
    'timestamp': timestamp,
  });
}

void saveDataWithLocation(String name, String email, String phone) async {
  final locationData = await getLocation();
  await storeUserData(name, email, phone, DateTime.now());
  await FirebaseFirestore.instance.collection('users').doc().set({
    'latitude': locationData['latitude'],
    'longitude': locationData['longitude'],
    'address': locationData['address'],
  });
}
