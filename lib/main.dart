import 'package:flutter/material.dart';
import '/services/supabase_service.dart';
import '/theme.dart';
import '/views/home_screen.dart'; // Create this file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Nest',
      theme: appTheme,
      home: const HomeScreen(),
      // Add routes for other screens like EbookDetailsScreen
    );
  }
}