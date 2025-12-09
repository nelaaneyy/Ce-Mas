import 'package:cemas/features/admin/services/admin_service.dart';
import 'package:cemas/features/admin/verification_detail_screen.dart';
import 'package:cemas/features/umkm/models/registration_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationListScreen extends StatefulWidget {
  const VerificationListScreen({super.key});

  @override
  State<VerificationListScreen> createState() => _VerificationListScreenState();
}

class _VerificationListScreenState extends State<VerificationListScreen> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Verifikasi UMKM'),
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
      body: StreamBuilder<List<RegistrationData>>(
        stream: _adminService.getSellersStream(status: 'Menunggu'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }

          final pendingVerifications = snapshot.data ?? [];

          if (pendingVerifications.isEmpty) {
             return Center(
              child: Text(
                'Tidak ada permohonan verifikasi.',
                style: GoogleFonts.mPlusRounded1c(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingVerifications.length,
            itemBuilder: (context, index) {
              final data = pendingVerifications[index];
              return _buildVerificationItem(context, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildVerificationItem(BuildContext context, RegistrationData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  data.namaPemilik,
                  style: GoogleFonts.mPlusRounded1c(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // CORRECTLY PLACED BUTTON
          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerificationDetailScreen(data: data),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066CC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Cek',
              style: GoogleFonts.mPlusRounded1c(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
