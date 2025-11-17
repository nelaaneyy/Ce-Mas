import 'package:flutter/material.dart';
import 'beranda_page.dart';
import 'umkm_page.dart';
import 'notifikasi_page.dart';
import 'akun_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late List<Widget> _pages; // Kita ubah dari 'static const'

  @override
  void initState() {
    super.initState();
    // Kita inisialisasi _pages di sini agar bisa mengirim fungsi
    _pages = <Widget>[
      BerandaPage(onTabJump: _jumpToTab), // Kirim fungsi ke Beranda
      UmkmPage(),
      NotifikasiPage(),
      AkunPage(),
    ];
  }

  // Fungsi untuk pindah tab, dipanggil dari BerandaPage
  void _jumpToTab(int index) {
    _onItemTapped(index);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            label: 'UMKM',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Akun',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}