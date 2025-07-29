

import 'package:final_test/models/student_booking_model.dart';
import 'package:final_test/views/admin_dashboard_screen.dart';
import 'package:final_test/views/admin_register_screen.dart';
import 'package:final_test/views/booking_details_screen.dart';
import 'package:final_test/views/booking_form_screen.dart';
import 'package:final_test/views/home_screen.dart';
import 'package:final_test/views/login_screen.dart';
import 'package:final_test/views/profile_screen.dart';
import 'package:final_test/views/register_screen.dart';
import 'package:flutter/material.dart';

/// A class to manage all route navigation in the app.
class RouteManager {
  // Define route names as constants
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String bookingForm = '/booking-form';
  static const String bookingDetails = '/booking-details';
  static const String adminRegister = '/admin-register';
  static const String adminDashboard = '/admin-dashboard';

  /// Generates the appropriate route based on the given settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        // Navigate to LoginScreen
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        // Navigate to RegisterScreen
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case home:
        // Navigate to HomeScreen
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case profile:
        // Navigate to ProfileScreen
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case bookingForm:
        // Navigate to BookingFormScreen with optional BookingModel argument
        final booking = settings.arguments as BookingModel?;
        return MaterialPageRoute(
          builder: (_) => BookingFormScreen(booking: booking),
        );

      case bookingDetails:
        // Navigate to BookingDetailsScreen with BookingModel argument
        final booking = settings.arguments as BookingModel;
        return MaterialPageRoute(
          builder: (_) => BookingDetailsScreen(booking: booking),
        );

      case adminRegister:
        // Navigate to AdminRegisterScreen
        return MaterialPageRoute(builder: (_) => const AdminRegisterScreen());

      case adminDashboard:
        // Navigate to AdminDashboardScreen
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      default:
        // Handle unknown routes by showing a 404 page
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('404: Page Not Found')),
              ),
        );
    }
  }
}
