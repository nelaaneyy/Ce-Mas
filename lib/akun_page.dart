import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  final auth = FirebaseAuth.instance;
  Map<String, dynamic>? userData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    final user = auth.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    setState(() {
      userData = doc.data();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text('Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          // Header Profil
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.blue.shade800,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Text(
                  "${userData?['namaPertama']} ${userData?['namaTerakhir']}",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTile(
                  title: "Nama",
                  subtitle:
                      "${userData?['namaPertama']} ${userData?['namaTerakhir']}",
                ),
                _buildTile(
                  title: "Username",
                  subtitle: userData?['username'] ?? "",
                ),
                _buildTile(title: "Email", subtitle: userData?['email'] ?? ""),
                _buildTile(
                  title: "Nomor HP",
                  subtitle: userData?['nomorHp'] ?? "",
                ),
                _buildTile(
                  title: "Ganti Password",
                  subtitle: "",
                  onTap: () {
                    Navigator.pushNamed(context, "/gantiPassword");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
