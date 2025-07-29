

import 'package:cloud_firestore/cloud_firestore.dart';

/// A model class representing a user of the app.
class AppUser {
  final String email; // User's email address
  final String name; // User's full name
  final DateTime createdAt; // The date and time the user account was created

  /// Constructor to create an instance of AppUser
  AppUser({required this.email, required this.name, required this.createdAt});

  /// Factory constructor to create an AppUser object from Firestore data
  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      email: data['email'], // Retrieves user's email from Firestore data
      name: data['name'], // Retrieves user's name from Firestore data
      createdAt:
          (data['createdAt'] as Timestamp)
              .toDate(), // Converts Firestore timestamp to Dart DateTime
    );
  }

  /// Converts the AppUser object to a map for saving to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email, // Stores user's email
      'name': name, // Stores user's name
      'createdAt': createdAt, // Stores the account creation timestamp
    };
  }
}
