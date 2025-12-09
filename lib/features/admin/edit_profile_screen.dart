import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cemas/features/admin/services/admin_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }



  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Try fetching from 'admins' first
        var doc = await FirebaseFirestore.instance.collection('admins').doc(user.uid).get();
        
        if (!doc.exists) {
          // Fallback: Try fetching from 'users' if not yet migrated
          doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        }

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          // Handle field differences: 'nama' in admins vs 'namaPertama' in users
          _nameController.text = data['nama'] ?? data['namaPertama'] ?? '';
          _emailController.text = data['email'] ?? user.email ?? '';
        }
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();

      // 1. Update/Create in 'admins' collection
      await FirebaseFirestore.instance.collection('admins').doc(user.uid).set({
        'nama': newName,
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Log Activity
      await AdminService().logActivity('Admin memperbarui profil (Nama:Key $newName)', 'info');

      // 3. Update Firebase Auth Email if changed
      if (user.email != newEmail) {
        await user.verifyBeforeUpdateEmail(newEmail);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email verifikasi dikirim ke email baru. Mohon verifikasi untuk mengubah email login.')),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBack() async {
    // Show confirmation dialog
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi', style: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.bold)),
        content: Text('Apakah yakin ingin keluar dan data akan hilang?', style: GoogleFonts.mPlusRounded1c()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // No, stay
            child: Text('Tidak', style: GoogleFonts.mPlusRounded1c(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Yes, exit
            child: Text('Ya', style: GoogleFonts.mPlusRounded1c(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldPop == true && mounted) {
      Navigator.pop(context); // Actually pop the screen
      // Show failure notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data gagal tersimpan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use PopScope to intercept system back button
    return PopScope(
      canPop: false, // Prevent automatic pop
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Edit Profil'),
          backgroundColor: const Color(0xFF0066CC),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack, // Intercept AppBar back button
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.mPlusRounded1c(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Photo Edit Section
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFE3F2FD),
                      child: Icon(Icons.person, size: 50, color: Color(0xFF0066CC)),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              _buildTextField('Nama', _nameController),
              const SizedBox(height: 20),
              _buildTextField('Email', _emailController),
              
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Simpan',
                            style: GoogleFonts.mPlusRounded1c(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.mPlusRounded1c(),
            decoration: InputDecoration(
              hintText: 'Masukkan $label',
              hintStyle: GoogleFonts.mPlusRounded1c(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
