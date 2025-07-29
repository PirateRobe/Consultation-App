

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_test/models/student_booking_model.dart';
import 'package:flutter/foundation.dart';

/// ViewModel class to manage student bookings using Firestore.
class BookingViewModel extends ChangeNotifier {
  final _bookingRef = FirebaseFirestore.instance.collection(
    'bookings',
  ); // Reference to 'bookings' collection
  List<BookingModel> bookings = []; // List to store fetched bookings

  /// Fetch bookings for a specific student from Firestore, sorted by date.
  Future<void> fetchBookings(String studentId) async {
    final snapshot =
        await _bookingRef
            .where('studentId', isEqualTo: studentId)
            .orderBy('dateTime')
            .get();

    // Map Firestore documents to BookingModel list
    bookings =
        snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList();

    notifyListeners(); // Notify UI listeners to update
  }

  /// Returns a real-time stream of bookings for the student
  Stream<List<BookingModel>> streamBookings(String studentId) {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('studentId', isEqualTo: studentId)
        .orderBy('dateTime')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  /// Adds a new booking to Firestore and refreshes the list
  Future<void> addBooking(BookingModel booking) async {
    await _bookingRef.add(booking.toMap()); // Add new booking document
    await fetchBookings(booking.studentId); // Refresh list after addition
  }

  /// Deletes a booking from Firestore and refreshes the list
  Future<void> deleteBooking(String bookingId, String studentId) async {
    await _bookingRef.doc(bookingId).delete(); // Delete booking document
    await fetchBookings(studentId); // Refresh list after deletion
  }

  /// Updates an existing booking in Firestore and refreshes the list
  Future<void> updateBooking(
    String bookingId,
    BookingModel updated,
    String studentId,
  ) async {
    await _bookingRef.doc(bookingId).update(updated.toMap()); // Update document
    await fetchBookings(studentId); // Refresh list after update
  }
}
