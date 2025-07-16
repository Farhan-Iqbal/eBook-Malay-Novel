import 'package:ebook_malay__novel/providers/user_providers.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'theme.dart';
import 'views/home_screen.dart';
import '/login_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(
    MultiProvider( // Use MultiProvider to manage multiple providers
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()), // Add UserProvider
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
  // Removed _supabaseClient and _user as we'll primarily rely on UserProvider for custom auth status
  // final _supabaseClient = SupabaseService.client;
  // User? _user;

  @override
  void initState() {
    super.initState();
    // No longer directly listening to Supabase auth state changes here for primary user status,
    // as custom login handles it via UserProvider.
  }

  @override
  Widget build(BuildContext context) {
    // Determine which screen to show based on the UserProvider's currentUserId
    return Consumer2<ThemeProvider, UserProvider>( // Use Consumer2 to listen to both providers
      builder: (context, themeProvider, userProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Book Nest',
          theme: buildAppTheme(themeProvider.fontSize, themeProvider.isBold, false),
          darkTheme: buildAppTheme(themeProvider.fontSize, themeProvider.isBold, true),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          // Now, the home screen is determined by the UserProvider's currentUserId
          home: userProvider.currentUserId == null ? const LoginScreen() : const HomeScreen(),
        );
      },
    );
  }
}
