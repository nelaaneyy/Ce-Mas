import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
    String? fotoKtpUrl,
    String? fotoUmkmUrl,
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
      'foto': fotoTokoUrl ?? '', // Foto toko utama
      'fotoToko': fotoTokoUrl ?? '', // Kompatibilitas dengan DetailTokoPage
      'fotoKtp': fotoKtpUrl ?? '', // Foto KTP pemilik
      'fotoUmkm': fotoUmkmUrl ?? '', // Foto UMKM
      'createdAt': FieldValue.serverTimestamp(),
      'rating': 0.0,
      'jumlahUlasan': 0,
    });

    await _firestore.collection('users').doc(user.uid).update({
      'role': 'penjual',
    });
  }

  // --- 3. AMBIL PRODUK SAYA (READ) ---
  Stream<QuerySnapshot> getMyProducts() {
    User? user = _auth.currentUser;
    if (user == null) {
      debugPrint("ERROR: No user logged in for getMyProducts!");
      return const Stream.empty();
    }

    debugPrint("Getting products for user: ${user.uid}");

    // Ambil produk HANYA yang sellerId-nya = UID saya
    // NOTE: orderBy dihapus sementara karena butuh composite index di Firestore
    // Untuk menambahkan orderBy kembali, buat index di Firestore Console:
    // Collection: products, Fields: sellerId (Ascending), createdAt (Descending)
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: user.uid)
        // .orderBy('createdAt', descending: true) // Commented out - needs index
        .snapshots();
  }

  // --- 4. TAMBAH PRODUK BARU ---
  Future<void> addProduct({
    required String namaProduk,
    required String deskripsi,
    required double harga,
    required String kategori,
    String? fotoProdukUrl,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) {
      debugPrint("ERROR: No user logged in!");
      return;
    }

    debugPrint("Adding product for user: ${user.uid}");
    debugPrint("Product name: $namaProduk, Price: $harga");

    await _firestore.collection('products').add({
      'sellerId': user.uid,
      'namaProduk': namaProduk,
      'deskripsi': deskripsi,
      'harga': harga,
      'kategori': kategori,
      'fotoProduk': fotoProdukUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    debugPrint("Product added successfully!");
  }

  // --- 5. HAPUS PRODUK ---
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // --- 6. UPDATE PRODUK ---
  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('products').doc(productId).update(data);
  }
}
