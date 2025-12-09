import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String role; // 'pembeli', 'penjual', 'admin'
  final String namaPertama;
  final String namaTerakhir;
  final String nomorHp;
  final String username;
  final DateTime? createdAt;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.namaPertama = '',
    this.namaTerakhir = '',
    this.nomorHp = '',
    this.username = '',
    this.createdAt,
    this.photoUrl,
  });

  // Getter helper
  bool get isSeller => role == 'penjual' || role == 'umkm';
  bool get isAdmin => role == 'admin';
  String get fullName => '$namaPertama $namaTerakhir'.trim();

  // Factory untuk membuat UserModel dari DocumentSnapshot Firestore
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      role: data['role'] ?? 'pembeli',
      namaPertama: data['namaPertama'] ?? '',
      namaTerakhir: data['namaTerakhir'] ?? '',
      nomorHp: data['nomorHp'] ?? '',
      username: data['username'] ?? '',
      photoUrl: data['photoUrl'] ?? data['foto'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Konversi ke Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'namaPertama': namaPertama,
      'namaTerakhir': namaTerakhir,
      'nomorHp': nomorHp,
      'username': username,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
    };
  }
}
