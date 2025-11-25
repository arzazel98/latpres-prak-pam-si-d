// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nitendo/screen/home_screen.dart';
import 'package:nitendo/screen/login_screen.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nintendo Amiibo App',

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF151517),
        primaryColor: const Color(0xFF6C63FF),
        fontFamily: 'Roboto',

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Halaman pertama yang dicek adalah AuthWrapper
      home: const AuthWrapper(),
    );
  }
}

// --- Auth Wrapper: Pengecek Status Login ---
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    // FutureBuilder akan mengecek status login saat aplikasi dimulai
    return FutureBuilder<bool>(
      future: _storageService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tampilkan loading screen/splash screen saat menunggu
          return const Scaffold(
            backgroundColor: Color(0xFF151517),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Jika sudah login (snapshot.data == true), arahkan ke Home
        if (snapshot.hasData && snapshot.data == true) {
          return const HomeScreen();
        }

        // Jika belum login atau data false, arahkan ke Login
        return const LoginScreen();
      },
    );
  }
}
