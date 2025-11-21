import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text('Akun'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---- CARD PROFILE ----
            _menuTile(
              icon: Icons.person_outline,
              title: "Profile",
              onTap: () {
                Navigator.pushNamed(context, "/profilePage");
              },
            ),

            const SizedBox(height: 12),

            // ---- CARD TENTANG KAMI ----
            _menuTile(
              icon: Icons.info_outline,
              title: "Tentang Kami",
              onTap: () {
                Navigator.pushNamed(context, "/tentangKami");
              },
            ),

            const SizedBox(height: 12),

            // ---- CARD LOGOUT ----
            _menuTile(
              icon: Icons.logout,
              title: "Logout",
              titleColor: Colors.red,
              iconColor: Colors.red,
              onTap: () async {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, "/login");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.blue.shade800),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: titleColor ?? Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}
