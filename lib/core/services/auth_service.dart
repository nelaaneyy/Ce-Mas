// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

class UserModel {
  final String uid;
  final String email;
  final String role;

  UserModel({required this.uid, required this.email, required this.role});
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

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

  // --- STREAM STATUS AUTH WITH ROLE ---
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) return null;

      try {
        print("AuthService: Checking role for ${user.uid} (${user.email})"); // DEBUG

        // 1. Cek User Biasa / UMKM
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          print("AuthService: Found in 'users'. Role: ${data['role']}"); // DEBUG
          return UserModel(
            uid: user.uid, 
            email: user.email ?? '', 
            role: data['role'] ?? 'pembeli'
          );
        }

        // 2. Cek Admin (jika tidak ada di users)
        DocumentSnapshot adminDoc = await _firestore.collection('admins').doc(user.uid).get();
        if (adminDoc.exists) {
           print("AuthService: Found in 'admins'. Assigning role 'admin'."); // DEBUG
           return UserModel(
            uid: user.uid, 
            email: user.email ?? '', 
            role: 'admin' // Force role admin
          );
        }

        print("AuthService: User not found in DB. Defaulting to 'pembeli'."); // DEBUG
        // 3. Default (Baru daftar / belum ada data)
        return UserModel(uid: user.uid, email: user.email ?? '', role: 'pembeli');
        
      } catch (e) {
        print("Error fetching user role: $e");
        return null;
      }
    });
  }

  // --- FUNGSI SIGN UP (DAFTAR) ---
  // Catatan: Tidak ada try-catch di sini agar error diteruskan ke UI
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
    String namaPertama,
    {
      String role = 'pembeli',
      String? namaTerakhir,
      String? username,
      String? nomorHp,
    } 
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
        'namaTerakhir': namaTerakhir ?? '',
        'nomorHp': nomorHp ?? '',
        'username': username ?? '',
        'role': role,
        'createdAt': Timestamp.now(),
      });
      
      // Log Activity automatically (New Feature)
      try {
        // We import AdminService dynamically or just use firestore directly here to avoid circular dependencies if AdminService depends on AuthService?
        // Actually, AdminService depends on nothing complex, but let's check. 
        // AdminService is fine.
        await _firestore.collection('activities').add({
            'text': 'Pendaftaran Akun Baru (${role == 'umkm' ? 'Penjual' : 'Pembeli'}): $email',
            'type': 'info',
            'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print("Log activity failed: $e");
      }
      
      // If role is umkm or penjual, also create entry in sellers if needed, 
      // but usually registration form handles that.
    }

    return userCredential;
  }
  
  // Wrapper for simple signUp from RegisterPage which might only send limited data
  Future<void> signUp({required String email, required String password, required String role}) async {
      await signUpWithEmailPassword(email, password, 'User', role: role);
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
  
  // Wrapper for Login Page
  Future<void> signIn({required String email, required String password}) async {
      await signInWithEmailPassword(email, password);
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
      
      // Check if user exists in Firestore, if not create default
      if (userCredential.user != null) {
          final doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
          if (!doc.exists) {
               await _firestore.collection('users').doc(userCredential.user!.uid).set({
                'uid': userCredential.user!.uid,
                'email': userCredential.user!.email,
                'namaPertama': userCredential.user!.displayName ?? 'User',
                'role': 'pembeli',
                'createdAt': Timestamp.now(),
              });
          }
      }
      
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
