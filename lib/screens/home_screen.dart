import 'package:flutter/material.dart';
import 'FindServicesScreen.dart';
import 'OfferServiceScreen.dart';
import 'ProfileScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Job App'),
        backgroundColor: Colors.black, // Dark AppBar to make neon glow pop
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNeonButton(
              context,
              Icons.search,
              'Find Services',
              Colors.blueAccent,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FindServicePage()),
                );
              },
            ),
            const SizedBox(height: 40),
            _buildNeonButton(
              context,
              Icons.handyman,
              'Offer Service',
              Colors.green,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OfferServicePage()),
                );
              },
            ),
            const SizedBox(height: 40),
            _buildNeonButton(
              context,
              Icons.person,
              'Profile',
              Colors.orange,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeonButton(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.8),
              blurRadius: 15,
              spreadRadius: 5,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: color,
                      offset: Offset(0, 0),
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
