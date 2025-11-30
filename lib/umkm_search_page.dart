import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_toko_page.dart';

class UmkmSearchPage extends StatefulWidget {
  const UmkmSearchPage({super.key});

  @override
  State<UmkmSearchPage> createState() => _UmkmSearchPageState();
}

class _UmkmSearchPageState extends State<UmkmSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearched = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  final List<String> _recommendationTags = [
    'Kuliner',
    'Kelontong',
    'Jasa',
    'Transportasi',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _hasSearched = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final results = <Map<String, dynamic>>[];
      final queryLower = query.toLowerCase();

      // 1. Search UMKM/Sellers
      final sellersSnapshot = await firestore.collection('sellers').get();
      for (var doc in sellersSnapshot.docs) {
        final data = doc.data();
        final namaToko = (data['namaToko'] as String?)?.toLowerCase() ?? '';
        final deskripsi = (data['deskripsi'] as String?)?.toLowerCase() ?? '';
        final kategori = (data['kategori'] as String?)?.toLowerCase() ?? '';

        final matches =
            namaToko.contains(queryLower) ||
            deskripsi.contains(queryLower) ||
            kategori.contains(queryLower);

        if (matches) {
          results.add({
            'type': 'seller',
            'doc': doc,
            'namaToko': data['namaToko'] ?? '',
            'kategori': data['kategori'] ?? '',
            'deskripsi': data['deskripsi'] ?? '',
            'foto': data['foto'] ?? data['fotoToko'] ?? '',
          });
        }
      }

      // 2. Search Products
      final productsSnapshot = await firestore.collection('products').get();
      for (var doc in productsSnapshot.docs) {
        final data = doc.data();
        final namaProduk = (data['namaProduk'] as String?)?.toLowerCase() ?? '';
        final deskripsi = (data['deskripsi'] as String?)?.toLowerCase() ?? '';
        final harga = data['harga'] ?? 0;

        if (namaProduk.contains(queryLower) || deskripsi.contains(queryLower)) {
          results.add({
            'type': 'product',
            'doc': doc,
            'namaProduk': data['namaProduk'] ?? '',
            'deskripsi': data['deskripsi'] ?? '',
            'foto': data['fotoProduk'] ?? '',
            'harga': harga,
            'sellerId': data['sellerId'] ?? '',
          });
        }
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Search error: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text(
          'Cari UMKM',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Cari nama toko, produk, atau kategori...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.blue.shade800),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),

          // Content
          Expanded(
            child: !_hasSearched
                ? _buildRecommendationTags()
                : (_isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (_searchResults.isEmpty
                            ? _buildEmptyState()
                            : _buildSearchResults())),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationTags() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Kategori Rekomendasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recommendationTags.map((tag) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = tag;
                  _performSearch(tag);
                },
                child: Chip(
                  label: Text(tag),
                  backgroundColor: Colors.blue.shade100,
                  labelStyle: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          Center(
            child: Column(
              children: [
                Icon(Icons.search, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Mulai pencarian',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada hasil untuk "${_searchController.text}"',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _hasSearched = false;
                _searchResults = [];
              });
            },
            child: const Text('Coba Cari Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        if (item['type'] == 'seller') {
          return _buildSellerCard(item);
        } else {
          return _buildProductCard(item);
        }
      },
    );
  }

  Widget _buildSellerCard(Map<String, dynamic> item) {
    final doc = item['doc'] as DocumentSnapshot;
    final namaToko = item['namaToko'] ?? '';
    final kategori = item['kategori'] ?? '';
    final deskripsi = item['deskripsi'] ?? '';
    final foto = item['foto'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailTokoPage(sellerData: doc),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            // Foto
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                color: Colors.grey[200],
              ),
              child: foto.isNotEmpty
                  ? Image.network(
                      foto,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.store,
                          size: 40,
                          color: Colors.grey[400],
                        );
                      },
                    )
                  : Icon(Icons.store, size: 40, color: Colors.grey[400]),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Toko",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      namaToko,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        kategori,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deskripsi,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    final namaProduk = item['namaProduk'] ?? '';
    final deskripsi = item['deskripsi'] ?? '';
    final harga = item['harga'] ?? 0;
    final foto = item['foto'] ?? '';

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Produk: $namaProduk')));
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            // Foto Produk
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                color: Colors.grey[200],
              ),
              child: foto.isNotEmpty
                  ? Image.network(
                      foto,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.fastfood,
                          size: 40,
                          color: Colors.grey[400],
                        );
                      },
                    )
                  : Icon(Icons.fastfood, size: 40, color: Colors.grey[400]),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Produk",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      namaProduk,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Rp ${harga.toString()}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deskripsi,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
