import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cemas/core/services/auth_service.dart';
import 'package:cemas/core/theme/app_theme.dart';
import 'package:cemas/features/umkm/services/seller_service.dart';
import 'package:cemas/features/umkm/pages/registration/daftar_umkm_main.dart';
import 'package:cemas/features/umkm/pages/dashboard_toko_page.dart';
import 'package:cemas/features/umkm/pages/edit_shop_profile_page.dart'; // Import
import 'package:cemas/shared/pages/profile_page.dart';
import 'package:cemas/shared/pages/tentang_kami.dart';
import 'package:cemas/shared/pages/login_page.dart';
import 'package:cemas/shared/pages/layanan_aduan_page.dart';
import 'package:cemas/shared/register_page.dart';

class AkunPage extends StatelessWidget {

  final VoidCallback? onBackToHome;

  const AkunPage({super.key, this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final SellerService sellerService = SellerService();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.backgroundWhite,
        title: const Text('Akun'),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (onBackToHome != null) {
              onBackToHome!(); // Switch tab if callback provided
            } else {
               // Only pop if we can, otherwise do nothing or go home
               if (Navigator.canPop(context)) {
                 Navigator.pop(context);
               } 
            }
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          children: [
            // ---- HEADER PROFILE ----
            StreamBuilder<DocumentSnapshot?>(
              stream: FirebaseAuth.instance.currentUser != null 
                  ? FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots()
                  : null,
              builder: (context, snapshot) {
                String nama = "Memuat...";
                String email = "";

                if (snapshot.hasData && snapshot.data != null) {
                  final doc = snapshot.data!;
                  if (doc.exists && doc.data() != null) {
                    final data = doc.data() as Map<String, dynamic>;
                    final f = (data['namaPertama'] as String?) ?? "";
                    final l = (data['namaTerakhir'] as String?) ?? "";
                    nama = (f + (l.isNotEmpty ? ' $l' : '')).trim();
                    email = (data['email'] as String?) ?? "";
                  } else {
                     nama = "Pengguna";
                  }
                } else if (snapshot.connectionState == ConnectionState.active && snapshot.data == null) {
                   nama = "Belum Login";
                }

                return Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.primaryBlue,
                      child: const Icon(Icons.person, size: 50, color: AppTheme.backgroundWhite),
                    ),
                    const SizedBox(height: AppTheme.spaceSM),
                    Text(
                      nama,
                      style: AppTheme.h2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(email, style: AppTheme.bodySmall),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            // ---- LOGIC TOMBOL TOKO ----
            StreamBuilder<DocumentSnapshot?>(
              stream: sellerService.getMyStoreStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                bool hasStore = false;
                if (snapshot.hasData && snapshot.data != null) {
                  hasStore = snapshot.data!.exists;
                }

                // Check arguments
                final args = ModalRoute.of(context)?.settings.arguments;
                final bool isFromStore = (args is Map && args['isFromStore'] == true);

                if (isFromStore) {
                  // --- MODE PENGATURAN TOKO (Saat di dalam Dashboard) ---
                  return Column(
                    children: [
                      _menuTile(
                        icon: Icons.home,
                        title: "Kembali ke Beranda Pembeli",
                        iconColor: AppTheme.primaryBlue,
                        onTap: () {
                          // Pop until we hit the root (MainPage) which shows Buyer Home
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          if (onBackToHome != null) onBackToHome!(); // Ensure Tab 0 is selected
                        },
                      ),
                      const SizedBox(height: AppTheme.spaceMD),
                      _menuTile(
                        icon: Icons.edit_note,
                        title: "Kelola Data Toko",
                        iconColor: AppTheme.primaryBlue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditShopProfilePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }

                // --- MODE AKUN BIASA (Tab Akun) ---
                if (hasStore) {
                  return _menuTile(
                    icon: Icons.store,
                    title: "Masuk Toko Saya",
                    iconColor: AppTheme.primaryBlue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardTokoPage(),
                        ),
                      );
                    },
                  );
                } else {
                  return _menuTile(
                    icon: Icons.add_business,
                    title: "Daftar Gratis sebagai UMKM",
                    iconColor: AppTheme.secondaryGreen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DaftarUmkmMainPage(showBackButton: true),
                        ),
                      );
                    },
                  );
                }
              },
            ),

            const SizedBox(height: AppTheme.spaceMD),

            _menuTile(
              icon: Icons.person_outline,
              title: "Edit Profil",
              onTap: () {
                Navigator.pushNamed(context, "/profilePage");
              },
            ),

            const SizedBox(height: AppTheme.spaceMD),

            _menuTile(
              icon: Icons.info_outline,
              title: "Tentang Kami",
              onTap: () {
                Navigator.pushNamed(context, "/tentangKami");
              },
            ),

            const SizedBox(height: AppTheme.spaceMD),

             _menuTile(
              icon: Icons.support_agent,
              title: "Layanan Aduan",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LayananAduanPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: AppTheme.spaceMD),

            _menuTile(
              icon: Icons.logout,
              title: "Keluar",
              titleColor: AppTheme.secondaryRed,
              iconColor: AppTheme.secondaryRed,
              onTap: () async {
                bool confirm = await showDialog(
                  context: context, 
                  builder: (ctx) => AlertDialog(
                    title: const Text("Konfirmasi"),
                    content: const Text("Yakin ingin keluar?"),
                    actions: [
                      TextButton(child: const Text("Batal"), onPressed: () => Navigator.pop(ctx, false)),
                      TextButton(
                        child: const Text("Keluar", style: TextStyle(color: AppTheme.secondaryRed)), 
                        onPressed: () => Navigator.pop(ctx, true)
                      ),
                    ],
                  )
                ) ?? false;

                if (confirm) {
                  await authService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => LoginPage(
                          onSwitchToRegister: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      (route) => false,
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 30),
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
      decoration: AppTheme.cardDecoration(),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppTheme.primaryBlue),
        title: Text(
          title,
          style: AppTheme.labelBold.copyWith(
            fontSize: 16,
            color: titleColor ?? AppTheme.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: AppTheme.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
