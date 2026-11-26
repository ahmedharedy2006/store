// ============================================================================
// Screen 1: AuthScreen
// Purpose: Allows users to Register a new account or Login with existing credentials.
// Storage: Saves and checks user credentials from Hive 'users_box'.
// State: AuthProvider handles the login/register state changes.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // State flag: true = Login Mode, false = Register Mode
  bool _isLoginMode = true;

  // Controllers for handling text input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Boolean to toggle password visibility (show/hide password)
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from tree to avoid memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Helper method to show clean error messages
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Method to handle Form submission for either Login or Register
  Future<void> _submitForm() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    // 1. Simple direct validation using if checks
    if (!_isLoginMode && name.isEmpty) {
      _showError('Please enter your full name');
      return;
    }

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      _showError('Please enter a valid email address');
      return;
    }

    if (password.length < 4) {
      _showError('Password must be at least 4 characters');
      return;
    }

    // 2. Access the AuthProvider using context.read
    final authProvider = context.read<AuthProvider>();

    // 3. Perform Login or Register depending on current mode
    bool success = false;
    if (_isLoginMode) {
      // Execute Login
      success = await authProvider.login(
        email: email,
        password: password,
      );
    } else {
      // Execute Register
      success = await authProvider.register(
        name: name,
        email: email,
        password: password,
      );
    }

    // 4. Handle navigation on success or display error message
    if (success && mounted) {
      // Navigate to HomeScreen upon successful login or registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (!success && mounted) {
      final errorMsg = authProvider.errorMessage ?? 'Authentication failed!';
      _showError(errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch AuthProvider for loading state changes
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      // Background gradient color for modern store app feel
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade800, Colors.indigo.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Shoppy App Icon
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withAlpha(40),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/shoppy_logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.shopping_bag_rounded,
                                size: 54,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Title Text
                        Text(
                          _isLoginMode ? 'Welcome to Shoppy' : 'Join Shoppy',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          _isLoginMode
                              ? 'Login to manage your store products & stock'
                              : 'Create an account to manage your store products',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 1. Name Field (Only visible when Registering)
                        if (!_isLoginMode) ...[
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // 2. Email Field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 3. Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 4. Submit Button (Login or Register)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: authProvider.isLoading ? null : _submitForm,
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isLoginMode ? 'Login' : 'Register',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 5. Toggle between Login & Register modes
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLoginMode = !_isLoginMode;
                            });
                          },
                          child: Text(
                            _isLoginMode
                                ? "Don't have an account? Register here"
                                : "Already have an account? Login here",
                            style: TextStyle(
                              color: Colors.indigo.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // 6. Quick Demo Account auto-fill helper (Convenient for demos and testing)
                        if (_isLoginMode) ...[
                          const SizedBox(height: 6),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              setState(() {
                                _emailController.text = 'admin@shoppy.com';
                                _passwordController.text = '1234';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.indigo.shade100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.flash_on, size: 16, color: Colors.indigo.shade700),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Fill Demo: admin@shoppy.com / 1234',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}
