// screen/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:nitendo/models/ambio_model.dart';
import '../services/storage_service.dart';

class DetailScreen extends StatefulWidget {
  final Amiibo amiibo;

  const DetailScreen({super.key, required this.amiibo});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    bool status = await _storageService.isFavorite(
      widget.amiibo.head,
      widget.amiibo.tail,
    );
    setState(() {
      isFavorite = status;
    });
  }

  void _toggleFavorite() async {
    await _storageService.toggleFavorite(widget.amiibo);
    setState(() {
      isFavorite = !isFavorite;
    });

    // Tampilkan Snackbar feedback (opsional tapi bagus)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? "Added to Favorites" : "Removed from Favorites",
        ),
        backgroundColor: isFavorite ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151517), // Background Gelap Utama
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER IMAGE (Full Width dengan Tombol Back & Fav)
            Stack(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2B2B),
                    image: DecorationImage(
                      image: NetworkImage(widget.amiibo.image),
                      fit: BoxFit.contain, // Agar figure tidak terpotong
                    ),
                  ),
                ),
                // Gradient Hitam di bawah gambar agar menyatu dengan body
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, const Color(0xFF151517)],
                      ),
                    ),
                  ),
                ),
                // Tombol Back & Love (Overlay)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircleButton(
                          icon: Icons.arrow_back_ios_new,
                          onTap: () => Navigator.pop(context),
                        ),
                        _buildCircleButton(
                          icon: isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                          onTap: _toggleFavorite,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 2. JUDUL & UTAMA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.amiibo.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${widget.amiibo.amiiboSeries} • ${widget.amiibo.gameSeries}",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),

                  const SizedBox(height: 30),

                  // 3. STATS GRID (Head, Tail, Type, Character)
                  const Text(
                    "Specifications",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildInfoCard("Character", widget.amiibo.character),
                      _buildInfoCard("Type", widget.amiibo.type),
                      _buildInfoCard("Head Hex", widget.amiibo.head),
                      _buildInfoCard("Tail Hex", widget.amiibo.tail),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 4. RELEASE DATES SECTION
                  const Text(
                    "Release Dates",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B2B2B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: _buildReleaseDates(widget.amiibo.release),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Tombol Bulat di atas
  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4), // Semi transparan
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // Helper Widget: Kartu Info Kecil
  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Helper Widget: List Tanggal Rilis
  List<Widget> _buildReleaseDates(Map<String, dynamic>? releaseDates) {
    if (releaseDates == null || releaseDates.isEmpty) {
      return [
        const Text("No release info", style: TextStyle(color: Colors.grey)),
      ];
    }
    return releaseDates.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              entry.key.toUpperCase(),
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              entry.value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
