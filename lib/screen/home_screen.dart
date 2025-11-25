// screen/home_screen.dart
import 'package:flutter/material.dart';
import 'package:nitendo/models/ambio_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'detail_screen.dart';
import 'favorite_screen.dart';
import 'login_screen.dart'; // Import LoginScreen agar bisa kembali ke sana

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AmiiboHomeContent(), // Halaman Utama
    const FavoriteScreen(), // Halaman Favorite
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151517),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1F1F1F),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}

// --- WIDGET KONTEN HOME ---
class AmiiboHomeContent extends StatefulWidget {
  const AmiiboHomeContent({super.key});

  @override
  State<AmiiboHomeContent> createState() => _AmiiboHomeContentState();
}

class _AmiiboHomeContentState extends State<AmiiboHomeContent> {
  final StorageService _storageService = StorageService();

  // VARIABLE DATA
  List<Amiibo> _allAmiibo = [];
  List<Amiibo> _filteredAmiibo = [];
  bool _isLoading = true;
  String _selectedCategory = "All";

  final List<String> _categories = [
    "All",
    "Super Mario",
    "The Legend of Zelda",
    "Pokemon",
    "Animal Crossing",
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // AMBIL DATA API
  Future<void> _fetchData() async {
    try {
      final data = await ApiService().getAllAmiibo();
      setState(() {
        _allAmiibo = data;
        _filteredAmiibo = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error: $e");
    }
  }

  // SEARCH LOGIC
  void _runSearch(String keyword) {
    List<Amiibo> results = [];
    if (keyword.isEmpty) {
      _filterByCategory(_selectedCategory);
      return;
    } else {
      results = _allAmiibo
          .where(
            (item) =>
                item.name.toLowerCase().contains(keyword.toLowerCase()) ||
                item.character.toLowerCase().contains(keyword.toLowerCase()),
          )
          .toList();
    }

    setState(() {
      _filteredAmiibo = results;
    });
  }

  // FILTER LOGIC
  void _filterByCategory(String category) {
    List<Amiibo> results = [];
    if (category == "All") {
      results = _allAmiibo;
    } else {
      results = _allAmiibo
          .where((item) => item.gameSeries.contains(category))
          .toList();
    }

    setState(() {
      _selectedCategory = category;
      _filteredAmiibo = results;
    });
  }

  // --- LOGOUT LOGIC (Baru) ---
  void _handleLogout() async {
    // 1. Panggil fungsi logout di service (hapus sesi)
    await _storageService.logoutUser();

    // 2. Arahkan kembali ke LoginScreen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER & SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title & LOGOUT BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Nintendo Amiibo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // TOMBOL LOGOUT (ICON MERAH)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2B2B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          // Tampilkan Dialog Konfirmasi Logout
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF2B2B2B),
                              title: const Text(
                                "Logout",
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                "Are you sure you want to logout?",
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Tutup dialog
                                    _handleLogout(); // Jalankan logout
                                  },
                                  child: const Text(
                                    "Logout",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // SEARCH BAR
                TextField(
                  onChanged: (value) => _runSearch(value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2B2B2B),
                    hintText: "Search amiibo...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: const Icon(Icons.tune, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // KATEGORI CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _categories.map((category) {
                final bool isActive = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => _filterByCategory(category),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF6C63FF)
                          : const Color(0xFF2B2B2B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category == "The Legend of Zelda" ? "Zelda" : category,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "New Releases",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // LIST VIEW
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAmiibo.isEmpty
                ? const Center(
                    child: Text(
                      "No Amiibo found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: _filteredAmiibo.length,
                    itemBuilder: (context, index) {
                      final amiibo = _filteredAmiibo[index];
                      return _buildAmiiboCard(context, amiibo);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // WIDGET CARD
  Widget _buildAmiiboCard(BuildContext context, Amiibo amiibo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(amiibo: amiibo)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF2B2B2B),
          image: DecorationImage(
            image: NetworkImage(amiibo.image),
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () {
                    _storageService.toggleFavorite(amiibo);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${amiibo.name} updated favorites"),
                        duration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 15,
              left: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 5),
                    Text(
                      "8.2",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildTag(amiibo.gameSeries),
                      const SizedBox(width: 8),
                      _buildTag(amiibo.type),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    amiibo.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Character: ${amiibo.character}",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
