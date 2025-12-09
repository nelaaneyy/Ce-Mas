import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cemas/core/services/auth_service.dart';
import 'package:cemas/features/user/widgets/umkm_card.dart';
import 'package:cemas/features/user/widgets/umkm_search_results.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key, required void Function(int index) onTabJump});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'Semua',
    'Kelontong',
    'Kuliner',
    'Jasa',
    'Transportasi',
  ];
  String _selectedFilter = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- METHODS ---

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // 1. APP BAR & HEADER (SliverAppBar)
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 220.0, // Increased to 220.0 to provide gap between text and search bar
            backgroundColor: const Color(0xFF0A6EBD),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A6EBD), Color(0xFF29B6F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 90, 20, 0), // Increased top padding to lower text
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildGreeting(),
                      const SizedBox(height: 4),
                      const Text(
                        "Mau cari apa hari ini?",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Custom Title/Actions in pinned mode (appears when collapsed)
            title: Row(
              children: [
                // LOGO - CircleAvatar implementation for perfect circle (Adjusted Size)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ClipOval(
                         child: Image.asset(
                          'assets/images/logocemas.jpeg',
                          fit: BoxFit.contain,
                          width: 36,
                          height: 36,
                          errorBuilder: (c,e,s) => const Icon(Icons.store, color: Color(0xFF0A6EBD), size: 20),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () => Navigator.pushNamed(context, "/notifikasiPage"),
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.white),
                  onPressed: () => Navigator.pushNamed(context, "/akunPage"),
                ),
              ],
            ),
            // PINNED SEARCH BAR
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80), // Size for SearchBar + Padding
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                width: double.infinity,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari UMKM, Produk, atau Jasa...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0A6EBD)),
                      suffixIcon: Container(
                         margin: const EdgeInsets.all(6),
                         decoration: const BoxDecoration(
                           color: Color(0xFF0A6EBD),
                           shape: BoxShape.circle,
                         ),
                         child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                       ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
              ),
            ),
          ),

          // 2. FILTER CHIPS (Now first item in body)
          SliverToBoxAdapter(
            child: Container(
              height: 40,
              margin: const EdgeInsets.only(top: 20, bottom: 20), // Added top margin

              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (c, i) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == _filters[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = _filters[index];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0A6EBD) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0A6EBD) : Colors.grey[300]!,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF0A6EBD).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          _filters[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 4. SECTION TITLE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rekomendasi Pilihan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UmkmSearchResults(
                            searchQuery: "", // Empty query to show all
                            selectedFilter: _selectedFilter == 'Semua' ? null : _selectedFilter,
                          ),
                        ),
                      );
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
            ),
          ),

          // 5. GRID CONTENT
          StreamBuilder<QuerySnapshot>(
            stream: (_selectedFilter == 'Semua')
                ? FirebaseFirestore.instance.collection('sellers').snapshots()
                : FirebaseFirestore.instance
                    .collection('sellers')
                    .where('kategori', isEqualTo: _selectedFilter)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_mall_directory_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("Belum ada UMKM ditemukan", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }

              var sellerDocs = snapshot.data!.docs;

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return UmkmCard(sellerData: sellerDocs[index]);
                    },
                    childCount: sellerDocs.length,
                  ),
                ),
              );
            },
          ),
          
          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Text(
        'Halo, Tamu!',
        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        String nama = 'Pengguna';
        if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            // Try to find a name field
            if (data['namaPertama'] != null) nama = data['namaPertama'];
            else if (data['nama'] != null) nama = data['nama'];
        }
        return Text(
          'Halo, $nama!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22, // Agak lebih kecil agar muat
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
