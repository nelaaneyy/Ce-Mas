import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cemas/core/theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final auth = FirebaseAuth.instance;
  bool uploadingImage = false;

  // =============================
  // UPLOAD FOTO (LANGSUNG BERUBAH DI FIRESTORE)
  // =============================
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() => uploadingImage = true);

    try {
      final uid = auth.currentUser!.uid;
      final file = File(picked.path);

      // Cek file exists
      if (!await file.exists()) {
        throw Exception('File tidak ditemukan');
      }

      final storageRef = FirebaseStorage.instance.ref().child(
        "profile_images/$uid.jpg",
      );

      // Upload dengan error handling lebih baik
      final task = storageRef.putFile(file);
      await task;

      final imageUrl = await storageRef.getDownloadURL();

      // UPDATE DATABASE
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "foto": imageUrl,
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() => uploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diubah'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Gagal upload: $e");
      if (mounted) {
         setState(() => uploadingImage = false);
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload foto: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // =============================
  // EDIT FIELD (LANGSUNG BERUBAH DI FIRESTORE)
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
                  try {
                    // UPDATE DATABASE
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(auth.currentUser!.uid)
                        .set({field: newValue}, SetOptions(merge: true));

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data berhasil disimpan'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
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
    final user = auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not found")));
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.backgroundWhite,
        title: const Text('Profile'),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("users").doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> userData = {};
          
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
             userData = snapshot.data!.data() as Map<String, dynamic>;
          } 

          // Fallback / Defaults logic (tapi tidak save otomatis disini untuk hindari infinite loop build)
          // Kita hanya display fallback values.
          String fName = userData['namaPertama'] ?? "";
          String lName = userData['namaTerakhir'] ?? "";
          String email = userData['email'] ?? user.email ?? "";
          String phone = userData['nomorHp'] ?? "";
          String foto = userData['foto'] ?? user.photoURL ?? "";

          // Auto-parse name if empty in DB but exists in Auth (Display only)
          if (fName.isEmpty && user.displayName != null && user.displayName!.isNotEmpty) {
             List<String> namaSplit = user.displayName!.split(" ");
             if (namaSplit.isNotEmpty) fName = namaSplit.first;
             if (namaSplit.length > 1) lName = namaSplit.sublist(1).join(" ");
          }

          return ListView(
            padding: const EdgeInsets.all(AppTheme.spaceLG),
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

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: AppTheme.primaryBlue,
                        radius: 18,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: AppTheme.backgroundWhite,
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

              const SizedBox(height: AppTheme.spaceMD),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Text(
                    "$fName $lName",
                    style: AppTheme.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spaceXL),

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
          );
        },
      ),
    );
  }

  Widget _profileTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMD),
      decoration: AppTheme.cardDecoration(),
      child: ListTile(
        title: Text(
          title,
          style: AppTheme.labelBold,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.edit),
        onTap: onTap,
      ),
    );
  }
}
