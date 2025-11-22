import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- 1. CEK STATUS TOKO ---
  // Mengecek apakah user yang login sudah punya toko?
  Stream<DocumentSnapshot?> getMyStoreStream() {
    User? user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    // Kita cari dokumen di koleksi 'sellers' yang ID-nya sama dengan UID user
    return _firestore.collection('sellers').doc(user.uid).snapshots();
  }

  // --- 2. BUAT TOKO BARU (DAFTAR UMKM) ---
  Future<void> createStore({
    required String namaToko,
    required String deskripsi,
    required String noWhatsapp,
    required String alamat,
    required String kategori,
    String? fotoTokoUrl,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Pastikan format WA benar (ganti 0 di depan jadi 62)
    String formattedWA = noWhatsapp.trim();
    if (formattedWA.startsWith('0')) {
      formattedWA = '62${formattedWA.substring(1)}';
    }

    // Simpan data toko menggunakan UID user sebagai ID Toko
    await _firestore.collection('sellers').doc(user.uid).set({
      'sellerId': user.uid,
      'namaToko': namaToko,
      'deskripsi': deskripsi,
      'noWhatsapp': formattedWA,
      'alamat': alamat,
      'kategori': kategori, // Penting untuk filter
      'fotoToko': fotoTokoUrl ?? '', // Kosongkan jika tidak ada
      'createdAt': FieldValue.serverTimestamp(),
      'rating': 0.0, 
      'jumlahUlasan': 0,
    });
  }

  // --- 3. AMBIL PRODUK SAYA (READ) ---
  Stream<QuerySnapshot> getMyProducts() {
    User? user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    // Ambil produk HANYA yang sellerId-nya = UID saya
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // --- 4. TAMBAH PRODUK BARU ---
  Future<void> addProduct({
    required String namaProduk,
    required String deskripsi,
    required double harga, // Perhatikan tipe data double/int
    required String kategori,
    String? fotoProdukUrl,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('products').add({
      'sellerId': user.uid,
      'namaProduk': namaProduk,
      'deskripsi': deskripsi,
      'harga': harga,
      'kategori': kategori,
      'fotoProduk': fotoProdukUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- 5. HAPUS PRODUK ---
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }
}