import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme.dart';
// Removed: import 'package:uuid/uuid.dart'; // No longer needed

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  final List<String> _roles = ['reader', 'clerk']; // Roles a user can choose
  String? _selectedRole;

  // Removed: final Uuid _uuid = const Uuid(); // No longer needed

  @override
  void initState() {
    super.initState();
    _selectedRole = _roles.first; // Set 'reader' as the default selected role
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == null || _selectedRole!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a role.')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // IMPORTANT SECURITY WARNING:
      // This approach bypasses Supabase Auth's built-in secure password hashing and session management.
      // You MUST implement secure password hashing on your backend (e.g., a Supabase Edge Function)
      // before inserting the password into your 'users' table.
      // Storing plain text passwords is a severe security vulnerability.

      final String hashedPassword = _passwordController.text; // Replace with actual hashing logic

      // Removed: final String newUserId = _uuid.v4(); // No longer needed

      // Directly insert user data into the 'users' table
      // user_id will be automatically generated by the database due to gen_random_uuid() default value
      final response = await SupabaseService.client.from('users').insert({
        // Removed: 'user_id': newUserId, // No longer needed, DB handles it
        'name': _nameController.text,
        'email': _emailController.text,
        'password': hashedPassword, // REMEMBER TO HASH THIS SECURELY!
        'roles': _selectedRole!, // Ensure this matches your column name 'roles'
      }).select('user_id'); // Still select user_id to confirm insertion and get the generated ID

      if (response != null && response.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful. You can now log in.')),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration failed: No user data returned.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: kPrimaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight : FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter a strong password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator(color: kPrimaryColor)
                    : ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Already have an account? Log In",
                    style: TextStyle(color: kSubtleTextColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}