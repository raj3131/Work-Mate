import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Auth/auth_service.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userId = '';
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserIdAndData();
  }

  Future<void> _getUserIdAndData() async {
    _userId = await _authService.getCurrentUserId();
    if (_userId.isNotEmpty) {
      _userData = await _authService.fetchUserData(_userId);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userData != null
          ? _buildProfileInfo()
          : _buildNoUserData(),
      backgroundColor: Colors.teal.shade50,
    );
  }

  Widget _buildProfileInfo() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_userData!['role'] != null && _userData!['role'].isNotEmpty)
              _buildUserInfoCard("Role", _userData!['role']),
            if (_userData!['firstName'] != null &&
                _userData!['firstName'].isNotEmpty)
              _buildUserInfoCard("First Name", _userData!['firstName']),
            if (_userData!['lastName'] != null &&
                _userData!['lastName'].isNotEmpty)
              _buildUserInfoCard("Last Name", _userData!['lastName']),
            if (_userData!['occupation'] != null &&
                _userData!['occupation'].isNotEmpty)
              _buildUserInfoCard("Occupation", _userData!['occupation']),
            if (_userData!['bio'] != null && _userData!['bio'].isNotEmpty)
              _buildUserInfoCard("Bio", _userData!['bio']),
            if (_userData!['serviceCategory'] != null &&
                _userData!['serviceCategory'].isNotEmpty)
              _buildUserInfoCard("Service Category", _userData!['serviceCategory']),
            if (_userData!['experienceLevel'] != null &&
                _userData!['experienceLevel'].isNotEmpty)
              _buildUserInfoCard("Experience Level", _userData!['experienceLevel']),

            // Display contact info
            if (_userData!['contactNumber'] != null && _userData!['contactNumber'].isNotEmpty)
              _buildUserInfoCard("Contact", _userData!['contactNumber']),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(userId: _userId),
                  ),
                );
                if (result == true) {
                  _getUserIdAndData();
                }
              },
              child: Text("Update Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signOut,
              child: Text("Sign Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(String label, String? value) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$label:",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal.shade800),
            ),
            Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 18, color: Colors.teal.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoUserData() {
    return Center(
      child: Text(
        "No user data available.",
        style: TextStyle(fontSize: 18, color: Colors.teal.shade700),
      ),
    );
  }
}
