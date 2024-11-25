import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ServiceCategories.dart';

class OfferServicePage extends StatefulWidget {
  @override
  _OfferServicePageState createState() => _OfferServicePageState();
}

class _OfferServicePageState extends State<OfferServicePage> {
  String? _selectedServiceCategory;
  String? _occupation;
  String? _bio;
  String? _experienceLevel;
  double? _latitude;
  double? _longitude;
  bool _serviceOffered = false;
  List<String> _filteredCategories = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCategories = ServiceCategories.categories;  // Initial list
    _searchController.addListener(_filterCategories);
    _getUserLocation();
    _retrieveServiceData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter categories based on search query
  void _filterCategories() {
    setState(() {
      _filteredCategories = ServiceCategories.categories
          .where((category) => category.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Location Services'),
          content: const Text(
              'Location services are disabled. Please enable them in settings to proceed.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              child: Text('Open Settings'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission is permanently denied.')),
        );
        return;
      }
    }

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    if (mounted) {
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    }
  }

  Future<void> _offerService() async {
    if (_selectedServiceCategory == null ||
        _occupation == null ||
        _bio == null ||
        _experienceLevel == null ||
        _latitude == null ||
        _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields!')),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user logged in!')),
        );
        return;
      }

      String userId = user.uid;
      DocumentReference userRef =
      FirebaseFirestore.instance.collection('users').doc(userId);

      await userRef.update({
        'serviceCategory': _selectedServiceCategory,
        'occupation': _occupation,
        'bio': _bio,
        'experienceLevel': _experienceLevel,
        'location': {
          'latitude': _latitude,
          'longitude': _longitude,
        },
        'role': 'provider',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _serviceOffered = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service Offered Successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _shareLocation() async {
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not available!')),
      );
      return;
    }

    final googleMapsUrl =
        'https://www.google.com/maps?q=$_latitude,$_longitude';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  Future<void> _retrieveServiceData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        _selectedServiceCategory = userDoc['serviceCategory'];
        _occupation = userDoc['occupation'];
        _bio = userDoc['bio'];
        _experienceLevel = userDoc['experienceLevel'];
        _latitude = userDoc['location']['latitude'];
        _longitude = userDoc['location']['longitude'];
        _serviceOffered = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Offer Service")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Service Category',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                hint: Text("Select Service Category"),
                value: _selectedServiceCategory,
                items: _filteredCategories
                    .map((service) => DropdownMenuItem(
                  child: Text(service),
                  value: service,
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedServiceCategory = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(labelText: "Occupation"),
                onChanged: (value) {
                  setState(() {
                    _occupation = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(labelText: "Bio"),
                onChanged: (value) {
                  setState(() {
                    _bio = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(labelText: "Experience Level"),
                onChanged: (value) {
                  setState(() {
                    _experienceLevel = value;
                  });
                },
              ),
              SizedBox(height: 20),
              if (_latitude != null && _longitude != null)
                Text(
                  'Current Location: Lat: $_latitude, Lon: $_longitude',
                  style: TextStyle(fontSize: 16),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _shareLocation,
                child: Text("Share Location"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _offerService,
                child: Text("Offer Service"),
              ),
              SizedBox(height: 20),
              if (_serviceOffered)
                Card(
                  color: Colors.blue[50],
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Provider Information',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text('Service Category: $_selectedServiceCategory'),
                        Text('Occupation: $_occupation'),
                        Text('Bio: $_bio'),
                        Text('Experience Level: $_experienceLevel'),
                        Text(
                            'Location: Latitude $_latitude, Longitude $_longitude'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
