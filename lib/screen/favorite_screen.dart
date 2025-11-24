// screen/favorite_screen.dart
import 'package:flutter/material.dart';
import 'package:nitendo/models/ambio_model.dart';
import '../services/storage_service.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final StorageService _storageService = StorageService();
  List<Amiibo> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Mengambil data dari local storage saat halaman dibuka
  void _loadFavorites() async {
    final data = await _storageService.getFavorites();
    setState(() {
      _favorites = data;
      _isLoading = false;
    });
  }

  // Fungsi Hapus Item
  void _removeFavorite(int index) async {
    Amiibo removedItem = _favorites[index];

    // Hapus dari state visual dulu agar cepat
    setState(() {
      _favorites.removeAt(index);
    });

    // Hapus dari storage fisik
    await _storageService.toggleFavorite(
      removedItem,
    ); // Toggle akan menghapus jika sudah ada

    // Tampilkan Snackbar sesuai soal [cite: 89]
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${removedItem.name} removed from favorites"),
          backgroundColor: const Color(0xFF2B2B2B),
          action: SnackBarAction(
            label: "UNDO",
            onPressed: () {
              // Fitur tambahan: Undo delete (Opsional tapi keren)
              _storageService.toggleFavorite(removedItem);
              _loadFavorites();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151517), // Dark Background
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar transparan
        elevation: 0,
        title: const Text(
          "My Favorites",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No favorites yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final amiibo = _favorites[index];

                // Widget Wajib: Dismissible untuk Swipe Delete
                return Dismissible(
                  key: Key(amiibo.head + amiibo.tail), // ID Unik
                  direction: DismissDirection.endToStart, // Swipe kanan ke kiri
                  onDismissed: (direction) {
                    _removeFavorite(index);
                  },
                  // Background Merah saat swipe
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  // Tampilan Item Favorite
                  child: GestureDetector(
                    onTap: () async {
                      // Navigasi ke detail, dan reload saat kembali (kali aja di-unlove dari detail)
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(amiibo: amiibo),
                        ),
                      );
                      _loadFavorites();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2B2B), // Kartu warna abu gelap
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          // Gambar Kecil
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              amiibo.image,
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 15),
                          // Teks Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  amiibo.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  amiibo.gameSeries,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    amiibo.type,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Icon Panah Kecil
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
