import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your name'
                    : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)
                    ? 'Enter a valid email'
                    : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || !RegExp(r'^\d{10}\$').hasMatch(value)
                    ? 'Enter a valid 10-digit phone number'
                    : null,
              ),
              if (_currentAddress != null) ...[
                SizedBox(height: 16),
                Text('Address: $_currentAddress'),
              ],
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
