import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_toggle_page.dart'; 
// import 'product_crud_page.dart'; // <-- Hapus atau komentari ini
import 'main_page.dart'; // <-- IMPORT HALAMAN BARU KITA

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Jika user sudah login
        if (snapshot.hasData) {
          // --- UBAH BARIS INI ---
          return const MainPage(); 
        }

        // Jika user belum login
        return const AuthTogglePage();
      },
    );
  }
}