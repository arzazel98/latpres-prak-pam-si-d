// services/storage_service.dart
import 'dart:convert';
import 'package:nitendo/models/ambio_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyFavorite = 'favorite_amiibo';
  static const String keyUser = 'user_credentials';
  static const String keyLoggedIn = 'is_logged_in';

  // --- FUNGSI FAVORITE (Sama seperti sebelumnya) ---

  // Ambil semua data favorite
  Future<List<Amiibo>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString(keyFavorite);

    if (dataString != null) {
      final List<dynamic> jsonList = jsonDecode(dataString);
      return jsonList.map((json) => Amiibo.fromJson(json)).toList();
    }
    return [];
  }

  // Cek apakah item sudah difavorite-kan
  Future<bool> isFavorite(String head, String tail) async {
    final list = await getFavorites();
    return list.any((item) => item.head == head && item.tail == tail);
  }

  // Tambah atau Hapus Favorite (Toggle)
  Future<void> toggleFavorite(Amiibo item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getFavorites();

    final index = list.indexWhere(
      (element) => element.head == item.head && element.tail == item.tail,
    );

    if (index != -1) {
      list.removeAt(index);
    } else {
      list.add(item);
    }

    final String encodedData = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(keyFavorite, encodedData);
  }

  // --- FUNGSI AUTENTIKASI (BARU) ---

  // Register Pengguna
  Future<bool> registerUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Cek apakah user sudah terdaftar (kita asumsikan hanya 1 user untuk contoh ini)
    if (prefs.containsKey(keyUser)) {
      return false; // User sudah ada
    }

    final userData = jsonEncode({'username': username, 'password': password});
    await prefs.setString(keyUser, userData);
    return true; // Register sukses
  }

  // Login Pengguna
  Future<bool> loginUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString(keyUser);

    if (userDataString != null) {
      final userData = jsonDecode(userDataString);

      // Verifikasi username dan password
      if (userData['username'] == username &&
          userData['password'] == password) {
        await prefs.setBool(keyLoggedIn, true); // Set status login true
        return true; // Login sukses
      }
    }
    return false; // Login gagal
  }

  // Logout Pengguna
  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLoggedIn, false);
  }

  // Cek Status Login
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyLoggedIn) ?? false;
  }
}
