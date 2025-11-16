import 'package:flutter/material.dart';
import 'login_page.dart';  // Ini akan error jika login_page belum ada
import 'signup_page.dart'; // Ini akan error jika signup_page belum ada

class AuthTogglePage extends StatefulWidget {
  const AuthTogglePage({super.key});

  @override
  State<AuthTogglePage> createState() => _AuthTogglePageState();
}

class _AuthTogglePageState extends State<AuthTogglePage> {
  // Secara default, kita tampilkan halaman login
  bool _showLoginPage = true;

  // Fungsi untuk ganti halaman
  void _toggleView() {
    setState(() {
      _showLoginPage = !_showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showLoginPage) {
      // Tampilkan LoginPage dan berikan fungsi _toggleView
      return LoginPage(onSwitchToRegister: _toggleView);
    } else {
      // Tampilkan SignUpPage dan berikan fungsi _toggleView
      return SignUpPage(onSwitchToLogin: _toggleView);
    }
  }
}