import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:cemas/features/umkm/models/registration_model.dart';

class StepPemilik extends StatefulWidget {
  final RegistrationData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StepPemilik({
    super.key,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<StepPemilik> createState() => _StepPemilikState();
}

class _StepPemilikState extends State<StepPemilik> {
  final ImagePicker _imagePicker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Column(
              children: [
                Text(
                  "Data Pemilik",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "Identitas pemilik untuk verifikasi",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: 'Nama Pemilik *',
            initialValue:
                widget.data.namaPemilik, // Isi jika sudah ada data sebelumnya
            onChanged: (val) => widget.data.namaPemilik = val,
          ),

          _buildTextField(
            label: 'NIK *',
            initialValue: widget.data.nik,
            isNumber: true,
            onChanged: (val) => widget.data.nik = val,
          ),

          _buildKtpPhotoSection(),

          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: Colors.blue.shade800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: widget.onBack, // Panggil fungsi kembali
                  child: Text(
                    'Kembali',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: widget.onNext, // Panggil fungsi lanjut
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

  // --- Helper Widgets ---
  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    String? initialValue,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildKtpPhotoSection() {
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
            'Foto KTP *',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          if (widget.data.fotoKtpPath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: kIsWeb
                    ? Image.network(
                        widget.data.fotoKtpPath!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(widget.data.fotoKtpPath!),
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                height: 120,
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _pickKtpPhoto,
                icon: const Icon(Icons.photo_library),
                label: const Text('Pilih Galeri'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                ),
              ),
              if (widget.data.fotoKtpPath != null)
                OutlinedButton.icon(
                  onPressed: _clearKtpPhoto,
                  icon: const Icon(Icons.close),
                  label: const Text('Hapus'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickKtpPhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null && mounted) {
        setState(() {
          widget.data.fotoKtpPath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error memilih foto KTP: $e')));
      }
    }
  }

  void _clearKtpPhoto() {
    setState(() {
      widget.data.fotoKtpPath = null;
    });
  }
}
