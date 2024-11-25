import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Auth/auth_service.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  final _bioController = TextEditingController();
  final _serviceCategoryController = TextEditingController();
  final _experienceLevelController = TextEditingController();
  final _contactController = TextEditingController(); // Contact number controller
  final AuthService _authService = AuthService();

  String _userRole = 'Seeker'; // Default role

  void _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String age = _ageController.text.trim();
    String occupation = _occupationController.text.trim();
    String bio = _bioController.text.trim();
    String serviceCategory = _serviceCategoryController.text.trim();
    String experienceLevel = _experienceLevelController.text.trim();
    String contactNumber = _contactController.text.trim(); // Contact number value

    // Validation checks
    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || contactNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill in all required fields.")));
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Passwords do not match!")));
      return;
    }

    // Attempt registration
    bool success = await _authService.registerWithEmail(
        email, password, _userRole, age, occupation, bio, serviceCategory, experienceLevel, firstName, lastName, contactNumber);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration successful!")));
      Navigator.pop(context); // Navigate back to login screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed! Please try again.")));
    }
  }



  String? validateContact(String contact) {
    // Check if the contact number is exactly 10 digits
    if (contact.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(contact)) {
      return "Please enter a valid 10-digit contact number";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<String>(
                value: _userRole,
                items: <String>['Seeker', 'Provider'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _userRole = newValue!;
                  });
                },
              ),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: "First Name"),
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: "Last Name"),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: "Confirm Password"),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Restrict input to digits only
              ),
              TextField(
                controller: _occupationController,
                decoration: InputDecoration(labelText: "Occupation"),
              ),
              TextField(
                controller: _bioController,
                decoration: InputDecoration(labelText: "Short Bio"),
              ),
              TextField(
                controller: _contactController, // Contact number input
                decoration: InputDecoration(
                  labelText: "Contact Number",
                  prefixText: "+91 ", // Prepend country code
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  // Only allow numeric input and enforce a length of 10 digits
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10), // Limit to 10 digits
                ],
                onChanged: (value) {
                  // Optionally, you can add validation here
                  if (value.length == 10) {
                    // Optional: You can add further validation for valid phone number patterns if needed
                  }
                },
              ),

              if (_userRole == 'Provider') ...[
                TextField(
                  controller: _serviceCategoryController,
                  decoration: InputDecoration(labelText: "Service Category"),
                ),
                TextField(
                  controller: _experienceLevelController,
                  decoration: InputDecoration(labelText: "Experience Level"),
                ),
              ],
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _register,
                child: Text("Register"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to login screen
                },
                child: Text("Already have an account? Login here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
