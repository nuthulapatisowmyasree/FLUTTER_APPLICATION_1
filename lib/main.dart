import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:provider/provider.dart';

import 'user_provider.dart';

import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite Web
  databaseFactory = databaseFactoryFfiWeb;

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ==========================================================
      // GLOBAL APP THEME
      // ==========================================================

      theme: ThemeData(
        useMaterial3: true,

        // Main application color
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),

        // Default scaffold background
        scaffoldBackgroundColor:
            const Color(0xFFF1F8F3),

        // Global text theme
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontWeight: FontWeight.w800,
          ),
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w700,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
          ),
        ),

        // Global ElevatedButton style
        elevatedButtonTheme:
            ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 2,
            minimumSize:
                const Size(0, 50),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
          ),
        ),

        // Global OutlinedButton style
        outlinedButtonTheme:
            OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor:
                const Color(0xFF2E7D32),
            side: const BorderSide(
              color: Color(0xFF43A047),
            ),
            minimumSize:
                const Size(0, 50),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
          ),
        ),

        // Global input field theme
        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          fillColor:
              const Color(0xFFF7FAF8),

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                BorderSide.none,
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                BorderSide(
              color: Colors.grey.shade200,
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                const BorderSide(
              color: Color(0xFF2E7D32),
              width: 2,
            ),
          ),
        ),

        // Global AppBar style
        appBarTheme:
            const AppBarTheme(
          backgroundColor:
              Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      // ==========================================================
      // NAMED ROUTES
      // ==========================================================

      initialRoute: '/',

      routes: {
        '/': (context) =>
            const WelcomeScreen(),

        '/login': (context) =>
            const LoginScreen(),

        '/register': (context) =>
            const RegisterScreen(),

        '/admin-login': (context) =>
            const AdminLoginScreen(),
      },
    );
  }
}