import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cemas/core/theme/app_theme.dart';
import 'package:cemas/shared/pages/detail_notifikasi_page.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    if (diff.inDays < 7) return '${diff.inDays}h lalu';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Notifikasi")),
        body: const Center(child: Text("Silakan login untuk melihat notifikasi")),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.backgroundWhite,
        title: const Text("Notifikasi"),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('uid', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada notifikasi",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spaceLG),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;

              final title = data['title'] ?? 'Notifikasi';
              final message = data['message'] ?? '';
              final timestamp = data['timestamp'] as Timestamp?;
              final isRead = data['isRead'] ?? false;
              final waktu = _formatTimestamp(timestamp);

              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spaceLG),
                padding: const EdgeInsets.all(AppTheme.spaceLG),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Waktu + titik merah
                    Row(
                      children: [
                        Text(
                          waktu,
                          style: AppTheme.bodySmall,
                        ),
                        const SizedBox(width: AppTheme.spaceSM),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.secondaryRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceSM),

                    // Pesan (Judul)
                    Text(
                      title,
                      style: AppTheme.labelBold.copyWith(
                        fontSize: 16,
                        fontWeight: !isRead ? FontWeight.w600 : FontWeight.bold,
                      ),
                    ),
                    // Snippet Message (Optional)
                     const SizedBox(height: 4),
                     Text(
                       message,
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                       style: const TextStyle(fontSize: 12, color: Colors.grey),
                     ),

                    const SizedBox(height: AppTheme.spaceMD),

                    // Tombol tindakan
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Mark as read
                          if (!isRead) {
                            doc.reference.update({'isRead': true});
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailNotifikasiPage(
                                waktu: waktu,
                                pesan: title,
                                umkmNama: '', // Not strictly needed for generic notifications
                                deskripsi: message,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: AppTheme.backgroundWhite,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spaceMD),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMD),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Lihat Notifikasi",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
