import 'package:flutter/material.dart';
import 'package:cemas/shared/pages/login_page.dart';
import 'package:cemas/shared/pages/signup_page.dart';

class AuthTogglePage extends StatefulWidget {
  const AuthTogglePage({super.key});

  @override
  State<AuthTogglePage> createState() => _AuthTogglePageState();
}

class _AuthTogglePageState extends State<AuthTogglePage> {
  bool _showLoginPage = true;

  void _toggleView() {
    setState(() {
      _showLoginPage = !_showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showLoginPage) {
      return LoginPage(onSwitchToRegister: _toggleView);
    } else {
      return SignUpPage(onSwitchToLogin: _toggleView);
    }
  }
}