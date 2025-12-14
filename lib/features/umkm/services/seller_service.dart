import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

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
    // New fields
    String? nik,
    String? namaPemilik,
    String? instagram,
    String? facebook,
    String? tiktok,
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
      'foto': fotoTokoUrl ?? fotoUmkmUrl ?? '', // Foto toko utama (Logo/Banner) - Fallback to UMKM photo
      'fotoToko': fotoTokoUrl ?? fotoUmkmUrl ?? '', // Kompatibilitas dengan DetailTokoPage - Fallback to UMKM photo
      'fotoKtp': fotoKtpUrl ?? '', // Foto KTP pemilik
      'fotoUmkm': fotoUmkmUrl ?? '', // Foto UMKM
      
      // New Fields Saved
      'nik': nik ?? '',
      'namaPemilik': namaPemilik ?? '',
      'instagram': instagram ?? '',
      'facebook': facebook ?? '',
      'tiktok': tiktok ?? '',

      'createdAt': FieldValue.serverTimestamp(),
      'rating': 0.0,
      'jumlahUlasan': 0,
      'status': 'Menunggu', // Default status for verification
    });

    await _firestore.collection('users').doc(user.uid).update({
      'role': 'penjual',
    });
    
    // Log Activity (New Feature)
    try {
       await _firestore.collection('activities').add({
         'text': 'Pendaftaran UMKM Baru: $namaToko',
         'type': 'warning', // Warning because needs verification
         'timestamp': FieldValue.serverTimestamp(),
       });
    } catch (e) {
      debugPrint("Log activity failed: $e");
    }
  }

  // --- 2b. UPDATE DATA TOKO ---
  Future<void> updateStoreProfile({
    required String namaToko,
    required String deskripsi,
    required String noWhatsapp,
    required String alamat,
    String? fotoToko, // Added parameter
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Format WA
    String formattedWA = noWhatsapp.trim();
    if (formattedWA.startsWith('0')) {
      formattedWA = '62${formattedWA.substring(1)}';
    }

    final Map<String, dynamic> data = {
      'namaToko': namaToko,
      'deskripsi': deskripsi,
      'noWhatsapp': formattedWA,
      'alamat': alamat,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (fotoToko != null) {
      data['fotoToko'] = fotoToko;
      // Update legacy fields to keep in sync
      data['foto'] = fotoToko; 
      data['fotoUmkm'] = fotoToko;
    }

    await _firestore.collection('sellers').doc(user.uid).update(data);
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
  // --- 7. DASHBOARD STATS STREAM (REAL-TIME) ---
  Stream<Map<String, dynamic>> getStoreStatsStream() {
    User? user = _auth.currentUser;
    if (user == null) {
      return Stream.value({'products': 0, 'rating': 0.0, 'chat': 0, 'views': 0});
    }

    late StreamController<Map<String, dynamic>> controller;
    // ignore: cancel_subscriptions
    var subs = <dynamic>[];
    
    // Initial values
    int productCount = 0;
    double rating = 0.0;
    int chatCount = 0; // Placeholder until Chat feature is live
    int views = 0; // Placeholder

    void emitStats() {
      if (!controller.isClosed) {
        debugPrint("SellerStats: Emitting - Products: $productCount, Rating: $rating");
        controller.add({
          'products': productCount,
          'rating': rating,
          'chat': chatCount,
          'views': views,
        });
      }
    }

    controller = StreamController<Map<String, dynamic>>(
      onListen: () {
        debugPrint("SellerStats: Stream Listen Started for ${user.uid}");
        
        // 1. Listen to Product Count
        subs.add(_firestore.collection('products').where('sellerId', isEqualTo: user.uid).snapshots().listen((snapshot) {
          productCount = snapshot.docs.length;
          debugPrint("SellerStats: Products update. Count: $productCount");
          emitStats();
        }));

        // 2. Listen to Seller Info for Rating & Views
        subs.add(_firestore.collection('sellers').doc(user.uid).snapshots().listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data() as Map<String, dynamic>;
            rating = (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0;
            debugPrint("SellerStats: Seller info update. Rating: $rating");
            // views = data['views'] ?? 0;
            emitStats();
          }
        }));

        // Emission awal (penting agar tidak loading terus)
        emitStats();
      },
      onCancel: () {
         debugPrint("SellerStats: Stream Cancelled");
        for (var sub in subs) {
          sub.cancel();
        }
      },
    );

    return controller.stream;
  }
  // --- 8. INCREMENT UNIQUE STORE VIEW ---
  Future<void> incrementStoreView(String sellerId) async {
    User? user = _auth.currentUser;
    // Jika user belum login atau user adalah pemilik toko sendiri, tidak dihitung
    if (user == null || user.uid == sellerId) return;

    final sellerRef = _firestore.collection('sellers').doc(sellerId);
    final visitorRef = sellerRef.collection('visitors').doc(user.uid);

    try {
      final visitorDoc = await visitorRef.get();
      if (!visitorDoc.exists) {
        // Jika user belum pernah mengunjungi toko ini
        await _firestore.runTransaction((transaction) async {
          transaction.set(visitorRef, {
            'firstVisit': FieldValue.serverTimestamp(),
            'lastVisit': FieldValue.serverTimestamp(),
          });
          transaction.update(sellerRef, {
            'views': FieldValue.increment(1),
          });
        });
        debugPrint("View verification successful. Views incremented.");
      } else {
         // Opsional: Update lastVisit jika ingin tracking kapan terakhir berkunjung
         await visitorRef.update({'lastVisit': FieldValue.serverTimestamp()});
         debugPrint("User already viewed this store. Skipping increment.");
      }
    } catch (e) {
      debugPrint("Failed to increment store view: $e");
    }
  }
}
