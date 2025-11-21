import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File ini dibuat otomatis oleh flutterfire
import 'auth_wrapper.dart'; // Penjaga status login kita
import 'profile_page.dart';
import 'tentang_kami.dart';
import 'login_page.dart';

void main() async {
  // 1. Pastikan Flutter siap sebelum menjalankan Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase
  // Dia akan membaca 'kunci' dari firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Jalankan aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi UMKM',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Kamu bisa ganti temanya nanti
      ),
      routes: {
        "/profilePage": (context) => const ProfilePage(),
        "/tentangKami": (context) => const TentangKamiPage(),
        "/login": (context) => const LoginPage(),
      },

      // --- INI BAGIAN PENTING ---
      home: const AuthWrapper(),

      debugShowCheckedModeBanner: false,
    );
  }
}
