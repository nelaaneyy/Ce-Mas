import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cemas/features/umkm/services/seller_service.dart';

class DetailTokoPage extends StatefulWidget {
  final DocumentSnapshot
  sellerData; // Data toko yang dikirim dari halaman sebelumnya

  const DetailTokoPage({super.key, required this.sellerData});

  @override
  State<DetailTokoPage> createState() => _DetailTokoPageState();
}

class _DetailTokoPageState extends State<DetailTokoPage> {
  // Service Instance
  final SellerService _sellerService = SellerService();  

  @override
  void initState() {
    super.initState();
    // Record View (Uniqueness handled in Service)
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _sellerService.incrementStoreView(widget.sellerData.id);
    });
  }
  // Fungsi untuk membuka WhatsApp
  Future<void> _launchWA(String number, String message) async {
    // Format nomor (ganti 0 di depan dengan 62)
    if (number.startsWith('0')) {
      number = '62${number.substring(1)}';
    }

    final Uri url = Uri.parse(
      "https://wa.me/$number?text=${Uri.encodeComponent(message)}",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak bisa membuka WhatsApp")),
      );
    }
  }

  Widget _buildRatingSection(Map<String, dynamic> sellerData) {
    final num ratingNum = sellerData['rating'] ?? 0;
    final double rating = ratingNum.toDouble();
    final int reviewCount = sellerData['jumlahUlasan'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Rating & Ulasan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Rating Display
            if (rating > 0) ...[
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < rating.floor()
                            ? Icons.star_rounded
                            : (index < rating
                                ? Icons.star_half_rounded
                                : Icons.star_outline_rounded),
                        color: const Color(0xFFFFA000), // Amber 700
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "($reviewCount ulasan)",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // New Shop Badge (Large)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      "Toko Baru",
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700
                      ),
                    ),
                    const Text(
                      "Belum ada ulasan",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),
            
            // Add Review Button
            InkWell(
              onTap: () => _showAddReviewDialog(sellerData),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Colors.blue.shade800),
                    const SizedBox(width: 8),
                    Text(
                      "Tulis Ulasan",
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Reviews List
        _buildReviewsList(sellerData['sellerId'] ?? ''),
      ],
    );
  }

  Widget _buildReviewsList(String sellerId) {
    if (sellerId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "Belum ada ulasan",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final reviews = snapshot.data!.docs;

        return Column(
          children: reviews.map((doc) {
            final review = doc.data() as Map<String, dynamic>;
            return _buildReviewCard(review);
          }).toList(),
        );
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = review['rating'] as int? ?? 0;
    final userName = review['userName'] ?? 'Pengguna';
    final comment = review['comment'] ?? '';
    final timestamp = review['createdAt'] as Timestamp?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              index < rating ? Icons.star : Icons.star_outline,
                              color: Colors.amber,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timestamp != null
                                ? _formatDate(timestamp.toDate())
                                : 'Baru saja',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment,
              style: const TextStyle(fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  void _showAddReviewDialog(Map<String, dynamic> sellerData) {
    final ratingNotifier = ValueNotifier<int>(5);
    final commentController = TextEditingController();
    final sellerId = sellerData['sellerId'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Beri Ulasan"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Rating:"),
              const SizedBox(height: 8),
              ValueListenableBuilder<int>(
                valueListenable: ratingNotifier,
                builder: (context, rating, _) {
                  return Row(
                    children: List.generate(
                      5,
                      (index) => GestureDetector(
                        onTap: () => ratingNotifier.value = index + 1,
                        child: Icon(
                          index < rating ? Icons.star : Icons.star_outline,
                          color: Colors.amber,
                          size: 32,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text("Komentar:"),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Bagikan pengalaman Anda...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
            ElevatedButton(
              onPressed: () async {
                final comment = commentController.text.trim();
                // Validasi input
                if (comment.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Komentar tidak boleh kosong")),
                  );
                  return;
                }

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Silakan login terlebih dahulu")),
                    );
                    return;
                  }

                  // 1. Simpan Ulasan ke Sub-Collection
                  await FirebaseFirestore.instance
                      .collection('sellers')
                      .doc(sellerId)
                      .collection('reviews')
                      .add({
                        'rating': ratingNotifier.value,
                        'comment': comment,
                        'userName': user.displayName ?? 'Pengguna',
                        'userId': user.uid,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                  // 2. Update Rata-rata Rating (Best Effort)
                  // Kita pisahkan try-catch agar jika ini gagal (misal masalah izin),
                  // ulasan tetap dianggap berhasil terkirim.
                  try {
                    await _updateSellerRating(sellerId);
                  } catch (e) {
                    debugPrint("Gagal update rata-rata rating: $e");
                  }

                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Ulasan berhasil dikirim!"),
                        backgroundColor: Colors.green.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  }
                } catch (e) {
                  // Error saat simpan ulasan
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Gagal mengirim ulasan: $e"),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white, // Text White
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 2,
              ),
              child: const Text(
                "Kirim",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _updateSellerRating(String sellerId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerId)
          .collection('reviews')
          .get();

      if (snapshot.docs.isEmpty) return;

      double totalRating = 0;
      for (var doc in snapshot.docs) {
        totalRating += (doc['rating'] as int? ?? 0);
      }

      final avgRating = totalRating / snapshot.docs.length;

      await FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerId)
          .update({'rating': avgRating, 'jumlahUlasan': snapshot.docs.length});
    } catch (e) {
      debugPrint("Error updating seller rating: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String sellerId = widget.sellerData.id; 

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('sellers').doc(sellerId).snapshots(),
        builder: (context, snapshot) {
          // Use stream data if available, otherwise fallback to widget data
          Map<String, dynamic> data;
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
            data = snapshot.data!.data() as Map<String, dynamic>;
          } else {
            data = widget.sellerData.data() as Map<String, dynamic>;
          }

          return CustomScrollView(
            slivers: [
              // --- 1. HEADER GAMBAR TOKO ---
              SliverAppBar(
                expandedHeight: 200.0,
                pinned: true,
                backgroundColor: Colors.blue.shade800,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    data['namaToko'] ?? 'Toko',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  background: (data['fotoToko'] ?? data['fotoUmkm'] ?? data['foto']) != null && (data['fotoToko'] ?? data['fotoUmkm'] ?? data['foto']) != ''
                      ? Image.network(data['fotoToko'] ?? data['fotoUmkm'] ?? data['foto'], fit: BoxFit.cover)
                          : Container(
                          color: Colors.blue.shade800,
                          child: const Icon(
                            Icons.store,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              // --- 2. INFO TOKO ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Chip(
                            label: Text(data['kategori'] ?? 'Umum'),
                            backgroundColor: Colors.blue.shade50,
                            labelStyle: TextStyle(color: Colors.blue.shade800),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              data['alamat'] ?? '-',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data['deskripsi'] ?? 'Tidak ada deskripsi.',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Divider(height: 30),
                      _buildRatingSection(data),
                      const Divider(height: 30),
                      const Text(
                        "Daftar Produk",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // --- 3. DAFTAR PRODUK (GRID) ---
              StreamBuilder<QuerySnapshot>(
                // Query: Ambil produk yang sellerId-nya sama dengan toko ini
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .where('sellerId', isEqualTo: sellerId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: Text("Toko ini belum upload produk.")),
                      ),
                    );
                  }

                  var products = snapshot.data!.docs;

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        var prodData =
                            products[index].data() as Map<String, dynamic>;
                        return _buildProductCard(prodData, data['noWhatsapp'] ?? '');
                      }, childCount: products.length),
                    ),
                  );
                },
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> prodData, String sellerWA) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto Produk
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              child:
                  (prodData['fotoProduk'] != null &&
                      prodData['fotoProduk'] != '')
                  ? Image.network(
                      prodData['fotoProduk'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: Icon(Icons.fastfood, color: Colors.grey),
                      ),
                    ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prodData['namaProduk'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rp ${prodData['harga']}",
                  style: TextStyle(color: Colors.blue.shade800, fontSize: 12),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      _launchWA(
                        sellerWA,
                        "Halo, saya mau pesan ${prodData['namaProduk']}...",
                      );
                    },
                    child: const Text(
                      "Beli (WA)",
                      style: TextStyle(fontSize: 10, color: Colors.white),
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
}
