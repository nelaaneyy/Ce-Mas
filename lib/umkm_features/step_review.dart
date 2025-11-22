import 'package:flutter/material.dart';
import 'registration_model.dart';

class StepReview extends StatelessWidget {
  final RegistrationData data;
  final VoidCallback onSubmit; // Fungsi untuk kirim ke Firebase
  final VoidCallback onBack;

  const StepReview({
    super.key, 
    required this.data, 
    required this.onSubmit, 
    required this.onBack
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Column(
              children: [
                Text("Review Data", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("Pastikan data sudah benar sebelum dikirim", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionTitle("Akun & Pemilik"),
          _buildInfoRow("Email", data.email),
          _buildInfoRow("Username", data.username),
          _buildInfoRow("Nama Pemilik", data.namaPemilik),
          _buildInfoRow("NIK", data.nik),

          const Divider(height: 30),

          _buildSectionTitle("Data UMKM"),
          _buildInfoRow("Nama Toko", data.namaUmkm),
          _buildInfoRow("Kategori", data.kategori),
          _buildInfoRow("Alamat", "Blok ${data.blok} No. ${data.nomor}"),
          _buildInfoRow("Deskripsi", data.deskripsi),

          const Divider(height: 30),

          _buildSectionTitle("Kontak"),
          _buildInfoRow("WhatsApp", data.whatsapp),
          _buildInfoRow("Instagram", data.instagram.isEmpty ? '-' : data.instagram),

          const SizedBox(height: 40),

          // TOMBOL KIRIM
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit, // Panggil fungsi submit di parent
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Kirim Untuk Verifikasi', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Kembali'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}