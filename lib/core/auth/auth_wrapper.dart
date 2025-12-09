import 'package:cemas/core/services/auth_service.dart';
import 'package:cemas/features/admin/home_screen.dart';
import 'package:cemas/shared/pages/login_page.dart'; // Premium Login
import 'package:cemas/shared/register_page.dart'; // Legacy Register
import 'package:cemas/features/user/pages/beranda_page.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: AuthService().authStateChanges,
      // initialData: null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          if (user.role == 'admin') {
            return const AdminHomeScreen();
          } else {
            return BerandaPage(onTabJump: (_) {});
          }
        }

        // Use Premium Login Page but preserve Legacy Register Flow
        return LoginPage(
          onSwitchToRegister: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            );
          },
        );
      },
    );
  }
}
