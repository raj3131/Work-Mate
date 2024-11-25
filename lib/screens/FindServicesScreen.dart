import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ServiceCategories.dart';


class FindServicePage extends StatefulWidget {
  const FindServicePage({super.key});

  @override
  _FindServicePageState createState() => _FindServicePageState();
}

class _FindServicePageState extends State<FindServicePage> {
  String? _selectedServiceCategory;
  List<Map<String, dynamic>> _usersOfferingService = [];
  List<Map<String, dynamic>> _allProviders = [];
  Position? _userPosition;
  bool _isLoading = false;

  String? _selectedCategory;

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category; // Update the selected category
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAllProviders();
  }

  Future<void> _fetchAllProviders() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'provider')
        .get();

    setState(() {
      _allProviders = querySnapshot.docs.map((doc) {
        return {
          'userId': doc.id,
          'firstName': doc['firstName'] ?? 'No first name',
          'lastName': doc['lastName'] ?? 'No last name',
          'bio': doc['bio'] ?? '',
          'serviceCategory': doc['serviceCategory'] ?? 'No category',
          'contact': doc['contact'] ?? '',
        };
      }).toList();
    });
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location permissions are permanently denied')),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _userPosition = position;
    });
  }

  Future<void> _searchForService() async {
    if (_selectedServiceCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service to search for!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await _getUserLocation();
    if (_userPosition == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('serviceCategory', isEqualTo: _selectedServiceCategory)
        .where('role', isEqualTo: 'provider')
        .get();

    List<Map<String, dynamic>> users = querySnapshot.docs.map((doc) {
      var location = doc['location'];
      double userLat = location != null ? location['latitude'] : 0.0;
      double userLon = location != null ? location['longitude'] : 0.0;

      double distance = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        userLat,
        userLon,
      ) / 1000; // Convert meters to kilometers

      return {
        'userId': doc.id,
        'firstName': doc['firstName'] ?? 'No first name',
        'lastName': doc['lastName'] ?? 'No last name',
        'bio': doc['bio'] ?? '',
        'serviceCategory': doc['serviceCategory'] ?? 'No category',
        'distance': distance,
        'contact': doc['contact'] ?? '',
      };
    }).toList();

    users.sort((a, b) => a['distance'].compareTo(b['distance']));

    setState(() {
      _usersOfferingService = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find Service")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [



              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ServiceCategories.dropdownWithFilter(
                          onChanged: _onCategorySelected,
                          selectedValue: _selectedCategory,
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedCategory ?? 'Select Service Category',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_selectedCategory != null)
                Text(
                  'You selected: $_selectedCategory',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              // DropdownButtonFormField<String>(
              //   decoration: const InputDecoration(
              //     labelText: "Select Service Category",
              //     border: OutlineInputBorder(),
              //   ),
              //   value: _selectedServiceCategory,
              //   items: ServiceCategories.categories.map((service) => DropdownMenuItem(
              //     child: Text(service),
              //     value: service,
              //   ))
              //       .toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedServiceCategory = value;
              //     });
              //   },
              // ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _searchForService,
                child: const Text("Search for Service"),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedServiceCategory != null)
                      const Text(
                        "Providers Matching Your Search",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    _usersOfferingService.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _selectedServiceCategory != null
                            ? 'No providers found for ${_selectedServiceCategory!}'
                            : 'Please select a service category to search.',
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _usersOfferingService.length,
                      itemBuilder: (context, index) {
                        var user = _usersOfferingService[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(user['firstName'][0]),
                            ),
                            title: Text(
                                '${user['firstName']} ${user['lastName']}'),
                            subtitle: Text(
                                '${user['serviceCategory']} - ${user['distance'].toStringAsFixed(2)} km away'),
                            trailing: const Icon(Icons.location_on),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('${user['firstName']} ${user['lastName']}'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Service: ${user['serviceCategory']}'),
                                      Text('Bio: ${user['bio']}'),
                                      Text('Distance: ${user['distance'].toStringAsFixed(2)} km away'),
                                      Text('Contact Number: ${user['contact']}'),
                                    ],
                                  ),
                                  actions: [
                                    IconButton(
                                      icon: const Icon(Icons.call, color: Colors.green),
                                      onPressed: () async {
                                        final String? contactNumber = user['contact'];

                                        // Check if the contact number is available and valid
                                        if (contactNumber == null || contactNumber.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Contact number is unavailable')),
                                          );
                                          return;
                                        }

                                        final Uri callUri = Uri(
                                          scheme: 'tel',
                                          path: contactNumber,
                                        );

                                        try {
                                          if (await canLaunchUrl(callUri)) {
                                            await launchUrl(callUri, mode: LaunchMode.externalApplication);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Could not launch dialer')),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error launching dialer: $e')),
                                          );
                                        }
                                      },
                                    ),

                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },

                          ),
                        );
                      },
                    ),
                    const Divider(),
                    const Text(
                      "Available Providers",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _allProviders.length,
                        itemBuilder: (context, index) {
                          var provider = _allProviders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(provider['firstName'][0]),
                              ),
                              title: Text(
                                  '${provider['firstName']} ${provider['lastName']}'),
                              subtitle: Text(provider['serviceCategory']),
                              trailing: const Icon(Icons.info_outline),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                        '${provider['firstName']} ${provider['lastName']}'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text('Service: ${provider['serviceCategory']}'),
                                        Text('Bio: ${provider['bio']}'),
                                        Text('Contact Number: ${provider['contact']}'),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
