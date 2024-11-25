import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workmate/screens/home_or_login_screen.dart';
import 'firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _requestLocationPermission(); // Request location permission on app startup

  runApp(MyApp());
}

Future<void> _requestLocationPermission() async {
  var status = await Permission.location.request();
  if (status.isDenied) {
    // Handle permission denied case
    print("Location permission denied");
  } else if (status.isPermanentlyDenied) {
    // Open app settings if permission is permanently denied
    await openAppSettings();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Job App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeOrLoginScreen(),
    );
  }
}
