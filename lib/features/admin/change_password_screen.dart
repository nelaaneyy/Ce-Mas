import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cemas/features/admin/services/admin_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Password validation regex
  // Contains at least one uppercase letter, one lowercase letter, and one number.
  bool _isPasswordStrong(String password) {
    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    final hasDigits = RegExp(r'[0-9]').hasMatch(password);
    return hasUpperCase && hasLowerCase && hasDigits;
  }

  bool _isLoading = false;

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: _oldPasswordController.text,
        );



        // 1. Re-authenticate
        await user.reauthenticateWithCredential(cred);

        // 2. Update Password
        await user.updatePassword(_newPasswordController.text);

        // 3. Update 'lastPasswordChange' in admins collection
        await FirebaseFirestore.instance.collection('admins').doc(user.uid).set({
          'lastPasswordChange': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 4. Log Activity
        await AdminService().logActivity('Admin mengubah password', 'warning');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password berhasil diubah'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Gagal mengubah password';
        if (e.code == 'wrong-password') {
          message = 'Password lama salah';
        } else if (e.code == 'weak-password') {
          message = 'Password terlalu lemah';
        } else if (e.code == 'requires-recent-login') {
            message = 'Sesi habis, silakan login ulang';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Terjadi kesalahan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleBack() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi', style: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.bold)),
        content: Text('Yakin ingin membatalkan? Tindakan ini akan menyebabkan data yang telah diisi akan hilang.', style: GoogleFonts.mPlusRounded1c()),
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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password gagal diganti'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleCancel() {
    _handleBack();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Ganti Password'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
        backgroundColor: const Color(0xFF0066CC),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.mPlusRounded1c(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPasswordField(
                label: 'Password Lama',
                controller: _oldPasswordController,
                obscureText: _obscureOld,
                onToggleVisibility: () => setState(() => _obscureOld = !_obscureOld),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password lama wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'Password Baru',
                controller: _newPasswordController,
                obscureText: _obscureNew,
                onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                helperText: 'Harus mengandung huruf besar, kecil, dan angka',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password baru wajib diisi';
                  }
                  if (!_isPasswordStrong(value)) {
                    return 'Harus mengandung huruf besar, kecil, dan angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'Konfirmasi Password Baru',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password wajib diisi';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Password tidak sama';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              
              // Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleSave,
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _handleCancel,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.mPlusRounded1c(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
    String? helperText,
  }) {
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
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: GoogleFonts.mPlusRounded1c(),
            validator: validator,
            decoration: InputDecoration(
              hintText: 'Masukkan $label',
              hintStyle: GoogleFonts.mPlusRounded1c(color: Colors.grey),
              helperText: helperText,
              helperStyle: GoogleFonts.mPlusRounded1c(fontSize: 12, color: Colors.grey[600]),
              helperMaxLines: 2,
              errorStyle: GoogleFonts.mPlusRounded1c(color: Colors.red),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
