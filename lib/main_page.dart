import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// --- IMPORT HALAMAN PEMBELI ---
import 'beranda_page.dart';
import 'umkm_page.dart';

// --- IMPORT HALAMAN PENJUAL (UMKM) ---
import 'dashboard_toko_page.dart';
import 'kelola_toko_page.dart';

// --- IMPORT HALAMAN UMUM ---
import 'notifikasi_page.dart';
import 'akun_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  // Kita simpan Stream di variabel agar tidak dibuat ulang setiap kali set state
  late Stream<DocumentSnapshot> _userRoleStream;

  @override
  void initState() {
    super.initState();
    // Inisialisasi stream di sini supaya lebih stabil
    _userRoleStream = FirebaseFirestore.instance.collection('users').doc(_uid).snapshots();
  }

  // Fungsi untuk pindah tab
  void _jumpToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userRoleStream,
      builder: (context, snapshot) {
        
        // 1. Loading State (Hanya muncul saat awal aplikasi dibuka)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Cek Role User
        String role = 'pembeli';
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          role = data['role'] ?? 'pembeli';
        }

        // 3. Tentukan Halaman & Menu
        List<Widget> currentPages;
        List<BottomNavigationBarItem> currentNavItems;

        if (role == 'penjual') {
          // === MENU PENJUAL ===
          currentPages = [
            const DashboardTokoPage(),
            const KelolaTokoPage(),
            const NotifikasiPage(),
            const AkunPage(),
          ];

          currentNavItems = const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Produk'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Notifikasi'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Akun'),
          ];
        } else {
          // === MENU PEMBELI ===
          currentPages = [
            BerandaPage(onTabJump: _jumpToTab),
            const UmkmPage(),
            const NotifikasiPage(),
            const AkunPage(),
          ];

          currentNavItems = const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'UMKM'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Notifikasi'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Akun'),
          ];
        }

        // Safety check index
        if (_selectedIndex >= currentPages.length) {
          _selectedIndex = 0;
        }

        return Scaffold(
          // --- PERUBAHAN UTAMA DI SINI ---
          // Gunakan IndexedStack agar halaman tidak di-refresh saat pindah tab
          body: IndexedStack(
            index: _selectedIndex,
            children: currentPages,
          ),
          
          bottomNavigationBar: BottomNavigationBar(
            items: currentNavItems,
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue.shade800,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
          ),
        );
      },
    );
  }
}