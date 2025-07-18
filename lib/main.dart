import 'package:ebook_malay__novel/providers/user_providers.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'theme.dart';
import 'views/home_screen.dart';
import '/login_screen.dart';
import 'providers/subscription_provider.dart'; // Import the new provider

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();

  // Initialize and load subscription status before running the app
  final subscriptionProvider = SubscriptionProvider();
  await subscriptionProvider.loadSubscriptionStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider.value(value: subscriptionProvider), // Add SubscriptionProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Determine which screen to show based on the UserProvider's currentUserId
    return Consumer3<ThemeProvider, UserProvider, SubscriptionProvider>( // Use Consumer3
      builder: (context, themeProvider, userProvider, subscriptionProvider, child) { // Add subscriptionProvider
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Book Nest',
          theme: buildAppTheme(themeProvider.fontSize, themeProvider.isBold, false),
          darkTheme: buildAppTheme(themeProvider.fontSize, themeProvider.isBold, true),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: userProvider.currentUserId == null
              ? const LoginScreen()
              : const HomeScreen(),
        );
      },
    );
  }
}