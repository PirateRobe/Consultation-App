
import 'package:final_test/models/student_booking_model.dart';
import 'package:final_test/routes/route_manager.dart';
import 'package:final_test/viewmodels/auth_view_model.dart';
import 'package:final_test/viewmodels/booking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Screen showing detailed information about a booking,
/// including appointment details and actions to edit or delete.
class BookingDetailsScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailsScreen({super.key, required this.booking});

  /// Shows a confirmation dialog to confirm booking deletion.
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
              // Cancel button closes the dialog without any action.
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              // Delete button calls deleteBooking in the ViewModel,
              // then closes dialog, navigates back, and shows a SnackBar.
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
                  Navigator.pop(context); // Close confirmation dialog
                  Navigator.pop(context); // Go back to previous screen
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

  /// Navigates to the booking form screen for editing this booking.
  /// After editing, shows a SnackBar if the booking was updated.
  void _navigateToEdit(BuildContext context) async {
    final updated = await Navigator.pushNamed(
      context,
      RouteManager.bookingForm,
      arguments: booking,
    );

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
    final theme = Theme.of(context);

    // Format the booking datetime for display.
    final dateFormatted = DateFormat.yMMMd().add_jm().format(booking.dateTime);

    // Choose color based on booking status.
    final statusColor =
        booking.status == "confirmed"
            ? Colors.green
            : booking.status == "pending"
            ? Colors.orange
            : Colors.grey;

    return Scaffold(
      appBar: AppBar(title: const Text("Booking Details"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Container showing all appointment details.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title
                  Text(
                    "APPOINTMENT DETAILS",
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.textTheme.labelLarge?.color?.withOpacity(
                        0.6,
                      ),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Lecturer detail row with icon
                  _buildDetailRow(
                    icon: Icons.person_outline,
                    label: "Lecturer",
                    value: booking.lecturer,
                    theme: theme,
                  ),
                  const Divider(height: 30),

                  // Date and time detail row with icon
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: "Date & Time",
                    value: dateFormatted,
                    theme: theme,
                  ),
                  const Divider(height: 30),

                  // Topic detail row with icon
                  _buildDetailRow(
                    icon: Icons.topic_outlined,
                    label: "Topic",
                    value: booking.topic,
                    theme: theme,
                  ),
                  const Divider(height: 30),

                  // Notes detail row shown only if notes are not empty
                  if (booking.notes.isNotEmpty) ...[
                    _buildDetailRow(
                      icon: Icons.notes_outlined,
                      label: "Notes",
                      value: booking.notes,
                      theme: theme,
                    ),
                    const Divider(height: 30),
                  ],

                  // Status display with colored icon and label
                  Row(
                    children: [
                      Icon(
                        Icons.circle_outlined,
                        size: 20,
                        color: statusColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "STATUS",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.status.toUpperCase(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Row of action buttons: Back to Home and Edit
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        () => Navigator.pushReplacementNamed(
                          context,
                          RouteManager.home,
                        ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: theme.colorScheme.primary),
                    ),
                    child: const Text("BACK TO HOME"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _navigateToEdit(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    child: const Text("EDIT"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Delete booking button in full width with red background
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _confirmDelete(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red[600],
                ),
                child: const Text("DELETE BOOKING"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget for building a row displaying
  /// an icon, label, and value in a consistent style.
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label text (uppercased, small and slightly transparent)
              Text(
                label.toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              // Value text (larger, normal opacity)
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
