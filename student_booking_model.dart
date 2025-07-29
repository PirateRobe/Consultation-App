

import 'package:cloud_firestore/cloud_firestore.dart';

/// A model representing a booking/consultation made by a student.
class BookingModel {
  final String id; // Unique ID of the booking (document ID from Firestore)
  final String studentId; // ID of the student who made the booking
  final String lecturer; // Name of the lecturer for the consultation
  final DateTime dateTime; // Date and time of the consultation
  final String topic; // Topic of the consultation
  final String notes; // Additional notes provided by the student
  final String status; // Status of the booking (e.g., pending, approved)

  /// Constructor to initialize all fields of BookingModel
  BookingModel({
    required this.id,
    required this.studentId,
    required this.lecturer,
    required this.dateTime,
    required this.topic,
    required this.notes,
    required this.status,
  });

  /// Factory method to create a BookingModel from Firestore map data
  factory BookingModel.fromMap(Map<String, dynamic> data, String id) {
    return BookingModel(
      id: id,
      studentId: data['studentId'] ?? '', // Handles missing studentId
      lecturer: data['lecturer'] ?? '', // Handles missing lecturer
      dateTime:
          (data['dateTime'] as Timestamp)
              .toDate(), // Converts Firestore Timestamp to DateTime
      topic: data['topic'] ?? '', // Handles missing topic
      notes: data['notes'] ?? '', // Handles missing notes
      status:
          data['status'] ??
          'pending', // Defaults to 'pending' if status is missing
    );
  }

  /// Converts the BookingModel into a map format for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'lecturer': lecturer,
      'dateTime': dateTime,
      'topic': topic,
      'notes': notes,
      'status': status,
    };
  }
}
