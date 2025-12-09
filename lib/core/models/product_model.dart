import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String sellerId;
  final String namaProduk;
  final String deskripsi;
  final double harga;
  final String kategori; // 'Makanan', 'Minuman', 'Jasa', dll
  final String? fotoProduk;
  final DateTime? createdAt;
  final double rating;
  final int terjual;

  ProductModel({
    this.id = '',
    required this.sellerId,
    required this.namaProduk,
    required this.deskripsi,
    required this.harga,
    required this.kategori,
    this.fotoProduk,
    this.createdAt,
    this.rating = 0.0,
    this.terjual = 0,
  });

  factory ProductModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductModel(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      namaProduk: data['namaProduk'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      harga: (data['harga'] as num?)?.toDouble() ?? 0.0,
      kategori: data['kategori'] ?? 'Umum',
      fotoProduk: data['fotoProduk'] ?? data['foto'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      terjual: (data['terjual'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'namaProduk': namaProduk,
      'deskripsi': deskripsi,
      'harga': harga,
      'kategori': kategori,
      'fotoProduk': fotoProduk,
      'createdAt': createdAt,
      'rating': rating,
      'terjual': terjual,
    };
  }
}
