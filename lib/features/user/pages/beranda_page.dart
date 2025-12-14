import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        SnackBar(
          content: Text('Masukkan kata kunci pencarian', style: GoogleFonts.poppins()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
      backgroundColor: Colors.grey[50], // Very light grey base
      body: CustomScrollView(
        slivers: [
          // 1. APP BAR & HEADER (SliverAppBar) with Glassmorphism feel
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 240.0, // More breathing room
            backgroundColor: const Color(0xFF0A6EBD),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)], // Deep Blue to Light Blue
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  // Subtle overlay pattern or noise could go here
                  padding: const EdgeInsets.fromLTRB(24, 100, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildGreeting(),
                      const SizedBox(height: 8),
                      Text(
                        "Mau cari apa hari ini?",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Custom Title/Actions
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  // LOGO with Glass effect ring
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logocemas.jpeg',
                            fit: BoxFit.contain,
                            height: 40,
                            width: 40,
                            errorBuilder: (c,e,s) => const Icon(Icons.store, color: Color(0xFF0A6EBD)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildGlassActionButton(
                    icon: Icons.notifications_outlined,
                    onTap: () => Navigator.pushNamed(context, "/notifikasiPage"),
                  ),
                  const SizedBox(width: 12),
                  _buildGlassActionButton(
                    icon: Icons.person_outline,
                    onTap: () => Navigator.pushNamed(context, "/akunPage"),
                  ),
                ],
              ),
            ),
            // PINNED SEARCH BAR with Depth
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(90), 
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), // Increased padding
                width: double.infinity,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D47A1).withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: -5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.poppins(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Cari UMKM, Produk, atau Jasa...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0A6EBD)),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF0A6EBD),
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            onTap: _performSearch, // Make arrow functional too
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
              ),
            ),
          ),

          // 2. FILTER CHIPS (Animated & Modern)
          SliverToBoxAdapter(
            child: Container(
              height: 50, // Slightly taller for better touch targets
              margin: const EdgeInsets.only(top: 24, bottom: 24),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _filters.length,
                separatorBuilder: (c, i) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == _filters[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = _filters[index];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0A6EBD) : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.grey[200]!,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF0A6EBD).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                )
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                      ),
                      child: Center(
                        child: Text(
                          _filters[index],
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

          // 3. SECTION TITLE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rekomendasi Pilihan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B), // Slate 800
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UmkmSearchResults(
                            searchQuery: "",
                            selectedFilter: _selectedFilter == 'Semua' ? null : _selectedFilter,
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0A6EBD),
                      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
            ),
          ),

          // 4. GRID CONTENT
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
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.storefront_outlined, size: 70, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada UMKM ditemukan", 
                          style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 15)
                        ),
                      ],
                    ),
                  ),
                );
              }

              var sellerDocs = snapshot.data!.docs;

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.72, // Slightly taller cards
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Apply animation slide-in here if needed, but keeping it simple for now
                      return UmkmCard(sellerData: sellerDocs[index]);
                    },
                    childCount: sellerDocs.length,
                  ),
                ),
              );
            },
          ),
          
          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildGlassActionButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Text(
        'Halo, Tamu!',
        style: GoogleFonts.poppins(
          color: Colors.white, 
          fontSize: 24, 
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black26, offset: const Offset(0, 2), blurRadius: 4)],
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        String nama = 'Pengguna';
        if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            if (data['namaPertama'] != null) nama = data['namaPertama'];
            else if (data['nama'] != null) nama = data['nama'];
        }
        return Text(
          'Halo, $nama!',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            shadows: [const Shadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4)],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
