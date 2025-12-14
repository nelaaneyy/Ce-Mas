import 'package:cemas/features/admin/services/admin_service.dart';
import 'package:cemas/features/admin/complaint_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplaintListScreen extends StatelessWidget {
  const ComplaintListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminService adminService = AdminService();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Daftar Aduan'),
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
        stream: adminService.getComplaintsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }

          final complaints = snapshot.data ?? [];

          if (complaints.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada aduan masuk.',
                style: GoogleFonts.mPlusRounded1c(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              // Convert dynamic map to String map for the widget (or update widget)
              // Since the widget expects Map<String, String>, we ensure types.
              // Note: our service returns dynamic values, but we mapped them nicely.
              // We need to be careful with types.
              final Map<String, String> stringComplaint = {
                'id': complaint['id'].toString(),
                'sender': complaint['sender'].toString(),
                'message': complaint['message'].toString(),
                'date': complaint['date'].toString(),
                'status': complaint['status'].toString(),
                'uid': complaint['uid'].toString(), // Added UID for reply
                'reply': complaint['reply']?.toString() ?? '', // Added Reply content
              };

              return _buildComplaintItem(context, stringComplaint);
            },
          );
        },
      )
    );
  }

  Widget _buildComplaintItem(BuildContext context, Map<String, String> data) {
    bool isUnread = data['status'] == 'Baru';

    return GestureDetector(
      onTap: () {
        // Mark as read immediately when tapped if it's new
        if (isUnread) {
          AdminService().markComplaintAsRead(data['id']!);
        }
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComplaintDetailScreen(data: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? Colors.red.withOpacity(0.05) : Colors.white, // Highlight unread
          borderRadius: BorderRadius.circular(12),
          border: isUnread 
              ? Border.all(color: Colors.red.withOpacity(0.5), width: 1.5) 
              : Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data['sender']!,
                    style: GoogleFonts.mPlusRounded1c(
                      fontSize: 16,
                      fontWeight: isUnread ? FontWeight.w900 : FontWeight.bold,
                      color: isUnread ? Colors.black : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(data['status']!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getStatusColor(data['status']!)),
                  ),
                  child: Text(
                    data['status']!,
                    style: GoogleFonts.mPlusRounded1c(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(data['status']!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data['message']!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.mPlusRounded1c(
                fontSize: 14,
                color: isUnread ? Colors.black87 : Colors.grey[700],
                fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['date']!,
                  style: GoogleFonts.mPlusRounded1c(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (isUnread)
                  const Icon(Icons.circle, size: 8, color: Colors.red)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Baru':
        return Colors.red;
      case 'Dibalas':
        return Colors.green;
      case 'Dibaca':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
