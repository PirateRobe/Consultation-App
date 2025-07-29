

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// ViewModel for managing student profile data and profile image
class ProfileViewModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance; // Reference to Firestore
  final _storage = FirebaseStorage.instance; // Reference to Firebase Storage

  Map<String, dynamic>? profileData; // Holds fetched profile data

  /// Fetches profile data for a specific user by UID from Firestore
  Future<void> fetchProfile(String uid) async {
    final doc = await _firestore.collection('students').doc(uid).get();
    profileData = doc.data(); // Store fetched profile data
    notifyListeners(); // Notify UI to update
  }

  /// Updates profile fields in Firestore and refreshes local profile data
  Future<void> updateProfile(String uid, Map<String, dynamic> updates) async {
    await _firestore.collection('students').doc(uid).update(updates);
    await fetchProfile(uid); // Refresh profile data after update
  }

  /// Uploads a profile image to Firebase Storage and updates Firestore with the image URL
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage
        .ref()
        .child('profile_images')
        .child('$uid.jpg'); // Storage path
    await ref.putFile(imageFile); // Upload image
    final url = await ref.getDownloadURL(); // Get download URL
    await updateProfile(uid, {'photoUrl': url}); // Save image URL to Firestore
    return url; // Return image URL
  }
}
