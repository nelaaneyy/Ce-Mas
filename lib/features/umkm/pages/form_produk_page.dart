import 'dart:io'; // Tetap butuh untuk Android/iOS
import 'package:flutter/foundation.dart'; // Untuk cek kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cemas/features/umkm/services/seller_service.dart';

class FormProdukPage extends StatefulWidget {
  final Map<String, dynamic>? productData;
  final String? productId;

  const FormProdukPage({super.key, this.productData, this.productId});

  @override
  State<FormProdukPage> createState() => _FormProdukPageState();
}

class _FormProdukPageState extends State<FormProdukPage> {
  final SellerService _sellerService = SellerService();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  
  // KITA GANTI DARI File? MENJADI XFile? (Agar aman di Web)
  XFile? _pickedFile; 
  String? _currentImageUrl;
  
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.productData != null) {
      _namaController.text = widget.productData!['namaProduk'];
      _hargaController.text = widget.productData!['harga'].toString();
      _currentImageUrl = widget.productData!['fotoProduk'];
    }
  }

  // --- FUNGSI 1: AMBIL GAMBAR DENGAN KOMPRESI ---
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,    // Compress to 70% quality
      maxWidth: 1024,      // Resize to max 1024px width
      maxHeight: 1024,     // Resize to max 1024px height
    );
    
    if (picked != null) {
      setState(() {
        _pickedFile = picked;
      });
    }
  }

  // --- FUNGSI 2: UPLOAD KE FIREBASE DENGAN TIMEOUT ---
  Future<String> _uploadImageToStorage() async {
    if (_pickedFile == null) return _currentImageUrl ?? '';

    try {
      // Wrap upload dengan timeout 30 detik
      return await _uploadImageInternal().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Upload timeout. Koneksi terlalu lambat.');
        },
      );
    } catch (e) {
      debugPrint("Error upload: $e");
      rethrow; // Lempar error ke _submit untuk handling
    }
  }

  // Helper method untuk upload actual
  Future<String> _uploadImageInternal() async {
    // 1. Buat nama file unik
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = FirebaseStorage.instance.ref().child('produk/$fileName.jpg');

    // 2. Upload (Beda cara Web vs Mobile)
    UploadTask uploadTask;
    
    if (kIsWeb) {
      // JIKA WEB: Kita upload "Bytes" (Data mentah), bukan File
      final bytes = await _pickedFile!.readAsBytes();
      uploadTask = storageRef.putData(bytes);
    } else {
      // JIKA HP: Kita upload File biasa
      uploadTask = storageRef.putFile(File(_pickedFile!.path));
    }

    // 3. Tunggu dan ambil URL
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // --- FUNGSI SUBMIT DENGAN ERROR HANDLING LEBIH BAIK ---
  void _submit() async {
    if (_namaController.text.isEmpty || _hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi Nama dan Harga")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      double harga = double.tryParse(_hargaController.text) ?? 0;
      
      // Upload gambar dengan error handling terpisah
      String finalImageUrl = '';
      if (_pickedFile != null) {
        // User MEMILIH foto, coba upload
        try {
          finalImageUrl = await _uploadImageToStorage();
        } catch (e) {
          // Upload GAGAL - tanya user mau lanjut tanpa foto atau tidak
          if (mounted) {
            setState(() => _isLoading = false);
            bool continueWithoutPhoto = await _showPhotoErrorDialog(e.toString());
            if (!continueWithoutPhoto) {
              return; // User cancel
            }
            setState(() => _isLoading = true);
          }
          // Lanjut tanpa foto (finalImageUrl tetap '')
        }
      } else {
        // User TIDAK pilih foto baru
        // Jika edit, pakai foto lama. Jika tambah baru, kosong.
        finalImageUrl = _currentImageUrl ?? '';
      }

      // Simpan produk
      if (widget.productData == null) {
        // TAMBAH
        await _sellerService.addProduct(
          namaProduk: _namaController.text,
          harga: harga,
          deskripsi: "Deskripsi default",
          kategori: "Kuliner",
          fotoProdukUrl: finalImageUrl,
        );
      } else {
        // EDIT
        await _sellerService.updateProduct(widget.productId!, {
          'namaProduk': _namaController.text,
          'harga': harga,
          'fotoProduk': finalImageUrl,
        });
      }

      if (mounted) {
        Navigator.pop(context, widget.productData == null ? 'added' : 'edited');
      }
    } catch (e) {
      // Error saat menyimpan produk ke Firestore
      String errorMsg = 'Gagal menyimpan produk';
      if (e.toString().contains('network')) {
        errorMsg = 'Tidak ada koneksi internet';
      } else if (e.toString().contains('permission')) {
        errorMsg = 'Tidak memiliki izin untuk menyimpan';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- DIALOG ERROR FOTO ---
  Future<bool> _showPhotoErrorDialog(String error) async {
    String errorMessage = 'Gagal mengupload foto.';
    
    if (error.contains('timeout')) {
      errorMessage = 'Upload terlalu lama. Koneksi internet Anda mungkin lambat.';
    } else if (error.contains('network')) {
      errorMessage = 'Tidak ada koneksi internet.';
    } else if (error.contains('storage')) {
      errorMessage = 'Gagal menyimpan foto ke server.';
    }

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload Foto Gagal'),
        content: Text('$errorMessage\n\nSimpan produk tanpa foto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Simpan Tanpa Foto',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.productData != null;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Produk" : "Tambah Produk", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // CONTAINER PUTIH
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenSize.height * 0.75,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildLabel("Nama Produk"),
                    _buildTextField(controller: _namaController),
                    const SizedBox(height: 20),
                    _buildLabel("Harga Produk"),
                    _buildTextField(controller: _hargaController, isNumber: true),
                    const SizedBox(height: 20),
                    _buildLabel("Foto Produk"),
                    
                    // TOMBOL PILIH GAMBAR
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], elevation: 0),
                            onPressed: _pickImage, 
                            child: const Text('Pilih Gambar', style: TextStyle(color: Colors.black)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _pickedFile != null ? "Gambar terpilih" : "Belum ada file", 
                              overflow: TextOverflow.ellipsis, 
                              style: const TextStyle(color: Colors.grey)
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // TOMBOL AKSI
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.blue.shade800),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text("Kembali", style: TextStyle(color: Colors.blue.shade800)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _isLoading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Simpan", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),

          // ICON PREVIEW GAMBAR (MENGAMBANG) - LOGIKA BARU
          Positioned(
            top: 20, 
            left: 0, 
            right: 0,
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildImagePreview(), // Fungsi preview dipisah
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIKA TAMPILAN GAMBAR (WEB vs MOBILE) ---
  Widget _buildImagePreview() {
    if (_pickedFile != null) {
      // Jika ada gambar baru dipilih
      if (kIsWeb) {
        // WEB: Pakai Image.network (blob URL)
        return Image.network(_pickedFile!.path, fit: BoxFit.cover);
      } else {
        // MOBILE: Pakai Image.file
        return Image.file(File(_pickedFile!.path), fit: BoxFit.cover);
      }
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      // Jika sedang Edit dan ada gambar lama
      return Image.network(_currentImageUrl!, fit: BoxFit.cover);
    } else {
      // Kosong
      return Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey.shade400);
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}