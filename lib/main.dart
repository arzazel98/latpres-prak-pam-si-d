// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk mengatur warna status bar HP
import 'package:nitendo/screen/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengatur warna status bar HP agar ikon-ikonnya (jam, baterai) berwarna putih
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Menghilangkan pita "Debug" di pojok kanan atas
      title: 'Nintendo Amiibo App',

      // Tema Global: Kita set ke Dark Mode agar cocok dengan UI yang kita buat
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark, // Agar text default otomatis putih
        scaffoldBackgroundColor: const Color(
          0xFF151517,
        ), // Warna background utama (Hitam Gelap)
        primaryColor: const Color(0xFF6C63FF), // Warna aksen (Ungu)
        // Mengatur font default (opsional, Google Fonts bisa ditambahkan jika mau)
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

      // Halaman pertama yang dibuka
      home: const HomeScreen(),
    );
  }
}
