

import 'package:final_test/routes/route_manager.dart';
import 'package:final_test/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Screen that allows an admin to register with email and password
class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  /// Handles admin registration logic
  void _registerAdmin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      final auth = Provider.of<AuthViewModel>(context, listen: false);
      final error = await auth.registerAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() => _loading = false);

      if (error == null) {
        Navigator.pushReplacementNamed(context, RouteManager.adminDashboard);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Registration failed: $error")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Registration")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 8,
            shape: const RoundedRectangleBorder(), // Default rectangle shape
            shadowColor: Colors.grey.withOpacity(0.4),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Create Admin Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Email Input Field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      validator:
                          (val) =>
                              val != null && val.contains('@')
                                  ? null
                                  : "Invalid email",
                    ),
                    const SizedBox(height: 16),

                    /// Password Input Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      obscureText: true,
                      validator:
                          (val) =>
                              val != null &&
                                      val.length >= 8 &&
                                      val.contains('@')
                                  ? null
                                  : "Min 8 chars, must include '@'",
                    ),
                    const SizedBox(height: 30),

                    /// Register Button with loading indicator
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _registerAdmin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child:
                            _loading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Register as Admin",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
