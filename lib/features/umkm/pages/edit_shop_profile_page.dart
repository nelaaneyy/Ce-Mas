import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cemas/core/theme/app_theme.dart';
import 'package:cemas/features/umkm/services/seller_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class EditShopProfilePage extends StatefulWidget {
  const EditShopProfilePage({super.key});

  @override
  State<EditShopProfilePage> createState() => _EditShopProfilePageState();
}

class _EditShopProfilePageState extends State<EditShopProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final SellerService _sellerService = SellerService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _descController;
  late TextEditingController _phoneController;

  bool _isLoading = true;
  bool _isSaving = false;

  String? _currentFotoToko;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _descController = TextEditingController();
    _phoneController = TextEditingController();

    _loadShopData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadShopData() async {
    if (_currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(_currentUser!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['namaToko'] ?? '';
          _addressController.text = data['alamat'] ?? '';
          _descController.text = data['deskripsi'] ?? '';
          _currentFotoToko = data['fotoToko'] ?? data['fotoUmkm']; // Fallback
          
          String phone = data['noWhatsapp'] ?? '';
          if (phone.startsWith('62')) {
            phone = '0${phone.substring(2)}';
          }
          _phoneController.text = phone;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading shop data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _localImagePath = file.path;
      });
    }
  }

  Future<String?> _uploadImage() async {
     if (_localImagePath == null) return null;

     // 1. Coba Kompresi
     Uint8List? uploadData;
     try {
       final compressedBytes = await FlutterImageCompress.compressWithFile(
         _localImagePath!,
         quality: 50,
         format: CompressFormat.jpeg,
       );
       if (compressedBytes != null) {
         uploadData = compressedBytes;
       }
     } catch (e) {
       debugPrint("Kompresi gagal: $e");
     }

     // 2. Fallback ke File Asli
     if (uploadData == null) {
       try {
         uploadData = await File(_localImagePath!).readAsBytes();
       } catch (e) {
         debugPrint("Baca file asli gagal: $e");
         return null;
       }
     }

     // 3. Upload ke Firebase Storage
     try {
       // Use User UID to overwrite old photo (profile photo convention)
       // Or timestamp for unique history. Let's use simple overwrite for 'store_profile'
       final ref = FirebaseStorage.instance.ref().child('seller_profile/${_currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
       
       await ref.putData(uploadData, SettableMetadata(contentType: 'image/jpeg'));
       return await ref.getDownloadURL();
     } catch (e) {
       debugPrint("Upload failed: $e");
       return null;
     }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // 1. Upload Photo if changed
      String? newPhotoUrl = await _uploadImage();

      // 2. Update Profile
      await _sellerService.updateStoreProfile(
        namaToko: _nameController.text.trim(),
        deskripsi: _descController.text.trim(),
        noWhatsapp: _phoneController.text.trim(),
        alamat: _addressController.text.trim(),
        fotoToko: newPhotoUrl, // Null if not changed, handled in service to NOT overwrite if null? 
                               // Wait, service logic needs to handle null vs new value.
                               // My service logic was: if (fotoToko != null) update it. 
                               // Here if newPhotoUrl is null (no change), it won't be updated. Correct.
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data toko berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memperbarui data: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text("Edit Data Toko"),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- PHOTO UPLOAD UI ---
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.grey.shade300, width: 2),
                                image: (_localImagePath != null)
                                    ? DecorationImage(
                                        image: FileImage(File(_localImagePath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : (_currentFotoToko != null && _currentFotoToko!.isNotEmpty)
                                        ? DecorationImage(
                                            image: NetworkImage(_currentFotoToko!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                              ),
                              child: (_localImagePath == null && (_currentFotoToko == null || _currentFotoToko!.isEmpty))
                                  ? const Icon(Icons.store, size: 60, color: Colors.grey)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(child: Text("Ketuk untuk ganti foto toko", style: TextStyle(color: Colors.grey))),
                    const SizedBox(height: 30),

                    // --- Read Only Email ---
                    TextFormField(
                      initialValue: _currentUser?.email ?? '',
                      readOnly: true,
                      decoration: _inputDecoration("Email (Tidak dapat diubah)"),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 15),

                    // --- Editable Fields ---
                    _buildTextField(
                      controller: _nameController,
                      label: "Nama Toko *",
                      validator: (val) => val == null || val.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _addressController,
                      label: "Alamat Lengkap *",
                      validator: (val) => val == null || val.isEmpty ? "Wajib diisi" : null,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _descController,
                      label: "Deskripsi Toko *",
                      validator: (val) => val == null || val.isEmpty ? "Wajib diisi" : null,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _phoneController,
                      label: "Nomor Telepon (WhatsApp) *",
                      validator: (val) => val == null || val.isEmpty ? "Wajib diisi" : null,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 30),

                    // --- Save Button ---
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Simpan Perubahan",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
