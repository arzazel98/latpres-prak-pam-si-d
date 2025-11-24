// services/storage_service.dart
import 'dart:convert';
import 'package:nitendo/models/ambio_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyFavorite = 'favorite_amiibo';

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

  // Cek apakah item sudah difavorite-kan (berdasarkan ID head+tail)
  Future<bool> isFavorite(String head, String tail) async {
    final list = await getFavorites();
    // Kita anggap ID unik adalah gabungan head + tail
    return list.any((item) => item.head == head && item.tail == tail);
  }

  // Tambah atau Hapus Favorite (Toggle)
  Future<void> toggleFavorite(Amiibo item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getFavorites();

    // Cek index apakah barang sudah ada
    final index = list.indexWhere(
      (element) => element.head == item.head && element.tail == item.tail,
    );

    if (index != -1) {
      // Jika sudah ada, hapus (Remove)
      list.removeAt(index);
    } else {
      // Jika belum ada, tambah (Add)
      list.add(item);
    }

    // Simpan kembali ke string JSON
    final String encodedData = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(keyFavorite, encodedData);
  }
}
