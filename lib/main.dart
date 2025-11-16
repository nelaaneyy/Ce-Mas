import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File ini dibuat otomatis oleh flutterfire
import 'auth_wrapper.dart'; // Penjaga status login kita


void main() async {
  // 1. Pastikan Flutter siap sebelum menjalankan Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inisialisasi Firebase
  // Dia akan membaca 'kunci' dari firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
      
      // --- INI BAGIAN PENTING ---
      home: const AuthWrapper(), 
      
      debugShowCheckedModeBanner: false,
    );
  }
}