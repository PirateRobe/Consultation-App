/*
 * Student Numbers: 222034621, 221019559, 223083143, 223004229, 222074359, 223051502, 223021893
 * Student Names  : Temeki K, Maduna R, Ngwenya OL, Serebolo R, Rampedi MO, Masabala T, Sebolai KL
 * Question       : LoginScreen
 */

import 'package:final_test/routes/route_manager.dart';
import 'package:final_test/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers to capture user input for email and password
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State variables for "Remember me", loading state, and password visibility
  bool _rememberMe = false;
  bool _loading = false;
  bool _obscurePassword = true;

  // Handles login process
  Future<void> _login() async {
    setState(() => _loading = true); // Show loading indicator
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    // Attempt login with trimmed email and password
    final error = await authVM.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (error == null) {
      // If login successful, fetch user role to decide next screen
      final role = await authVM.fetchUserRole();
      setState(() => _loading = false); // Hide loading indicator

      // Navigate to admin dashboard or home screen based on role
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, RouteManager.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, RouteManager.home);
      }
    } else {
      // Show error message on failure and hide loading indicator
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  // Handles password reset logic
  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.contains('@')) {
      // If valid email, send reset link and notify user
      await Provider.of<AuthViewModel>(
        context,
        listen: false,
      ).resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset link has been sent to your email"),
        ),
      );
    } else {
      // Show error if email is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
    }
  }

  // Builds the email input field
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: "Email",
        prefixIcon: Icon(Icons.email_outlined),
        border: UnderlineInputBorder(),
      ),
    );
  }

  // Builds the password input field with visibility toggle
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
    );
  }

  // Builds the row containing "Remember me" checkbox and "Forgot password?" button
  Widget _buildRememberForgotRow(TextTheme textTheme, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(
            value: _rememberMe,
            onChanged: (val) => setState(() => _rememberMe = val!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Text("Remember me"),
          const Spacer(),
          TextButton(
            onPressed: _resetPassword,
            child: Text(
              "Forgot password?",
              style: textTheme.bodyMedium?.copyWith(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        // Background gradient decoration
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
                  // Flutter logo at top
                  const FlutterLogo(size: 80),
                  const SizedBox(height: 16),

                  // Welcome text styled with theme colors
                  Text(
                    'Welcome Back',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle text with opacity
                  Text(
                    'Sign in to continue',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email input field
                  _buildEmailField(),
                  const SizedBox(height: 24),

                  // Password input field with toggle
                  _buildPasswordField(),
                  const SizedBox(height: 8),

                  // Row with Remember Me checkbox and Forgot Password button
                  _buildRememberForgotRow(theme.textTheme, colorScheme.primary),
                  const SizedBox(height: 24),

                  // Login button with loading state
                  Center(
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
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
                                : const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider with "OR" text between lines
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

                  // Row with prompt to sign up and button to navigate to registration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed:
                            () => Navigator.pushNamed(
                              context,
                              RouteManager.register,
                            ),
                        child: Text(
                          "Sign up",
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
