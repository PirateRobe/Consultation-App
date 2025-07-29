

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// ViewModel class for handling authentication and user roles.
class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Firebase authentication instance
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore database instance

  /// Getter to access the current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Registers a student and stores info in 'students' and 'users' collections
  Future<String?> registerStudent({
    required String email,
    required String password,
    required String studentId,
    required String contact,
  }) async {
    try {
      // Create user with Firebase Auth
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user!.uid;

      // Store student-specific details in 'students' collection
      await _firestore.collection('students').doc(uid).set({
        'email': email,
        'studentId': studentId,
        'contact': contact,
        'uid': uid,
      });

      // Store general role info in 'users' collection
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'role': 'student',
        'uid': uid,
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      print("❌ FirebaseAuthException: ${e.code} - ${e.message}");
      return e.message ?? "An error occurred during registration.";
    } catch (e) {
      print("❌ Unknown Error: $e");
      return "An unexpected error occurred.";
    }
  }

  /// Registers an admin and saves role info in 'admins' and 'users' collections
  Future<String?> registerAdmin({
    required String email,
    required String password,
  }) async {
    try {
      // Create admin user with Firebase Auth
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user!.uid;

      // Save admin-specific details in 'admins' collection
      await _firestore.collection('admins').doc(uid).set({
        'email': email,
        'isAdmin': true,
        'uid': uid,
      });

      // Save role info in common 'users' collection
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'role': 'admin',
        'uid': uid,
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Admin registration failed.";
    }
  }

  /// Logs in a user with email and password
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  /// Logs out the current user
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Sends a password reset email to the user
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Fetches the current user's role from the 'users' collection
  Future<String> fetchUserRole() async {
    if (currentUser == null) {
      throw Exception("No user is currently logged in.");
    }

    // Get the user's document from Firestore
    final doc =
        await _firestore.collection('users').doc(currentUser!.uid).get();
    final data = doc.data();

    if (data == null || !data.containsKey('role')) {
      return 'student'; // Default to student if no role is found
    }

    return data['role'] as String;
  }
}
