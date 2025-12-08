// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- MENDAPATKAN USER ID SAAT INI ---
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Tambahkan fungsi ini agar dipanggil di UI
  User? getCurrentUser() {
    // <-- Mengembalikan objek User
    return _auth.currentUser;
  }

  // --- STREAM STATUS AUTH ---
  // Berguna untuk mengecek apakah user sedang login atau tidak secara realtime
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- FUNGSI SIGN UP (DAFTAR) ---
  // Catatan: Tidak ada try-catch di sini agar error diteruskan ke UI
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
    String namaPertama,
    String namaTerakhir,
    String username,
    String nomorHp,
  ) async {
    // 1. Buat user di Firebase Auth
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Simpan data tambahan ke Firestore
    // Menggunakan UID dari Auth sebagai ID dokumen
    if (userCredential.user != null) {
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'namaPertama': namaPertama,
        'namaTerakhir': namaTerakhir,
        'nomorHp': nomorHp,
        'username': username,
        'role': 'pembeli', // Default role
        'createdAt': Timestamp.now(),
      });
    }

    return userCredential;
  }

  // --- FUNGSI SIGN IN (LOGIN) ---
  // Catatan: Tidak ada try-catch di sini agar error (password salah, user not found) diteruskan ke UI
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  }

  // --- GOOGLE SIGN-IN (SOCIAL LOGIN) ---
  Future<UserCredential> signInWithGoogle() async {
    // Start the interactive sign in process
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      // The user canceled the sign-in
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    // Helpful debug logging (tokens redacted in logs)
    try {
      // Sanity check tokens
      if (idToken == null && accessToken == null) {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Missing Google ID token or access token.',
        );
      }

      // Build a credential
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      // Log that we're about to call Firebase using a Google credential
      // Do NOT print raw tokens in production; printing here helps diagnose invalid-credential.
      // We'll only log their presence (not full token contents)
      print(
        'AuthService.signInWithGoogle: idToken present=${idToken != null}, accessToken present=${accessToken != null}',
      );

      // Sign in to Firebase with the Google [UserCredential]
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      // Re-throw so UI can handle it and show messages
      rethrow;
    }
  }

  // --- FUNGSI SIGN OUT (LOGOUT) ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- FUNGSI AMBIL DATA USER DARI FIRESTORE ---
  Future<DocumentSnapshot?> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await _firestore.collection('users').doc(user.uid).get();
    }
    return null;
  }
}
