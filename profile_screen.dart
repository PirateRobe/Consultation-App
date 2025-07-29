

import 'dart:io';
import 'package:final_test/viewmodels/auth_view_model.dart';
import 'package:final_test/viewmodels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Form key to validate input fields
  final _formKey = GlobalKey<FormState>();

  // Controllers for contact number and student ID input fields
  final _contactController = TextEditingController();
  final _studentIdController = TextEditingController();

  // Tracks whether user is in edit mode or view mode
  bool _editMode = false;

  // Holds the URL of the profile photo (if any)
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    // Fetch user profile data from ViewModel using current user ID
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    Provider.of<ProfileViewModel>(
      context,
      listen: false,
    ).fetchProfile(auth.currentUser!.uid);
  }

  // Opens image picker and uploads the selected image as profile photo
  Future<void> _pickImage() async {
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    final picker = ImagePicker();

    // Pick image from gallery
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      // Upload picked image file to storage via ProfileViewModel
      final url = await Provider.of<ProfileViewModel>(
        context,
        listen: false,
      ).uploadProfileImage(auth.currentUser!.uid, File(picked.path));

      // Update UI with new photo URL
      setState(() {
        _photoUrl = url;
      });
    }
  }

  // Toggle between edit and view mode
  void _toggleEdit() => setState(() => _editMode = !_editMode);

  // Save updated profile data after validation
  void _save() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthViewModel>(context, listen: false);

      // Call updateProfile with new contact and studentId values
      await Provider.of<ProfileViewModel>(context, listen: false).updateProfile(
        auth.currentUser!.uid,
        {
          'contact': _contactController.text,
          'studentId': _studentIdController.text,
        },
      );

      // Exit edit mode
      setState(() => _editMode = false);

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Access profile data from ProfileViewModel
    final profileVM = Provider.of<ProfileViewModel>(context);
    final data = profileVM.profileData;

    // Show loading spinner while profile data is null (fetching)
    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If not editing, update text controllers and photoUrl with profile data
    if (!_editMode) {
      _contactController.text = data['contact'] ?? '';
      _studentIdController.text = data['studentId'] ?? '';
      _photoUrl = data['photoUrl'];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        actions: [
          // Edit / Cancel button toggles edit mode
          IconButton(
            icon: Icon(_editMode ? Icons.close : Icons.edit_outlined),
            onPressed: _toggleEdit,
            tooltip: _editMode ? 'Cancel' : 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile photo with editable camera icon overlay in edit mode
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    backgroundImage:
                        _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                    child:
                        // Show default icon if no photoUrl available
                        _photoUrl == null
                            ? Icon(
                              Icons.person_outline,
                              size: 60,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            )
                            : null,
                  ),
                ),
                // Show camera button only in edit mode
                if (_editMode)
                  FloatingActionButton.small(
                    onPressed: _pickImage,
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.camera_alt),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Card containing editable profile form fields
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Student ID input field, enabled only in edit mode
                      TextFormField(
                        controller: _studentIdController,
                        enabled: _editMode,
                        decoration: InputDecoration(
                          labelText: "Student ID",
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: !_editMode, // Fill background when disabled
                          fillColor: Colors.grey[100],
                        ),
                        validator: (val) => val!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),

                      // Contact number input field, enabled only in edit mode
                      TextFormField(
                        controller: _contactController,
                        enabled: _editMode,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Contact Number",
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: !_editMode,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (val) => val!.isEmpty ? "Required" : null,
                      ),

                      // Show Save Changes button only in edit mode
                      if (_editMode) ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Save Changes"),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
