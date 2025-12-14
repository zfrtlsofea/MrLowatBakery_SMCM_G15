import 'package:flutter/material.dart';
import 'package:mr_lowat_bakery/userscreens/home/navigation_bar.dart'; // Update with your correct import
import 'package:mr_lowat_bakery/adminScreens/admin_login.dart';
import 'package:mr_lowat_bakery/userscreens/login/forget_password.dart';
import 'package:mr_lowat_bakery/userscreens/services/auth_services.dart'; // Import AuthService
import 'package:mr_lowat_bakery/userscreens/login/sign_up.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/CustomerLogin.jpg', // Ensure the image path is correct
              fit: BoxFit.cover,
            ),
          ),
          // Content Overlay
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sign Up Button
                Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewAccount(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const Spacer(),
                // Title with Gesture Detector for hidden gesture
                GestureDetector(
// SCM-MAJOR: Remove hidden long-press admin entry and replace with proper RBAC
// Breaking change: authentication and authorization flow will be refactored (simulation only)
                  onLongPress: () {
                    // Navigate to Admin Login Screen on long press
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginAdmin()),
                    );
                  },
                  child: const Text(
                    "Mr Lowat Bakery",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Made by hand, from scratch\nwith love",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 200),
                // Username Field
                buildTextField("Email", controller: _emailController),
                const SizedBox(height: 20),
                // Password Field
                buildTextField("Password", controller: _passwordController, obscureText: true),
                const SizedBox(height: 10),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PasswordResetPage()),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Error Message Display
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 10),
                // Log In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Log In",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a text field
  Widget buildTextField(String hintText, {bool obscureText = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.orange.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
      ),
    );
  }

  // Sign in method with Firebase Authentication using AuthService
  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Validate email and password fields
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
      });
      setState(() => _isLoading = false);
      return;
    }

    // Simple email format validation
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Attempt to sign in with the provided credentials
      await _authService.signIn(
        email: email,
        password: password,
      );

      // Navigate to Homepage after successful login.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavigationMenu()),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Invalid email or password.');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
