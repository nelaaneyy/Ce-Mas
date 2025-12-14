import 'package:cemas/features/admin/services/admin_service.dart';
import 'package:cemas/features/umkm/models/registration_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationDetailScreen extends StatelessWidget {
  final RegistrationData data;
  final bool isVerification; // New parameter

  const VerificationDetailScreen({
    super.key,
    required this.data,
    this.isVerification = true, // Default to true for backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(isVerification ? 'Detail Verifikasi' : 'Detail UMKM'), // Dynamic title
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
        child: Column(
          children: [
            // UMKM Photo Section
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: Stack(
                children: [
                   data.fotoUmkmPath != null || data.fotoUmkmUrl.isNotEmpty
                       ? Image.network(data.fotoUmkmUrl, fit: BoxFit.cover, width: double.infinity, errorBuilder: (c, o, s) => const Center(child: Icon(Icons.broken_image))) // Placeholder logic
                       : const Center(
                    child: Icon(Icons.image, size: 64, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Foto UMKM',
                        style: GoogleFonts.mPlusRounded1c(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form Data Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Pendaftaran',
                      style: GoogleFonts.mPlusRounded1c(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0066CC),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow('Nama UMKM', data.namaUmkm),
                    _buildDetailRow('Pemilik', data.namaPemilik),
                    // _buildDetailRow('NIK', data.nik), // Moved to bottom
                    _buildDetailRow('Kategori', data.kategori),
                    _buildDetailRow('Alamat', 'Blok ${data.blok} No. ${data.nomor} ${data.alamatLengkap}'.trim()), // Combined address
                    
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),

                    // KTP Photo Section
                    Text(
                      'Foto KTP',
                      style: GoogleFonts.mPlusRounded1c(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: data.fotoKtpUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                data.fotoKtpUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => const Center(
                                    child: Icon(Icons.broken_image, color: Colors.grey)),
                              ),
                            )
                          : const Center(
                              child: Text('-', style: TextStyle(color: Colors.grey))),
                    ),
                    
                    const SizedBox(height: 20),

                    _buildDetailRow('Kontak', '${data.noHp}\n${data.whatsapp}'),
                    
                    // Social Media
                    if (data.instagram.isNotEmpty) _buildDetailRow('Instagram', data.instagram),
                    if (data.facebook.isNotEmpty) _buildDetailRow('Facebook', data.facebook),
                    if (data.tiktok.isNotEmpty) _buildDetailRow('TikTok', data.tiktok),
                    
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),

                    Text(
                      'Deskripsi Usaha',
                      style: GoogleFonts.mPlusRounded1c(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.deskripsi.isEmpty ? '-' : data.deskripsi,
                      style: GoogleFonts.mPlusRounded1c(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'NIK',
                      style: GoogleFonts.mPlusRounded1c(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.nik.isEmpty ? '-' : data.nik,
                      style: GoogleFonts.mPlusRounded1c(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 80), // Space for bottom buttons
          ],
        ),
      ),
      bottomNavigationBar: isVerification ? Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Reject Action
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Konfirmasi', style: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.bold)),
                      content: Text('Apakah yakin ingin menolak verifikasi UMKM?', style: GoogleFonts.mPlusRounded1c()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context), // Cancel
                          child: Text('Tidak', style: GoogleFonts.mPlusRounded1c(color: Colors.grey)),
                        ),
                        TextButton(
                          onPressed: () async {
                             if (data.uid.isEmpty) {
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: ID Toko tidak ditemukan")));
                               return;
                             }
                            
                            // Call backend to reject
                            await AdminService().verifySeller(data.uid, false);
                            
                            if (context.mounted) {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context, true); // Close screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('UMKM berhasil ditolak'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Text('Ya', style: GoogleFonts.mPlusRounded1c(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Tolak',
                  style: GoogleFonts.mPlusRounded1c(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  if (data.uid.isEmpty) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: ID Toko tidak ditemukan")));
                     return;
                   }

                  // Call backend to approve
                  await AdminService().verifySeller(data.uid, true);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('UMKM berhasil diverifikasi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066CC),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Verifikasi',
                  style: GoogleFonts.mPlusRounded1c(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ) : null, // Hide if not verification
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.mPlusRounded1c(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.mPlusRounded1c(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
