import 'dart:io'; // Tetap butuh untuk Android/iOS
import 'package:flutter/foundation.dart'; // Untuk cek kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'seller_service.dart';

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

  // --- FUNGSI 1: AMBIL GAMBAR ---
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    
    if (picked != null) {
      setState(() {
        _pickedFile = picked;
      });
    }
  }

  // --- FUNGSI 2: UPLOAD KE FIREBASE (KOMPATIBEL WEB & HP) ---
  Future<String> _uploadImageToStorage() async {
    if (_pickedFile == null) return _currentImageUrl ?? '';

    try {
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
      
    } catch (e) {
      print("Error upload: $e");
      return '';
    }
  }

  // --- FUNGSI SUBMIT ---
  void _submit() async {
    if (_namaController.text.isEmpty || _hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi Nama dan Harga")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      double harga = double.tryParse(_hargaController.text) ?? 0;
      
      // Upload gambar dulu
      String finalImageUrl = await _uploadImageToStorage();

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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