import 'package:cemas/features/admin/services/admin_service.dart';
import 'package:cemas/features/admin/verification_detail_screen.dart';
import 'package:cemas/features/umkm/models/registration_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UmkmManagementScreen extends StatefulWidget {
  const UmkmManagementScreen({super.key});

  @override
  State<UmkmManagementScreen> createState() => _UmkmManagementScreenState();
}

class _UmkmManagementScreenState extends State<UmkmManagementScreen> {
  final AdminService _adminService = AdminService();

  void _deleteUmkm(String uid) async {
    try {
      await _adminService.deleteSeller(uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('UMKM berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus UMKM: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Kelola UMKM'),
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
      // FloatingActionButton removed as adding UMKM should be done via registration
      // If needed, can be re-added but requires robust implementation
      body: StreamBuilder<List<RegistrationData>>(
        stream: _adminService.getSellersStream(status: 'Terverifikasi'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }

          final activeUmkms = snapshot.data ?? [];

          if (activeUmkms.isEmpty) {
             return Center(child: Text('Tidak ada data UMKM', style: GoogleFonts.mPlusRounded1c(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeUmkms.length,
            itemBuilder: (context, index) {
              return _buildUmkmItem(context, activeUmkms[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildUmkmItem(BuildContext context, RegistrationData data) {
    // Handling potential missing data
    final addressDisplay = data.alamatLengkap.isNotEmpty 
        ? data.alamatLengkap 
        : (data.blok.isNotEmpty || data.nomor.isNotEmpty 
            ? 'Blok ${data.blok} No. ${data.nomor}' 
            : '-');

    Color statusColor = Colors.grey;
    if (data.status == 'Terverifikasi') statusColor = Colors.green;
    else if (data.status == 'Ditolak') statusColor = Colors.red;
    else if (data.status == 'Menunggu') statusColor = Colors.orange;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationDetailScreen(data: data, isVerification: false), 
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.store, color: Color(0xFF0066CC)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.namaUmkm,
                    style: GoogleFonts.mPlusRounded1c(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${data.kategori} • $addressDisplay',
                    style: GoogleFonts.mPlusRounded1c(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                   const SizedBox(height: 4),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                     decoration: BoxDecoration(
                       color: statusColor.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(4),
                       border: Border.all(color: statusColor),
                     ),
                     child: Text(
                       data.status,
                       style: GoogleFonts.mPlusRounded1c(
                         fontSize: 10,
                         color: statusColor,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ),
                ],
              ),
            ),
              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  if (data.uid.isNotEmpty) {
                    _showDeleteConfirmation(context, data);
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: ID Toko tidak valid")));
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, RegistrationData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text('Konfirmasi Hapus',
                style: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus UMKM "${data.namaUmkm}"?',
          style: GoogleFonts.mPlusRounded1c(),
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.mPlusRounded1c(
                    color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              _deleteUmkm(data.uid); // Perform Delete using ID
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Hapus',
                style: GoogleFonts.mPlusRounded1c(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
