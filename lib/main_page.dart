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
  int _selectedIndex = 0; // Melacak tab mana yang sedang aktif

  // Daftar halaman/widget yang akan ditampilkan
  static const List<Widget> _pages = <Widget>[
    BerandaPage(),
    UmkmPage(),
    NotifikasiPage(),
    AkunPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update state saat tab diklik
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan berubah sesuai tab yang dipilih
      body: _pages[_selectedIndex], 
      
      // Navigasi Bawah
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'UMKM',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
        currentIndex: _selectedIndex, // Tandai tab yang aktif
        selectedItemColor: Colors.blue[800], // Warna tab aktif
        unselectedItemColor: Colors.grey, // Warna tab tidak aktif
        onTap: _onItemTapped, // Panggil fungsi saat diklik
        type: BottomNavigationBarType.fixed, // Pastikan 4 labelnya muncul
      ),
    );
  }
}