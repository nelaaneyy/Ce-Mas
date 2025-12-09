import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String sellerId; // UID pemilik
  final String namaToko;
  final String deskripsi;
  final String noWhatsapp;
  final String alamat;
  final String kategori;
  final String? fotoToko;
  final String? fotoKtp;
  final String? fotoUmkm;
  final String status; // 'Menunggu', 'Terverifikasi', 'Ditolak'
  final double rating;
  final int jumlahUlasan;
  final DateTime? createdAt;

  StoreModel({
    required this.sellerId,
    required this.namaToko,
    required this.deskripsi,
    required this.noWhatsapp,
    required this.alamat,
    required this.kategori,
    this.fotoToko,
    this.fotoKtp,
    this.fotoUmkm,
    this.status = 'Menunggu',
    this.rating = 0.0,
    this.jumlahUlasan = 0,
    this.createdAt,
  });

  factory StoreModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StoreModel(
      sellerId: doc.id,
      namaToko: data['namaToko'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      noWhatsapp: data['noWhatsapp'] ?? '',
      alamat: data['alamat'] ?? '',
      kategori: data['kategori'] ?? 'Umum',
      fotoToko: data['fotoToko'] ?? data['foto'],
      fotoKtp: data['fotoKtp'],
      fotoUmkm: data['fotoUmkm'],
      status: data['status'] ?? 'Menunggu',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      jumlahUlasan: (data['jumlahUlasan'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'namaToko': namaToko,
      'deskripsi': deskripsi,
      'noWhatsapp': noWhatsapp,
      'alamat': alamat,
      'kategori': kategori,
      'fotoToko': fotoToko,
      'fotoKtp': fotoKtp,
      'fotoUmkm': fotoUmkm,
      'status': status,
      'rating': rating,
      'jumlahUlasan': jumlahUlasan,
      'createdAt': createdAt,
    };
  }
}
