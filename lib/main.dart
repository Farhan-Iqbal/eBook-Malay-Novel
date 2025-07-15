import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'theme.dart';
import 'views/home_screen.dart';
import 'login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
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
  final _supabaseClient = SupabaseService.client;
  User? _user;

  @override
  void initState() {
    super.initState();
    // Listen for auth state changes
    _supabaseClient.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
        setState(() {
          _user = data.session?.user;
        });
      } else {
        setState(() {
          _user = null;
        });
      }
    });

    // Initial check for a session
    _user = _supabaseClient.auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Book Nest',
          theme: buildAppTheme(themeProvider.fontSize, themeProvider.isBold),
          home: _user == null ? const LoginScreen() : const HomeScreen(),
        );
      },
    );
  }
}