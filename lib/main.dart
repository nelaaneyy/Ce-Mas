import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/firebase_options.dart';
import 'core/widgets/auth_wrapper.dart';
import 'shared/pages/profile_page.dart';
import 'shared/pages/tentang_kami.dart';
import 'shared/pages/login_page.dart';
import 'shared/pages/notifikasi_page.dart';
import 'shared/pages/akun_page.dart';
import 'features/user/pages/nilai_umkm_page.dart';
import 'features/user/pages/umkm_page.dart';

void main() async {
  // 1. Pastikan Flutter siap sebelum menjalankan Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase
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
        primarySwatch: Colors.blue,
      ),
      routes: {
        "/profilePage": (context) => const ProfilePage(),
        "/tentangKami": (context) => const TentangKamiPage(),
        "/login": (context) => const LoginPage(),
        "/notifikasiPage": (context) => const NotifikasiPage(),
        "/akunPage": (context) => const AkunPage(),
        "/nilai_umkm": (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final String nama = (args is String) ? args : "UMKM";
          return NilaiUmkmPage(umkmNama: nama);
        },
        "/lihat_umkm": (context) => const UmkmPage(),
      },

      home: const AuthWrapper(),

      debugShowCheckedModeBanner: false,
    );
  }
}
