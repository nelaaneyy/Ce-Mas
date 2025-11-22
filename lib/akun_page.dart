import 'package:cemas/umkm_features/daftar_umkm_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'seller_service.dart';

class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final SellerService sellerService = SellerService();

    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text('Akun', style: TextStyle(color: Colors.white)),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),

      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---- HEADER PROFILE ----
            FutureBuilder<DocumentSnapshot?>(
              future: authService.getCurrentUserData(),
              builder: (context, snapshot) {
                String nama = "Memuat...";
                String email = "";
                
                if (snapshot.hasData && snapshot.data != null) {
                  var data = snapshot.data!;
                  nama = "${data['namaPertama']} ${data['namaTerakhir']}";
                  email = data['email'];
                }

                return Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      nama,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      email,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
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

                if (hasStore) {
                  // JIKA SUDAH PUNYA TOKO
                  return _menuTile(
                    icon: Icons.store,
                    title: "Kelola Toko Saya",
                    iconColor: Colors.blue.shade800,
                    onTap: () {
                      // TODO: Arahkan ke Dashboard Toko
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Masuk ke Dashboard Toko...")),
                      );
                    },
                  );
                } else {
                  // JIKA BELUM PUNYA TOKO
                  return _menuTile(
                    icon: Icons.add_business,
                    title: "Daftar Gratis sebagai UMKM",
                    iconColor: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DaftarUmkmMainPage()),
                      );
                    },
                  );
                }
              },
            ),

            const SizedBox(height: 12),

            // ---- CARD PROFILE / EDIT ----
            _menuTile(
              icon: Icons.person_outline,
              title: "Edit Profil",
              onTap: () {
                Navigator.pushNamed(context,"/profilePage");
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
                await authService.signOut();
                Navigator.pushNamed(context, "/loginPage");
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---- WIDGET HELPER ----
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
            color: Colors.grey.shade200, 
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
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}