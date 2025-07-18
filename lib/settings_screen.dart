// lib/views/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart'; // Assuming you have a LoginScreen
import '../theme.dart'; // Assuming you have a ThemeProvider in theme.dart
import '../providers/subscription_provider.dart'; // Import SubscriptionProvider
import '../providers/user_providers.dart'; // Import UserProvider for logout

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await SupabaseService.client.auth.signOut();
      if (context.mounted) {
        // Clear any user-specific data from providers
        Provider.of<UserProvider>(context, listen: false).setUserId(null);
        Provider.of<SubscriptionProvider>(context, listen: false).clearSubscription(); // Clear subscription on logout

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

  void _purchaseSubscription(
      BuildContext context, String type, int durationInWeeks, double price) {
    final subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    final currentExpiry = subscriptionProvider.subscriptionExpiry;
    DateTime newExpiry;

    if (subscriptionProvider.isSubscriptionActive && currentExpiry != null) {
      // If already subscribed, extend from current expiry
      newExpiry = currentExpiry.add(Duration(days: durationInWeeks * 7));
    } else {
      // If not subscribed, start from now
      newExpiry = DateTime.now().add(Duration(days: durationInWeeks * 7));
    }

    subscriptionProvider.setSubscription(status: true, expiry: newExpiry);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully subscribed to $type for RM ${price.toStringAsFixed(2)}!'),
        backgroundColor: Colors.green,
      ),
    );
    // In a real app, you would integrate with a payment gateway here.
    // For this demo, we just update the local provider.
  }

  @override
  Widget build(BuildContext context) {
    // Read the ThemeProvider and SubscriptionProvider state
    final themeProvider = Provider.of<ThemeProvider>(context);
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align header to the start
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Settings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Theme Settings Card
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'App Theme',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Divider(height: 24),
                        // Dark Mode Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Dark Mode',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (value) {
                                themeProvider.toggleDarkMode(value); // Pass 'value' here
                              },
                              activeColor: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        // Bold Text Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bold Text',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Switch(
                              value: themeProvider.isBold,
                              onChanged: (value) {
                                themeProvider.toggleBold(value); // Pass 'value' here
                              },
                              activeColor: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        // Font Size Slider
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Font Size: ${themeProvider.fontSize.toInt()}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Slider(
                              value: themeProvider.fontSize,
                              min: 12.0,
                              max: 20.0,
                              divisions: 4, // 12, 14, 16, 18, 20
                              label: themeProvider.fontSize.toInt().toString(),
                              activeColor: Theme.of(context).colorScheme.primary,
                              onChanged: (value) {
                                Provider.of<ThemeProvider>(
                                  context,
                                  listen: false,
                                ).setFontSize(value);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Subscription Section Card
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reading Subscription',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Divider(height: 24),
                        if (subscriptionProvider.isSubscriptionActive) ...[
                          Text(
                            'Current Status: Active until ${subscriptionProvider.subscriptionExpiry!.toLocal().day}/${subscriptionProvider.subscriptionExpiry!.toLocal().month}/${subscriptionProvider.subscriptionExpiry!.toLocal().year}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.green),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Extend your subscription:',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                        ] else ...[
                          Text(
                            'Current Status: No Active Subscription',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.red),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Get a reading subscription:',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                        ],
                        _buildSubscriptionOption(
                          context,
                          '1 Week Subscription',
                          'RM 7.00',
                          7, // duration in weeks
                          7.00, // price
                        ),
                        _buildSubscriptionOption(
                          context,
                          '1 Month Subscription',
                          'RM 28.00',
                          4 * 7, // 4 weeks for 1 month
                          28.00, // price
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Center(
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
      ],
    );
  }

  Widget _buildSubscriptionOption(BuildContext context, String title,
      String price, int durationInWeeks, double actualPrice) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          _purchaseSubscription(context, title, durationInWeeks, actualPrice);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get instant access to all ebooks.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Chip(
                label: Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: kSecondaryColor.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}