import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await SupabaseService.client.auth.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read the ThemeProvider state
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.settings_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Dark Mode Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.dark_mode_outlined),
                            SizedBox(width: 8),
                            Text('Dark Mode:'),
                          ],
                        ),
                        Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (bool value) {
                            Provider.of<ThemeProvider>(context, listen: false).toggleDarkMode(value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Font Size Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Font Size:'),
                        Expanded(
                          child: Slider(
                            value: themeProvider.fontSize,
                            min: 14.0,
                            max: 20.0,
                            divisions: 3,
                            label: themeProvider.fontSize.round().toString(),
                            onChanged: (double value) {
                              // Update provider state
                              Provider.of<ThemeProvider>(context, listen: false).setFontSize(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Bold Text Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bold Text:'),
                        Switch(
                          value: themeProvider.isBold, // Read from provider
                          onChanged: (bool value) {
                            // Update provider state
                            Provider.of<ThemeProvider>(context, listen: false).toggleBold(value);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}