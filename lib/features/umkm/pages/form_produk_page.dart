import 'package:flutter/material.dart';
import 'package:cemas/features/umkm/services/seller_service.dart';
import 'package:cemas/core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';

class FormProdukPage extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? initialData;

  const FormProdukPage({super.key, this.productId, this.initialData});

  @override
  State<FormProdukPage> createState() => _FormProdukPageState();
}

class _FormProdukPageState extends State<FormProdukPage> {
  final _formKey = GlobalKey<FormState>();
  final SellerService _sellerService = SellerService();
  
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  String _category = 'Makanan';
  
  String? _fotoUrl;
  String? _localImagePath;
  
  bool _isLoading = false;

  final List<String> _categories = ['Makanan', 'Minuman', 'Kerajinan', 'Jasa', 'Fashion', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['namaProduk'] ?? '');
    _descController = TextEditingController(text: widget.initialData?['deskripsi'] ?? '');
    _priceController = TextEditingController(text: widget.initialData != null ? widget.initialData!['harga'].toString() : '');
    _category = widget.initialData?['kategori'] ?? 'Makanan';
    _fotoUrl = widget.initialData?['fotoProduk'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
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
     debugPrint("Start _uploadImage");
     if (_localImagePath == null) {
       debugPrint("Local path is null, return existing url: $_fotoUrl");
       return _fotoUrl;
     }

     // Use XFile for better cross-platform/permission handling
     final xFile = XFile(_localImagePath!);
     Uint8List? uploadData;

     // 1. Coba Kompresi
     try {
       debugPrint("Compressing file: $_localImagePath");
       final compressedBytes = await FlutterImageCompress.compressWithFile(
         _localImagePath!,
         quality: 50,
         format: CompressFormat.jpeg,
       );
       if (compressedBytes != null) {
         uploadData = compressedBytes;
         debugPrint("Compression successful. Size: ${compressedBytes.length}");
       } else {
         debugPrint("Compression returned null");
       }
     } catch (e) {
       debugPrint("Kompresi gagal: $e");
     }

     // 2. Fallback: Read using XFile
     if (uploadData == null) {
       try {
         debugPrint("Reading original file via XFile...");
         uploadData = await xFile.readAsBytes();
         debugPrint("Read original successful. Size: ${uploadData.length}");
       } catch (e) {
         debugPrint("Baca file asli gagal: $e");
         throw Exception("Gagal membaca file foto: $e");
       }
     }

     // 3. Upload ke Firebase Storage
     try {
       String fileName = DateTime.now().millisecondsSinceEpoch.toString();
       debugPrint("Uploading to products/$fileName.jpg");
       final ref = FirebaseStorage.instance.ref().child('products/$fileName.jpg');
       
       final taskSnapshot = await ref.putData(uploadData, SettableMetadata(contentType: 'image/jpeg'));
       debugPrint("Upload complete. Bytes transferred: ${taskSnapshot.bytesTransferred}");

       final downloadUrl = await ref.getDownloadURL();
       debugPrint("Download URL: $downloadUrl");
       return downloadUrl;
     } catch (e) {
       debugPrint("Upload failed: $e");
       throw Exception("Gagal upload ke server: $e");
     }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      String? url;
      // If user selected a new image, try to upload it
      if (_localImagePath != null) {
        url = await _uploadImage();
        if (url == null) {
           throw Exception("Gagal mengupload foto. Silakan coba lagi.");
        }
      } else {
        // Prepare existing URL for update logic, though update logic handles nulls differently
        url = _fotoUrl; 
      }
      
      final double price = double.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      if (widget.productId == null) {
        // Add
        await _sellerService.addProduct(
          namaProduk: _nameController.text, 
          deskripsi: _descController.text, 
          harga: price, 
          kategori: _category,
          fotoProdukUrl: url // Will be the new URL, or null (if no image selected)
        );
      } else {
        // Update
        await _sellerService.updateProduct(widget.productId!, {
          'namaProduk': _nameController.text,
          'deskripsi': _descController.text,
          'harga': price,
          'kategori': _category,
          if (url != null) 'fotoProduk': url
        });
      }

      if (mounted) {
         Navigator.pop(context);
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produk berhasil disimpan")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Gagal: $e"),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.productId != null;
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Produk" : "Tambah Produk"),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Foto Upload
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: (_localImagePath != null) 
                    ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(_localImagePath!), fit: BoxFit.cover))
                    : (_fotoUrl != null)
                      ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(_fotoUrl!, fit: BoxFit.cover))
                      : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40, color: Colors.grey), Text("Upload Foto Produk")]),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: _inputDeco("Nama Produk"),
                validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _priceController,
                decoration: _inputDeco("Harga (Rp)").copyWith(prefixText: "Rp "),
                keyboardType: TextInputType.number,
                 validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _category,
                decoration: _inputDeco("Kategori"),
                items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _descController,
                decoration: _inputDeco("Deskripsi"),
                maxLines: 3,
                 validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
              ),
              
              const SizedBox(height: 30),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Simpan Produk", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}