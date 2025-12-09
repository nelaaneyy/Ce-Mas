import 'package:cemas/features/admin/services/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  final AdminService _adminService = AdminService();

  void _deleteActivity(String id) async {
    try {
      await _adminService.deleteActivity(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aktivitas berhasil dihapus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Konfirmasi', style: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan aktivitas ini?',
          style: GoogleFonts.mPlusRounded1c(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.mPlusRounded1c(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteActivity(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus', style: GoogleFonts.mPlusRounded1c(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Aktivitas', style: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Waktu:', style: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.bold)),
            Text(activity['fullTimestamp'] ?? activity['time'], style: GoogleFonts.mPlusRounded1c()),
            const SizedBox(height: 12),
            Text('Keterangan:', style: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.bold)),
            Text(activity['text'], style: GoogleFonts.mPlusRounded1c()),
            const SizedBox(height: 12),
            Text('Type:', style: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.bold)),
            Text(activity['type'], style: GoogleFonts.mPlusRounded1c()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: GoogleFonts.mPlusRounded1c()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Aktivitas Sistem'),
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _adminService.getActivityLogsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final activities = snapshot.data ?? [];

          if (activities.isEmpty) {
             return Center(
              child: Text(
                'Belum ada aktivitas tercatat',
                style: GoogleFonts.mPlusRounded1c(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              IconData icon = Icons.info;
              Color color = Colors.blue;
              
              if (activity['type'] == 'success') {
                icon = Icons.check_circle;
                color = Colors.green;
              } else if (activity['type'] == 'warning') {
                  icon = Icons.warning;
                  color = Colors.orange;
              } else if (activity['type'] == 'error') {
                  icon = Icons.error;
                  color = Colors.red;
              }

              return GestureDetector(
                onTap: () => _showDetail(context, activity),
                child: _buildActivityItem(
                  activity,
                  icon,
                  color,
                ),
              );
            },
          );
        },
      )
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['text'],
                  style: GoogleFonts.mPlusRounded1c(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  activity['time'],
                  style: GoogleFonts.mPlusRounded1c(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
            onPressed: () => _showDeleteConfirmation(context, activity['id']),
            tooltip: 'Hapus Aktivitas',
          ),
        ],
      ),
    );
  }
}
