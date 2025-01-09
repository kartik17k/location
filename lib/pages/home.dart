import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/service/localNotification.dart';

import '../service/firestore.dart';
import '../theme/color.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? _currentAddress;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  Future<bool> _handleLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enable location services.')),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission denied.')),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission permanently denied.')),
      );
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    if (!await _handleLocationPermission()) return;
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _getAddressFromLatLng(_currentPosition!);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String name = nameController.text;
      String address = _currentAddress ?? 'Unknown address';

      saveDataWithLocation(
        nameController.text,
        emailController.text,
        phoneController.text,
      );

      LocalNotifications.Notification(
        title: "Hello $name,",
        body: "How was the $address?",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form submitted successfully!')),
      );

      // Clear the form and reset state
      _formKey.currentState?.reset();
      nameController.clear();
      emailController.clear();
      phoneController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Location',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Fill in your details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: onBackgroundColor,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                  prefixIcon: const Icon(Icons.person, color: primaryColor),
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(color: onSurfaceColor),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email, color: primaryColor),
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(color: onSurfaceColor),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: const Icon(Icons.phone, color: primaryColor),
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(color: onSurfaceColor),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_currentPosition != null) ...[
                Text(
                  "Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: onSurfaceColor,
                  ),
                ),
                Text(
                  "Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (_currentAddress != null) ...[
                Text(
                  "Address:",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: onBackgroundColor,
                  ),
                ),
                Text(
                  _currentAddress!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor:
                                backgroundColor, // Set the dialog background color
                            title: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'Form Submitted',
                                  style: const TextStyle(
                                      color: onSurfaceColor), // Text color
                                ),
                              ],
                            ),
                            content: Text(
                              'Name: ${nameController.text}\nEmail: ${emailController.text}\nPhone: ${phoneController.text}',
                              style: const TextStyle(
                                  color: onSurfaceColor), // Text color
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _submitForm();
                                },
                                child: const Text(
                                  'OK',
                                  style: TextStyle(
                                      color: primaryColor), // Button text color
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: onPrimaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.send),
                    label: const Text(
                      'Submit',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _formKey.currentState?.reset();
                      nameController.clear();
                      emailController.clear();
                      phoneController.clear();
                    },
                    icon: const Icon(Icons.refresh, color: primaryColor),
                    label: const Text(
                      'Reset Form',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
