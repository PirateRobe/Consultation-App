/*
 * Student Numbers: 222034621, 221019559, 223083143, 223004229, 222074359, 223051502, 223021893
 * Student Names  : Temeki K, Maduna R, Ngwenya OL, Serebolo R, Rampedi MO, Masabala T, Sebolai KL
 * Question       : BookingFormScreen
 */

import 'package:final_test/models/student_booking_model.dart';
import 'package:final_test/viewmodels/auth_view_model.dart';
import 'package:final_test/viewmodels/booking_view_model.dart';
import 'package:final_test/views/booking_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookingFormScreen extends StatefulWidget {
  // Optional booking passed in for editing existing booking
  final BookingModel? booking;

  const BookingFormScreen({super.key, this.booking});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key to validate form fields
  final _lecturerList = [
    'Dr. Nel',
    'Prof. Einstein',
    'Ms. Mbhele',
  ]; // Sample lecturers list

  String? _selectedLecturer; // Selected lecturer from dropdown
  DateTime? _selectedDateTime; // Selected date and time
  final _topicController =
      TextEditingController(); // Controller for topic text field
  final _notesController =
      TextEditingController(); // Controller for notes text field

  @override
  void initState() {
    super.initState();
    // If editing an existing booking, populate fields with current data
    if (widget.booking != null) {
      _selectedLecturer = widget.booking!.lecturer;
      _selectedDateTime = widget.booking!.dateTime;
      _topicController.text = widget.booking!.topic;
      _notesController.text = widget.booking!.notes;
    }
  }

  // Submit handler for saving or updating booking
  Future<void> _submit() async {
    // Validate form and ensure date/time and lecturer are selected
    if (_formKey.currentState!.validate() &&
        _selectedDateTime != null &&
        _selectedLecturer != null) {
      final bookingVM = Provider.of<BookingViewModel>(context, listen: false);
      final userId =
          Provider.of<AuthViewModel>(context, listen: false).currentUser!.uid;

      // Create booking model object
      final booking = BookingModel(
        id: widget.booking?.id ?? '',
        studentId: userId,
        lecturer: _selectedLecturer!,
        dateTime: _selectedDateTime!,
        topic: _topicController.text,
        notes: _notesController.text,
        status: 'pending',
      );

      if (widget.booking == null) {
        // Add new booking
        await bookingVM.addBooking(booking);
        await bookingVM.fetchBookings(userId);
        final createdBooking = bookingVM.bookings.last;

        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booking successful"),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate to booking details screen for the new booking
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailsScreen(booking: createdBooking),
          ),
        );
      } else {
        // Update existing booking
        await bookingVM.updateBooking(widget.booking!.id, booking, userId);
        Navigator.pop(context); // Go back after update
      }
    }
  }

  // Date and time picker method
  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    // Show date picker with current date as minimum and 30 days max
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      initialDate: _selectedDateTime ?? now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date != null) {
      // If date chosen, show time picker
      final time = await showTimePicker(
        context: context,
        initialTime:
            _selectedDateTime != null
                ? TimeOfDay.fromDateTime(_selectedDateTime!)
                : TimeOfDay.now(),
      );
      if (time != null) {
        // Set selected date and time state
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit =
        widget.booking != null; // True if editing an existing booking

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Booking" : "New Booking"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey, // Assign form key for validation
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header text based on new or edit mode
              Text(
                isEdit ? "Update your booking" : "Book a consultation",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Fill in the details below",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Lecturer Dropdown field
              DropdownButtonFormField<String>(
                value: _selectedLecturer,
                items:
                    _lecturerList
                        .map(
                          (lect) =>
                              DropdownMenuItem(value: lect, child: Text(lect)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedLecturer = val),
                decoration: InputDecoration(
                  labelText: "Select Lecturer",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator:
                    (val) => val == null ? "Please select a lecturer" : null,
              ),
              const SizedBox(height: 20),

              // Date & Time Picker UI
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          _selectedDateTime == null
                              ? Colors.grey.withOpacity(0.5)
                              : theme.colorScheme.primary.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _selectedDateTime == null
                            ? "Select date and time"
                            : DateFormat(
                              'EEE, MMM d • h:mm a',
                            ).format(_selectedDateTime!),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color:
                              _selectedDateTime == null
                                  ? theme.textTheme.bodyLarge?.color
                                      ?.withOpacity(0.5)
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Validation error if no date/time selected
              if (_selectedDateTime == null)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    "Please select a date and time",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Consultation Topic text field
              TextFormField(
                controller: _topicController,
                decoration: InputDecoration(
                  labelText: "Consultation Topic",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.topic_outlined),
                ),
                validator:
                    (val) =>
                        val != null && val.length >= 20
                            ? null
                            : "Minimum 20 characters required",
              ),
              const SizedBox(height: 20),

              // Additional Notes field (optional)
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: "Additional Notes (Optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // Submit button - updates or submits booking
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEdit ? "Update Booking" : "Submit Booking",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
