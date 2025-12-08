import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:cemas/features/umkm/models/registration_model.dart';

class StepUMKM extends StatefulWidget {
  final RegistrationData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StepUMKM({
    super.key,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<StepUMKM> createState() => _StepUMKMState();
}

class _StepUMKMState extends State<StepUMKM> {
  final List<String> _kategoriList = [
    'Kelontong',
    'Kuliner',
    'Jasa',
    'Transportasi',
  ];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            "Data UMKM",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          _buildTextField(
            'Nama UMKM *',
            (val) => widget.data.namaUmkm = val,
            initial: widget.data.namaUmkm,
          ),

          // Dropdown Kategori
          DropdownButtonFormField<String>(
            initialValue: widget.data.kategori.isNotEmpty
                ? widget.data.kategori
                : null,
            decoration: InputDecoration(
              labelText: 'Kategori *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: _kategoriList
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => widget.data.kategori = val ?? '',
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Blok',
                  (val) => widget.data.blok = val,
                  initial: widget.data.blok,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  'Nomor',
                  (val) => widget.data.nomor = val,
                  initial: widget.data.nomor,
                ),
              ),
            ],
          ),

          _buildTextField(
            'Deskripsi Singkat *',
            (val) => widget.data.deskripsi = val,
            initial: widget.data.deskripsi,
            maxLines: 3,
          ),

          const SizedBox(height: 15),

          // FOTO UMKM
          _buildPhotoSection(),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  child: const Text('Kembali'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                  ),
                  child: const Text(
                    'Lanjut',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    Function(String) onChanged, {
    String? initial,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initial,
        onChanged: onChanged,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    // Check if file exists before displaying
    final photoPath = widget.data.fotoUmkmPath;
    // Di StepPemilik hanya cek != null, makanya aman.
    // Di sini kita pakai logika yang sama aman-nya untuk Web.
    final fileExists = photoPath != null &&
        (kIsWeb ? true : File(photoPath).existsSync());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto UMKM',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          if (fileExists)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: kIsWeb
                    ? Image.network(
                        photoPath,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                           return Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade100,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      )
                    : Image.file(
                        File(photoPath),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade100,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.photo_library, size: 20),
                  label: const Text('Pilih Galeri', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              if (fileExists) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearPhoto,
                    icon: const Icon(Icons.close, size: 20),
                    label: const Text('Hapus', style: TextStyle(fontSize: 12)),
                     style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null && mounted) {
        setState(() {
          widget.data.fotoUmkmPath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error memilih foto: $e')));
      }
    }
  }

  void _clearPhoto() {
    setState(() {
      widget.data.fotoUmkmPath = null;
    });
  }
}
