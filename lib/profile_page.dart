import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final auth = FirebaseAuth.instance;

  // Inisialisasi agar tidak error null
  Map<String, dynamic> userData = {};

  bool loading = true;
  bool uploadingImage = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  // ==================================================
  // INI BAGIAN KUNCI (PERBAIKAN LOGIKA DATA)
  // ==================================================
  Future<void> loadUser() async {
    final user = auth.currentUser;
    if (user == null) return;

    try {
      // 1. Cek Database Firestore
      final docRef = FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null && doc.data()!.isNotEmpty) {
        // SKENARIO A: Data SUDAH ADA di Database.
        // LAKUKAN: Pakai data ini. JANGAN TIMPA dengan data Login.
        // Ini yang menjaga agar data profilmu tidak hilang saat login ulang.

        setState(() {
          userData = doc.data() as Map<String, dynamic>;
          loading = false;
        });
      } else {
        // SKENARIO B: Data KOSONG di Database (Pengguna Baru).
        // LAKUKAN: Ambil data dari Auth (Login) lalu simpan ke Database.

        String namaLengkap = user.displayName ?? "";
        String namaDepan = "";
        String namaBelakang = "";

        // Pecah nama jika ada spasi (Contoh: "Budi Santoso")
        if (namaLengkap.isNotEmpty) {
          List<String> split = namaLengkap.split(" ");
          namaDepan = split.first;
          namaBelakang = split.length > 1 ? split.sublist(1).join(" ") : "";
        }

        // Siapkan data awal
        Map<String, dynamic> initialData = {
          "namaPertama": namaDepan,
          "namaTerakhir": namaBelakang,
          "email": user.email ?? "",
          "nomorHp": "",
          "foto": user.photoURL ?? "",
        };

        // SIMPAN KE DATABASE (Agar besok-besok masuk ke Skenario A)
        await docRef.set(initialData, SetOptions(merge: true));

        setState(() {
          userData = initialData;
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => loading = false); // Stop loading jika error
    }
  }

  // =============================
  // UPLOAD FOTO (LANGSUNG BERUBAH)
  // =============================
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() => uploadingImage = true);

    try {
      final uid = auth.currentUser!.uid;
      final storageRef = FirebaseStorage.instance.ref().child(
        "profile_images/$uid.jpg",
      );

      await storageRef.putFile(File(picked.path));
      final imageUrl = await storageRef.getDownloadURL();

      // 1. UPDATE TAMPILAN DULU (Biar cepat)
      setState(() {
        userData["foto"] = imageUrl;
        uploadingImage = false;
      });

      // 2. UPDATE DATABASE DI BACKGROUND
      // Pakai merge: true agar nama & email TIDAK TERHAPUS
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "foto": imageUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Gagal upload: $e");
      setState(() => uploadingImage = false);
    }
  }

  // =============================
  // EDIT FIELD (LANGSUNG BERUBAH)
  // =============================
  void editField(String field, String label, String value) {
    final controller = TextEditingController(text: value);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Edit $label"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newValue = controller.text.trim();
                Navigator.pop(context); // Tutup dialog

                if (newValue.isNotEmpty) {
                  // 1. UPDATE TAMPILAN DULU (Optimistic Update)
                  setState(() {
                    userData[field] = newValue;
                  });

                  // 2. UPDATE DATABASE
                  // Pakai merge: true agar field lain aman
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(auth.currentUser!.uid)
                      .set({field: newValue}, SetOptions(merge: true));
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Ambil data dengan pengecekan null agar aman
    String fName = userData['namaPertama'] ?? "";
    String lName = userData['namaTerakhir'] ?? "";
    String email = userData['email'] ?? "";
    String phone = userData['nomorHp'] ?? "";
    String foto = userData['foto'] ?? "";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: (foto.isNotEmpty)
                      ? NetworkImage(foto)
                      : null,
                  child: (foto.isEmpty)
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),

                // Tombol edit foto
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue.shade800,
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                      onPressed: uploadingImage ? null : pickImage,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (uploadingImage)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Center(child: CircularProgressIndicator()),
            ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              "$fName $lName",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          _profileTile(
            title: "Nama Depan",
            subtitle: fName.isEmpty ? "-" : fName,
            onTap: () => editField("namaPertama", "Nama Depan", fName),
          ),

          _profileTile(
            title: "Nama Belakang",
            subtitle: lName.isEmpty ? "-" : lName,
            onTap: () => editField("namaTerakhir", "Nama Belakang", lName),
          ),

          _profileTile(
            title: "Email",
            subtitle: email.isEmpty ? "-" : email,
            onTap: () => editField("email", "Email", email),
          ),

          _profileTile(
            title: "Nomor HP",
            subtitle: phone.isEmpty ? "-" : phone,
            onTap: () => editField("nomorHp", "Nomor HP", phone),
          ),
        ],
      ),
    );
  }

  Widget _profileTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.edit),
        onTap: onTap,
      ),
    );
  }
}
