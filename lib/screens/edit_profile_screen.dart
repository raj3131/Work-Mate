import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../Auth/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;

  EditProfileScreen({required this.userId});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form fields
  String _role = 'Seeker';
  String _firstName = '';
  String _lastName = '';
  String _occupation = '';
  String _bio = '';
  String _serviceCategory = '';
  String _experienceLevel = '';
  String _contact = ''; // Contact number field for both Seeker and Provider

  // Controllers
  final TextEditingController _contactController = TextEditingController();

  // Loading state
  bool _isLoading = true;
  bool _showWarning = false; // State for warning visibility

  // Predefined service categories for the dropdown
  final List<String> _serviceCategories = [
    // General Labor
    'Plumbing',
    'Electrical Work',
    'Carpentry',
    'Masonry',
    'Painting',
    'Welding',
    'Landscaping',
    'Cleaning',
    'Housekeeping',
    'Security Guard',
    'Construction',

    // Skilled Trades
    'Auto Mechanic',
    'HVAC Technician',
    'Tailoring',
    'Sewing',
    'CNC Machinist',
    'Furniture Making',
    'Roofing',
    'Tile Setting',
    'Flooring Installation',
    'Glass Installation',

    // Personal Services
    'Hairdressing',
    'Barbering',
    'Makeup Artist',
    'Nail Technician',
    'Massage Therapy',
    'Personal Trainer',
    'Pet Grooming',
    'Childcare',
    'Elderly Care',

    // Technical Services
    'Graphic Design',
    'Web Development',
    'Software Development',
    'Network Administration',
    'Cybersecurity',
    'IT Support',
    'Digital Marketing',
    'Social Media Management',
    'SEO Specialist',
    'Content Writing',

    // Professional Services
    'Accountant',
    'Tax Preparation',
    'Legal Assistance',
    'Real Estate Agent',
    'Financial Advisor',
    'Consulting',
    'Project Management',
    'Event Planning',
    'Architecture',
    'Interior Design',

    // Educational Services
    'Tutoring',
    'Language Instruction',
    'Music Instruction',
    'Art Instruction',
    'Driving Instructor',

    // Healthcare Services
    'Nursing',
    'Physical Therapy',
    'Medical Assistant',
    'Dietitian',
    'Home Health Aide',
    'Pharmacy Technician',

    // Hospitality Services
    'Catering',
    'Baking',
    'Bartending',
    'Waitstaff',
    'Hotel Management',

    // Transportation Services
    'Delivery Services',
    'Moving Services',
    'Chauffeur',
    'Truck Driving',
    'Courier Services',

    // Miscellaneous
    'Photography',
    'Videography',
    'Translation',
    'Voice Acting',
    'Handyman',
    'Repair Services',
  ];


  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }



  // Fetch user data method
  Future<void> _fetchUserData() async {
    Map<String, dynamic>? userData = await _authService.fetchUserData(widget.userId);
    if (userData != null) {
      setState(() {
        _role = userData['role'] ?? 'Seeker';
        _firstName = userData['firstName'] ?? '';
        _lastName = userData['lastName'] ?? '';
        _occupation = userData['occupation'] ?? '';
        _bio = userData['bio'] ?? '';

        // Ensure _serviceCategory is valid by checking if it exists in _serviceCategories
        String fetchedCategory = userData['serviceCategory'] ?? '';
        _serviceCategory = _serviceCategories.contains(fetchedCategory) ? fetchedCategory : '';

        _experienceLevel = userData['experienceLevel'] ?? '';
        _contact = userData['contact'] ?? '';
        _contactController.text = _contact; // Set existing contact number in controller
        _isLoading = false;
      });
    }
  }


  // Future<void> _fetchUserData() async {
  //   Map<String, dynamic>? userData = await _authService.fetchUserData(widget.userId);
  //   if (userData != null) {
  //     setState(() {
  //       _role = userData['role'] ?? 'Seeker';
  //       _firstName = userData['firstName'] ?? '';
  //       _lastName = userData['lastName'] ?? '';
  //       _occupation = userData['occupation'] ?? '';
  //       _bio = userData['bio'] ?? '';
  //       _serviceCategory = userData['serviceCategory'] ?? '';
  //       _experienceLevel = userData['experienceLevel'] ?? '';
  //       _contact = userData['contact'] ?? '';
  //       _contactController.text = _contact; // Set existing contact number in controller
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _updateUserData() async {
    if (_role == 'Provider' && (_occupation.isEmpty || _bio.isEmpty || _serviceCategory.isEmpty || _experienceLevel.isEmpty)) {
      setState(() {
        _showWarning = true; // Show warning if any field is empty
      });
      return;
    }

    if (_contact.isNotEmpty && _contact.length != 10) {
      setState(() {
        _showWarning = true; // Show warning if contact number is not valid
      });
      return;
    }

    // Save data to Firestore
    await _firestore.collection('users').doc(widget.userId).update({
      'role': _role,
      'firstName': _firstName,
      'lastName': _lastName,
      'occupation': _occupation,
      'bio': _bio,
      'serviceCategory': _serviceCategory,
      'experienceLevel': _experienceLevel,
      'contact': _contactController.text, // Save the updated contact number
    });

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _contactController.dispose(); // Dispose of controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRoleDropdown(),
            SizedBox(height: 16),
            _buildTextField("First Name", _firstName, (value) => _firstName = value),
            SizedBox(height: 16),
            _buildTextField("Last Name", _lastName, (value) => _lastName = value),
            SizedBox(height: 16),
            _buildTextField(
                "Contact Number (+91)",
                _contact,
                    (value) {
                  _contact = value;
                  _contactController.text = value;
                },
                controller: _contactController,
                maxLines: 1,
                inputType: TextInputType.phone
            ),
            if (_role == 'Provider') ...[
              SizedBox(height: 16),
              _buildTextField("Occupation", _occupation, (value) => _occupation = value),
              SizedBox(height: 16),
              _buildTextField("Bio", _bio, (value) => _bio = value, maxLines: 4),
              SizedBox(height: 16),
              _buildDropdownField("Service Category", _serviceCategory, (value) {
                setState(() {
                  _serviceCategory = value ?? '';
                });
              }),
              SizedBox(height: 16),
              _buildTextField("Experience", _experienceLevel, (value) => _experienceLevel = value),
            ],
            if (_showWarning) ...[
              SizedBox(height: 16),
              Text(
                "Please fill in all required fields.",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _updateUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Role",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _role == 'Seeker' || _role == 'Provider' ? _role : 'Seeker',
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          items: ['Seeker', 'Provider']
              .map((role) => DropdownMenuItem(
            value: role,
            child: Text(role),
          ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _role = value;
                _showWarning = false; // Reset warning when role changes
                if (_role == 'Seeker') {
                  _occupation = '';
                  _bio = '';
                  _serviceCategory = '';
                  _experienceLevel = '';
                }
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildTextField(
      String labelText,
      String value,
      Function(String) onChanged, {
        int maxLines = 1,
        TextInputType inputType = TextInputType.text,
        TextEditingController? controller,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller ?? TextEditingController(text: value),
          onChanged: onChanged,
          maxLines: maxLines,
          keyboardType: inputType,
          inputFormatters: [
            if (inputType == TextInputType.phone) FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  // New dropdown field specifically for "Service Category"
  Widget _buildDropdownField(String label, String currentValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentValue.isNotEmpty ? currentValue : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          items: _serviceCategories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
