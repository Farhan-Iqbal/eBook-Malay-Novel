import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart'; // Import SubscriptionProvider
import '../theme.dart'; // For kPrimaryColor
import '/settings_screen.dart'; // To navigate to settings

class ReadEbookScreen extends StatelessWidget {
  final String ebookId;
  final VoidCallback onFinish;

  const ReadEbookScreen({
    super.key,
    required this.ebookId,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    // Watch the SubscriptionProvider to react to changes
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);

    // Check if the user is a reader and doesn't have an active subscription
    // Assuming you have a way to determine if the current user is a 'reader' role.
    // For simplicity, we'll assume ALL users need a subscription to read for this demo.
    // In a real app, you'd check user roles.

    if (!subscriptionProvider.isSubscriptionActive) {
      // Show a dialog if no active subscription
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSubscriptionRequiredDialog(context);
      });
      // Return an empty scaffold or a loading indicator while the dialog is shown
      return Scaffold(
        appBar: AppBar(title: const Text("Access Denied")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // If subscribed, proceed to display the content
    return Scaffold(
      appBar: AppBar(
        title: const Text("Read Ebook"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                "AI-generated essay or PDF viewer goes here for ebookId: $ebookId.\n\nEnjoy reading!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                onFinish();
                Navigator.pop(context);
              },
              child: const Text("Mark as Finished"),
            ),
          )
        ],
      ),
    );
  }

  void _showSubscriptionRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Subscription Required", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  "You need an active reading subscription to access this ebook.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/subscription_icon.png', // You might want to add a relevant icon
                  height: 80,
                  width: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  "Don't have a reading subscription?",
                  style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                        color: kPrimaryColor, // Use your primary color
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
                Navigator.of(context).pop(); // Go back from ReadEbookScreen
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor, // Use your primary color
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Get Subscription"),
            ),
          ],
        );
      },
    );
  }
}