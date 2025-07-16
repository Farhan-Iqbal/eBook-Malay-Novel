import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/user.dart' as app_model;
import 'providers/user_providers.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  app_model.User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final userId = Provider.of<UserProvider>(
      context,
      listen: false,
    ).currentUserId;
    print('Fetching user profile for userId: $userId');
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      print('No userId found, stopping fetch');
      return;
    }
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('user_id', userId)
          .single()
          .maybeSingle();

      print('Supabase response: $response');

      if (response != null) {
        setState(() {
          _user = app_model.User.fromJson(response);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('No user data found');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching user profile: $e');
    }
  }

  void _navigateToEditProfile() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(user: _user)),
    );
    if (updated == true) {
      _fetchUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_user == null) {
      return const Center(child: Text('No user data available.'));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(
                _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : '',
                style: const TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(height: 16),
            Text('Name: ${_user!.name}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Email: ${_user!.email}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Phone: ${_user!.phoneNumber ?? 'N/A'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Role: ${_user!.role}', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
