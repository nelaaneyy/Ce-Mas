// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan User ID yang sedang login
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // --- FUNGSI SIGN UP (DAFTAR) ---
  Future<UserCredential?> signUpWithEmailPassword(
    String email,
    String password,
    String namaPertama,
    String namaTerakhir,
    String nomorHp,
  ) async {
    try {
      // 1. Buat user di Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Simpan data tambahan ke Firestore
      // Kita gunakan UID dari Auth sebagai ID dokumen di Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'namaPertama': namaPertama,
        'namaTerakhir': namaTerakhir,
        'nomorHp': nomorHp,
        'role': 'pembeli', // Default role adalah pembeli
        'createdAt': Timestamp.now(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Menampilkan pesan error yang lebih rapi
      print('Error: ${e.message}');
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // --- FUNGSI SIGN IN (LOGIN) ---
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      return null;
    }
  }

  // --- FUNGSI SIGN OUT (LOGOUT) ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- STREAM STATUS AUTH ---
  // (Ini untuk "AuthWrapper" yang akan kita bahas nanti)
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}