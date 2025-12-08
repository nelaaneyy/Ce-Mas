import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cemas/core/widgets/auth_toggle_page.dart';
import 'package:cemas/shared/pages/main_page.dart';

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