import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return true; // Login successful
    } catch (e) {
      print("Sign In Error: $e");
      return false; // Login failed
    }
  }

  // Register a new user
  Future<bool> registerWithEmail(
      String email,
      String password,
      String userRole,
      String age,
      String occupation,
      String bio,
      String serviceCategory,
      String experienceLevel,
      String firstName,
      String lastName,
      String contact, // Add contact parameter
      ) async {
    try {
      // Register the user
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      String userId = userCredential.user!.uid; // Get the unique user ID

      // Save user data in Firestore
      await _firestore.collection('users').doc(userId).set({
        'role': userRole,
        'age': age,
        'occupation': occupation,
        'bio': bio,
        'serviceCategory': serviceCategory,
        'experienceLevel': experienceLevel,
        'firstName': firstName,
        'lastName': lastName,
        'contact': contact, // Save contact number to Firestore
      });

      return true; // Registration successful
    } catch (e) {
      print("Registration Error: $e");
      return false; // Registration failed
    }
  }


  // Get the current user's ID
  Future<String> getCurrentUserId() async {
    User? user = _firebaseAuth.currentUser;
    return user != null ? user.uid : ''; // Return the user ID or an empty string if no user is logged in
  }

  // Fetch user data from Firestore
  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>; // Return user data
      } else {
        print("User document does not exist.");
        return null; // User document not found
      }
    } catch (e) {
      print("Fetch User Data Error: $e");
      return null; // Handle error appropriately
    }
  }

  // Sign out the user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}

