import 'package:flutter/material.dart';

class ServiceCategories {
  static final List<String> categories = [
    'Coding',
    'Cleaning',
    'Designing',
    'Plumbing',
    'Electrical Work',
    'Car Wash',
    'Carpentry',
    'Masonry',
    'Painting',
    'Welding',
    'Landscaping',
    'Housekeeping',
    'Security Guard',
    'Construction',
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
    'Hairdressing',
    'Barbering',
    'Makeup Artist',
    'Nail Technician',
    'Massage Therapy',
    'Personal Trainer',
    'Pet Grooming',
    'Childcare',
    'Elderly Care',
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
    'Tutoring',
    'Language Instruction',
    'Music Instruction',
    'Art Instruction',
    'Driving Instructor',
    'Nursing',
    'Physical Therapy',
    'Medical Assistant',
    'Dietitian',
    'Home Health Aide',
    'Pharmacy Technician',
    'Catering',
    'Baking',
    'Bartending',
    'Waitstaff',
    'Hotel Management',
    'Delivery Services',
    'Moving Services',
    'Chauffeur',
    'Truck Driving',
    'Courier Services',
    'Photography',
    'Videography',
    'Translation',
    'Voice Acting',
    'Handyman',
    'Repair Services',
  ];

  static Widget dropdownWithFilter({
    required ValueChanged<String?> onChanged,
    String? selectedValue,
  }) {
    return _ServiceCategoriesDropdown(
      onChanged: onChanged,
      selectedValue: selectedValue,
    );
  }
}

class _ServiceCategoriesDropdown extends StatefulWidget {
  final ValueChanged<String?> onChanged;
  final String? selectedValue;

  const _ServiceCategoriesDropdown({required this.onChanged, this.selectedValue});

  @override
  _ServiceCategoriesDropdownState createState() => _ServiceCategoriesDropdownState();
}

class _ServiceCategoriesDropdownState extends State<_ServiceCategoriesDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> filteredCategories = ServiceCategories.categories;
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCategories);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          isDropdownOpen = false;
        });
      }
    });
  }

  void _filterCategories() {
    setState(() {
      filteredCategories = ServiceCategories.categories
          .where((category) =>
          category.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Searchable Input Field
          TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: 'Search Categories',
              labelStyle: TextStyle(
                fontFamily: 'Cursive',
                fontSize: 18,
                color: Colors.brown,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.brown),
              ),
              prefixIcon: Icon(Icons.search, color: Colors.brown),
              filled: true,
              fillColor: Color(0xFFF5E4C3), // Vintage parchment color
            ),
            style: TextStyle(
              fontFamily: 'Cursive',
              fontSize: 16,
              color: Colors.brown,
            ),
            onTap: () {
              setState(() {
                isDropdownOpen = true;
              });
            },
          ),
          const SizedBox(height: 8),
          // Dropdown List
          if (isDropdownOpen)
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5, // Restrict dropdown height
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return ListTile(
                      tileColor: Color(0xFFF5E4C3), // Background for dropdown
                      hoverColor: Color(0xFFD3B88C),
                      title: Text(
                        category,
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 16,
                          color: Colors.brown,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _searchController.text = category;
                          isDropdownOpen = false;
                        });
                        widget.onChanged(category);
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
