import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart'; // Assuming you have a LoginScreen
import '../theme.dart'; // Assuming you have a ThemeProvider in theme.dart

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await SupabaseService.client.auth.signOut();
      if (context.mounted) {
        // Clear any user-specific data from providers if necessary
        // For example, if UserProvider holds current user ID:
        // Provider.of<UserProvider>(context, listen: false).setUserId(null);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to sign out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read the ThemeProvider state
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align header to the start
      children: [
        // Section Header for Settings
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16.0,
            16.0,
            16.0,
            8.0,
          ), // Consistent padding
          child: Text(
            'App Settings', // Your desired header text
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Expanded(
          // Wrap the main content in Expanded to take remaining space
          child: SingleChildScrollView(
            // Added SingleChildScrollView for scrollability
            padding: const EdgeInsets.all(16.0), // Original padding adjusted
            child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .start, // Changed to start to push content down
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 150), // Height to move card lower
                Center(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min, // Make column take minimum space
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
                                  Provider.of<ThemeProvider>(
                                    context,
                                    listen: false,
                                  ).toggleDarkMode(value);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Bold Text Toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.format_bold_outlined),
                                  SizedBox(width: 8),
                                  Text('Bold Text:'),
                                ],
                              ),
                              Switch(
                                value:
                                    themeProvider.isBold, // Read from provider
                                onChanged: (bool value) {
                                  // Update provider state
                                  Provider.of<ThemeProvider>(
                                    context,
                                    listen: false,
                                  ).toggleBold(value);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Font Size Slider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.text_fields_outlined),
                                  SizedBox(width: 8),
                                  Text('Font Size:'),
                                ],
                              ),
                              Expanded(
                                child: Slider(
                                  value: themeProvider.fontSize,
                                  min: 14.0,
                                  max: 20.0,
                                  divisions: 3,
                                  label: themeProvider.fontSize
                                      .round()
                                      .toString(),
                                  onChanged: (double value) {
                                    // Update provider state
                                    Provider.of<ThemeProvider>(
                                      context,
                                      listen: false,
                                    ).setFontSize(value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 48,
                ), // <--- Re-added SizedBox below the card
                Center(
                  // <--- Wrapped button in Center for horizontal alignment
                  child: ElevatedButton.icon(
                    onPressed: () => _signOut(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Log Out'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Removed the Padding and Center that were wrapping the button here
      ],
    );
  }
}
