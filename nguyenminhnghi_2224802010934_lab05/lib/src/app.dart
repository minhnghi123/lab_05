import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "screens/login_screen.dart";
import "screens/todo_list_screen.dart";
import "storage/auth_storage.dart";

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0FA3B1),
      brightness: Brightness.light,
    );

    final colorScheme = baseScheme.copyWith(
      secondary: const Color(0xFFF6AE2D),
      surface: const Color(0xFFF8F5F1),
    );

    return MaterialApp(
      title: "Todo Studio",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF2EFEA),
        textTheme: GoogleFonts.spaceGroteskTextTheme(),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF0E2A32),
        ),
      ),
      home: const SplashGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthStorage.hasSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final hasSession = snapshot.data ?? false;
        if (hasSession) {
          return const TodoListScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
