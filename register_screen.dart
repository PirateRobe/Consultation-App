/*
 * Student Numbers: 222034621, 221019559, 223083143, 223004229, 222074359, 223051502, 223021893
 * Student Names  : Temeki K, Maduna R, Ngwenya OL, Serebolo R, Rampedi MO, Masabala T, Sebolai KL
 * Question       : RegisterScreen
 */

import 'package:final_test/viewmodels/auth_view_model.dart';
import 'package:final_test/views/admin_dashboard_screen.dart';
import 'package:final_test/views/home_screen.dart';
import 'package:final_test/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Form key to validate the registration form
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _contactController = TextEditingController();

  // Track if user selects Admin or Student role
  bool _isAdmin = false;

  // Loading state for showing spinner during registration
  bool _loading = false;

  // Toggle password visibility
  bool _obscurePassword = true;

  // Email input field widget with validation for '@'
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: "Email",
        prefixIcon: Icon(Icons.email_outlined),
        border: UnderlineInputBorder(),
      ),
      validator:
          (value) =>
              value != null && value.contains('@')
                  ? null
                  : "Enter a valid email",
    );
  }

  // Password input field with visibility toggle and validation
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: const UnderlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.length < 8) {
          return "Minimum 8 characters";
        }
        if (!value.contains('@')) {
          return "Must include '@'";
        }
        return null;
      },
    );
  }

  // Student ID input field, required only for student registration
  Widget _buildStudentIdField() {
    return TextFormField(
      controller: _studentIdController,
      decoration: const InputDecoration(
        labelText: "Student ID",
        prefixIcon: Icon(Icons.badge_outlined),
        border: UnderlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? "Required" : null,
    );
  }

  // Contact number input field, required only for student registration
  Widget _buildContactField() {
    return TextFormField(
      controller: _contactController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: "Contact Number",
        prefixIcon: Icon(Icons.phone_outlined),
        border: UnderlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? "Required" : null,
    );
  }

  // Register method triggered when user taps Register button
  void _register() async {
    // Validate form fields before proceeding
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      final authVM = Provider.of<AuthViewModel>(context, listen: false);

      String? error;

      if (_isAdmin) {
        // Register admin user with email & password only
        error = await authVM.registerAdmin(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Register student with extra fields: studentId and contact
        error = await authVM.registerStudent(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          studentId: _studentIdController.text.trim(),
          contact: _contactController.text.trim(),
        );
      }

      setState(() => _loading = false);

      if (error == null) {
        // Navigate to respective home screens after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    _isAdmin
                        ? const AdminDashboardScreen()
                        : const HomeScreen(),
          ),
        );
      } else {
        // Show error snackbar on registration failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration failed: $error"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        // Gradient background for the registration screen
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FlutterLogo(size: 80),
                  const SizedBox(height: 16),

                  // Title text
                  Text(
                    'Create Account',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle text
                  Text(
                    'Join us today',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Role selection buttons: Student or Admin
                  Column(
                    children: [
                      SizedBox(
                        width: 220,
                        child: OutlinedButton(
                          onPressed: () => setState(() => _isAdmin = false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color:
                                  !_isAdmin
                                      ? colorScheme.primary
                                      : Colors.grey.shade300,
                              width: !_isAdmin ? 2 : 1,
                            ),
                            backgroundColor:
                                !_isAdmin
                                    ? colorScheme.primary.withOpacity(0.1)
                                    : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Student",
                            style: TextStyle(
                              color:
                                  !_isAdmin ? colorScheme.primary : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 220,
                        child: OutlinedButton(
                          onPressed: () => setState(() => _isAdmin = true),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color:
                                  _isAdmin
                                      ? colorScheme.primary
                                      : Colors.grey.shade300,
                              width: _isAdmin ? 2 : 1,
                            ),
                            backgroundColor:
                                _isAdmin
                                    ? colorScheme.primary.withOpacity(0.1)
                                    : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Admin",
                            style: TextStyle(
                              color:
                                  _isAdmin ? colorScheme.primary : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Registration form fields
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildEmailField(),
                        const SizedBox(height: 24),
                        _buildPasswordField(),

                        // Show student ID and contact fields only if role is Student
                        if (!_isAdmin) ...[
                          const SizedBox(height: 24),
                          _buildStudentIdField(),
                          const SizedBox(height: 24),
                          _buildContactField(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Register button or loading spinner if registration in progress
                  Center(
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 3,
                        ),
                        child:
                            _loading
                                ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(
                                  _isAdmin
                                      ? "Register Admin"
                                      : "Register Student",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider with "OR" text between registration and login
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: theme.dividerColor.withOpacity(0.5),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OR",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: theme.dividerColor.withOpacity(0.5),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Prompt and button to navigate to login screen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed:
                            () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            ),
                        child: Text(
                          "Sign In",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
