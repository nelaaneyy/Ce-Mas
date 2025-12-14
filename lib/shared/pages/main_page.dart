import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// User pages
import 'package:cemas/features/user/pages/beranda_page.dart';
import 'package:cemas/features/user/pages/umkm_page.dart';

// UMKM pages
import 'package:cemas/features/umkm/pages/dashboard_toko_page.dart';
import 'package:cemas/features/umkm/pages/kelola_toko_page.dart';

// Shared pages
import 'package:cemas/shared/pages/notifikasi_page.dart';
import 'package:cemas/shared/pages/akun_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  late Stream<DocumentSnapshot> _userRoleStream;

  @override
  void initState() {
    super.initState();
    _userRoleStream = FirebaseFirestore.instance.collection('users').doc(_uid).snapshots();
  }

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
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Always show Buyer Tabs by default
        List<Widget> currentPages = [
          BerandaPage(onTabJump: _jumpToTab),
          const UmkmPage(),
          const NotifikasiPage(),
          AkunPage(onBackToHome: () => _jumpToTab(0)),
        ];

        List<BottomNavigationBarItem> currentNavItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'UMKM'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Akun'),
        ];
        if (_selectedIndex >= currentPages.length) {
          _selectedIndex = 0;
        }

        return Scaffold(
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