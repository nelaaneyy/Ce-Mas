import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cemas/core/services/auth_service.dart';
import 'package:cemas/features/user/widgets/umkm_card.dart'; // Import card yang baru kita buat
import 'package:cemas/features/user/widgets/umkm_search_results.dart'; // Import halaman hasil pencarian

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key, required void Function(int index) onTabJump});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final AuthService _authService = AuthService();
  late Future<DocumentSnapshot?> _userDataFuture;
  final TextEditingController _searchController = TextEditingController();

  // Data untuk filter chips
  final List<String> _filters = [
    'Semua',
    'Kelontong',
    'Kuliner',
    'Jasa',
    'Transportasi',
  ];
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk ambil data user saat halaman dimuat
    _userDataFuture = _authService.getCurrentUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100], // Warna latar belakang putih
      body: Stack(
        children: [
          // 1. Latar Belakang Biru (Header)
          Container(
            height: screenSize.height * 0.28, // Tinggi area biru
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30), // Sudut melengkung di bawah
              ),
            ),
          ),

          // 2. Konten di atas Latar Biru (App Bar, Greeting, Search)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- Custom App Bar ---
                  _buildCustomAppBar(),

                  const SizedBox(height: 20),

                  // --- Greeting (Sapaan) ---
                  _buildGreeting(),

                  const SizedBox(height: 20),

                  // --- Search Bar ---
                  _buildSearchBar(),
                ],
              ),
            ),
          ),

          // 3. Area Konten Putih (Scrollable)
          Padding(
            // Mulai konten putih sedikit di atas akhir area biru
            padding: EdgeInsets.only(top: screenSize.height * 0.25),
            child: Column(
              children: [
                // --- Filter Chips ---
                _buildFilterChips(),

                // --- Grid Rekomendasi ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Rekomendasi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // --- Grid UMKM dari Firestore ---
                        _buildUmkmGrid(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildCustomAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Ganti dengan logo-mu
        Image.asset(
          'assets/images/logocemas.jpeg', // Pastikan path ini benar!
          height: 40,
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/notifikasiPage");
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, "/akunPage");
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    // Kita pakai FutureBuilder untuk menampilkan nama user
    return FutureBuilder<DocumentSnapshot?>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          final doc = snapshot.data!;
          if (doc.exists && doc.data() != null) {
            final data = doc.data() as Map<String, dynamic>;
            final String nama =
                (data['namaPertama'] as String?)?.isNotEmpty == true
                ? data['namaPertama'] as String
                : 'Pengguna';

            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Halo, $nama!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
        }
        // Tampilkan default jika data tidak ada
        return const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Halo, Pengguna!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari UMKM/Produk/Jasa',
              prefixIcon: const Icon(Icons.search),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white, size: 30),
          onPressed: () {
            // TODO: Tampilkan filter
          },
        ),
      ],
    );
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan kata kunci pencarian')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UmkmSearchResults(
          searchQuery: query,
          selectedFilter: _selectedFilter == 'Semua' ? null : _selectedFilter,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(_filters[index]),
              selected: _selectedFilter == _filters[index],
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = _filters[index];
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.blue.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUmkmGrid() {
    // Kita pakai StreamBuilder untuk menampilkan data UMKM/Sellers
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        // Kita ambil data dari koleksi 'sellers'
        stream: (_selectedFilter == 'Semua')
            ? FirebaseFirestore.instance.collection('sellers').snapshots()
            : FirebaseFirestore.instance
                  .collection('sellers')
                  .where('kategori', isEqualTo: _selectedFilter)
                  .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada UMKM terdaftar.'));
          }

          var sellerDocs = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 kolom
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75, // Atur rasio card
            ),
            itemCount: sellerDocs.length,
            itemBuilder: (context, index) {
              // Kirim data 1 seller ke UmkmCard
              return UmkmCard(sellerData: sellerDocs[index]);
            },
          );
        },
      ),
    );
  }
}
