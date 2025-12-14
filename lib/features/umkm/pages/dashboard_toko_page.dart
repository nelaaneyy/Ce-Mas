import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cemas/features/umkm/pages/kelola_toko_page.dart';
import 'package:cemas/features/umkm/services/seller_service.dart';

class DashboardTokoPage extends StatefulWidget {
  const DashboardTokoPage({super.key});

  @override
  State<DashboardTokoPage> createState() => _DashboardTokoPageState();
}

class _DashboardTokoPageState extends State<DashboardTokoPage> {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A6EBD),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sellers')
            .doc(_uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Data toko tidak ditemukan",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String status = data['status'] ?? 'Menunggu';
          bool isVerified = status == 'Terverifikasi';

          String namaToko = data['namaToko'] ?? 'Nama Toko';
          String kategori = data['kategori'] ?? '-';
          String alamat = data['alamat'] ?? '-';
          String deskripsi = data['deskripsi'] ?? '-';
          String? fotoToko = data['fotoToko'] ?? data['fotoUmkm'] ?? data['foto'];

          return SafeArea(
            child: Column(
              children: [
                // Header Section
                _buildHeader(namaToko),

                // STATUS BANNER for Unverified/Rejected
                if (!isVerified)
                  Container(
                    width: double.infinity,
                    color: status == 'Ditolak' ? Colors.red : Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          status == 'Ditolak' ? Icons.cancel : Icons.info_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          status == 'Ditolak'
                              ? "Verifikasi Ditolak. Hubungi Admin."
                              : "Menunggu Verifikasi Admin. Fitur dibatasi.",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Scrollable Content
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Statistics Cards (2x2 Grid) - Realtime
                          StreamBuilder<Map<String, dynamic>>(
                            stream: SellerService().getStoreStatsStream(),
                            builder: (context, statsSnapshot) {
                              // Default values / Loading state
                              String productCount = '...';
                              String rating = '...';
                              String chatCount = '0';
                              String views = '0'; // Placeholder

                              if (statsSnapshot.hasData) {
                                productCount = statsSnapshot.data!['products'].toString();
                                rating = statsSnapshot.data!['rating'].toStringAsFixed(1);
                                // chatCount removed
                                views = statsSnapshot.data!['views'].toString();
                              }

                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildEnhancedStatCard(
                                          value: productCount,
                                          label: 'Produk',
                                          icon: Icons.inventory_2_outlined,
                                          gradientColors: const [Color(0xFF0A6EBD), Color(0xFF1E88E5)],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildEnhancedStatCard(
                                          value: views,
                                          label: 'Dilihat',
                                          icon: Icons.visibility_outlined,
                                          gradientColors: const [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Rating Full Width
                                  _buildEnhancedStatCard(
                                    value: rating,
                                    label: 'Rating',
                                    icon: Icons.star,
                                    gradientColors: const [Color(0xFFFFA726), Color(0xFFFFB74D)],
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Banner Image
                          _buildBannerImage(fotoToko),

                          const SizedBox(height: 20),

                          // Info Section
                          _buildInfoRow(
                            Icons.category_outlined,
                            'Kategori',
                            kategori,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            Icons.location_on_outlined,
                            'Alamat',
                            alamat,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            Icons.description_outlined,
                            'Deskripsi',
                            deskripsi,
                          ),

                          const SizedBox(height: 30),

                          // Primary Action Button (LOCKED if not verified)
                          _buildPrimaryButton(isVerified),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Header with Logo, Store Name, and Notification Icon
  Widget _buildHeader(String namaToko) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // Top Row: Logo and Notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Store Logo
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.store,
                  color: const Color(0xFF0A6EBD),
                  size: 24,
                ),
              ),
                // Notification Icon
              Row(
                children: [
                   Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // Navigate to AkunPage with flag
                        Navigator.pushNamed(
                          context, 
                          "/akunPage",
                          arguments: {'isFromStore': true},
                        ); 
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, "/notifikasiPage");
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Store Name
          Text(
            namaToko,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Enhanced Stat Card with Gradient & Interaction
  Widget _buildEnhancedStatCard({
    required String value,
    required String label,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Placeholder for future action
          },
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with background circle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                // Value
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                // Label
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Banner Image Section
  Widget _buildBannerImage(String? fotoToko) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: (fotoToko != null && fotoToko.isNotEmpty)
            ? Image.network(
                fotoToko,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.store,
          size: 60,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  // Info Row (Icon + Title + Content)
  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF0A6EBD),
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0A6EBD),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Primary Action Button (LOCKED LOGIC - Premium Style)
  Widget _buildPrimaryButton(bool isVerified) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isVerified
            ? const LinearGradient(
                colors: [Color(0xFF0A6EBD), Color(0xFF29B6F6)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isVerified ? null : Colors.grey[300],
        boxShadow: isVerified
            ? [
                BoxShadow(
                  color: const Color(0xFF0A6EBD).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isVerified) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KelolaTokoPage(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menu terkunci. Tunggu verifikasi admin.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isVerified ? Icons.inventory_2_outlined : Icons.lock_outline,
                color: isVerified ? Colors.white : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Kelola Produk',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isVerified ? Colors.white : Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
