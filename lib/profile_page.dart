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
  Map<String, dynamic>? userData;

  bool loading = true;
  bool uploadingImage = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();

    setState(() {
      userData = doc.data();
      loading = false;
    });
  }

  // =============================
  // UPLOAD FOTO PROFIL
  // =============================
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() => uploadingImage = true);

    final uid = auth.currentUser!.uid;
    final storageRef = FirebaseStorage.instance.ref().child("profile_images/$uid.jpg");

    await storageRef.putFile(File(picked.path));
    final imageUrl = await storageRef.getDownloadURL();

    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "foto": imageUrl,
    });

    setState(() {
      uploadingImage = false;
      userData!["foto"] = imageUrl;
    });
  }

  // =============================
  // EDIT FIELD
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
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final uid = auth.currentUser!.uid;
              final newValue = controller.text.trim();

              // UPDATE di Firestore
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(uid)
                  .update({
                field: newValue,
              });

              // UPDATE UI
              setState(() {
                userData![field] = newValue;
              });

              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          )
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text('Profile'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: userData?['foto'] != null
                      ? NetworkImage(userData!['foto'])
                      : null,
                  child: userData?['foto'] == null
                      ? const Icon(Icons.person, size: 60)
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
                      icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      onPressed: uploadingImage ? null : pickImage,
                    ),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              "${userData?['namaPertama']} ${userData?['namaTerakhir']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          _profileTile(
            title: "Nama Depan",
            subtitle: userData?['namaPertama'] ?? "",
            onTap: () => editField("namaPertama", "Nama Depan", userData?['namaPertama'] ?? ""),
          ),

          _profileTile(
            title: "Nama Belakang",
            subtitle: userData?['namaTerakhir'] ?? "",
            onTap: () => editField("namaTerakhir", "Nama Belakang", userData?['namaTerakhir'] ?? ""),
          ),

          _profileTile(
            title: "Email",
            subtitle: userData?['email'] ?? "",
            onTap: () => editField("email", "Email", userData?['email'] ?? ""),
          ),

          _profileTile(
            title: "Nomor HP",
            subtitle: userData?['nomorHp'] ?? "",
            onTap: () => editField("nomorHp", "Nomor HP", userData?['nomorHp'] ?? ""),
          ),

          if (uploadingImage)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Center(child: CircularProgressIndicator()),
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
