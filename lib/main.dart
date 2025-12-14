import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:anached_denya/screens/home_screen.dart';
import 'package:anached_denya/screens/add_container_screen.dart';
import 'package:anached_denya/screens/edit_container_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://llloawrccyctaqqnmmzy.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsbG9hd3JjY3ljdGFxcW5tbXp5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzODc5ODUsImV4cCI6MjA4MDk2Mzk4NX0.YDrQTWS845_8HNRTo3UMDWhaVMJnZpAU-vWNvNVaSY0",
  );

  runApp(const AnacheadDynea());
}

class AnacheadDynea extends StatelessWidget {
  const AnacheadDynea({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/add':
            return MaterialPageRoute(
              builder: (_) => const AddContainerScreen(),
            );
          case '/edit':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => EditContainerScreen(songData: args),
            );
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}
