

import 'package:final_test/models/student_booking_model.dart'; // Import the booking model
import 'package:final_test/routes/route_manager.dart'; // Import route manager for navigation
import 'package:final_test/viewmodels/auth_view_model.dart'; // Import AuthViewModel for authentication state
import 'package:final_test/viewmodels/booking_view_model.dart'; // Import BookingViewModel for booking data
import 'package:flutter/material.dart'; // Flutter material package
import 'package:intl/intl.dart'; // Package for date formatting
import 'package:provider/provider.dart'; // Provider package for state management

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtain AuthViewModel instance (without listening for changes)
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    // Obtain BookingViewModel instance (without listening for changes)
    final bookingVM = Provider.of<BookingViewModel>(context, listen: false);
    // Get current logged-in user
    final user = authVM.currentUser;

    // If no user logged in, show message
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in.")));
    }

    // Main scaffold for the home screen
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        centerTitle: true,
        actions: [
          // Profile button in the app bar
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              // Navigate to profile screen
              Navigator.pushNamed(context, RouteManager.profile);
            },
          ),
          // Logout button in the app bar
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Perform logout
              await authVM.logout();
              // Navigate back to login screen, removing all previous routes
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteManager.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<BookingModel>>(
        // Listen to bookings stream for the current user
        stream: bookingVM.streamBookings(user.uid),
        builder: (context, snapshot) {
          // Handle error in stream
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }
          // Show loading indicator while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading bookings..."),
                ],
              ),
            );
          }

          // Retrieve bookings list or empty list if none
          final bookings = snapshot.data ?? [];

          // Show message if no bookings found
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 48),
                  const SizedBox(height: 16),
                  const Text("No bookings found"),
                  const SizedBox(height: 8),
                ],
              ),
            );
          }

          // Display bookings list along with a welcome message
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message with user email
                    Text(
                      "Welcome, ${user.email}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Header for bookings section
                    const Text("Your Bookings", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              // Expandable list of bookings
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    // Display each booking inside a BookingCard widget
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BookingCard(booking: bookings[index]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      // Floating button to add a new booking
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, RouteManager.bookingForm),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingModel booking; // Booking data passed from parent widget

  const BookingCard({super.key, required this.booking});

  // Determine color based on booking status
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "confirmed":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Show confirmation dialog before deleting a booking
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirm Deletion"),
            content: const Text(
              "Are you sure you want to delete this booking?",
            ),
            actions: [
              // Cancel button closes the dialog
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              // Delete button calls the booking deletion method
              TextButton(
                onPressed: () async {
                  final bookingVM = Provider.of<BookingViewModel>(
                    context,
                    listen: false,
                  );
                  final authVM = Provider.of<AuthViewModel>(
                    context,
                    listen: false,
                  );
                  await bookingVM.deleteBooking(
                    booking.id,
                    authVM.currentUser!.uid,
                  );
                  Navigator.pop(context); // Close dialog after deletion
                  // Show confirmation snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Booking deleted"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // Navigate to booking form for editing current booking
  void _navigateToEdit(BuildContext context) async {
    final updated = await Navigator.pushNamed(
      context,
      RouteManager.bookingForm,
      arguments: booking, // Pass current booking for editing
    );

    // If booking was updated, show snackbar confirmation
    if (updated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking updated"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format the booking date/time for display
    final formattedDate = DateFormat.yMMMd().add_jm().format(booking.dateTime);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row containing the booking topic and status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.topic,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(booking.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      color: _statusColor(booking.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            // Display the lecturer name
            Text(
              "With: ${booking.lecturer}",
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 8),
            // Row showing calendar icon and booking date/time
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(formattedDate),
              ],
            ),

            const SizedBox(height: 12),

            // Row containing Edit and Delete buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit booking button
                TextButton.icon(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  label: const Text(
                    "Edit",
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () => _navigateToEdit(context),
                ),
                const SizedBox(width: 8),
                // Delete booking button
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
