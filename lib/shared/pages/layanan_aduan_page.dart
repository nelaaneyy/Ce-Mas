import 'package:cemas/features/admin/services/admin_service.dart';
import 'package:cemas/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LayananAduanPage extends StatefulWidget {
  const LayananAduanPage({super.key});

  @override
  State<LayananAduanPage> createState() => _LayananAduanPageState();
}

class _LayananAduanPageState extends State<LayananAduanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      // 1. Simpan Aduan ke Firestore
      await FirebaseFirestore.instance.collection('complaints').add({
        'uid': user.uid,
        'sender': user.email ?? 'Pengguna',
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Baru',
      });

      // 2. Log Activity untuk Admin (New Feature)
      try {
        // Log is always type 'warning' or 'error' context for complaints? Or just 'info'.
        // Let's use 'info'.
        AdminService().logActivity(
          'Aduan Baru dari ${user.email}: "${_messageController.text.length > 20 ? '${_messageController.text.substring(0, 20)}...' : _messageController.text}"', 
          'warning'
        );
      } catch (e) {
        // ignore log error
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aduan berhasil dikirim. Terima kasih.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim aduan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Layanan Aduan'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Form Section
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceLG),
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sampaikan keluhan atau masukan Anda:',
                    style: AppTheme.labelBold,
                  ),
                  const SizedBox(height: AppTheme.spaceMD),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan aduan Anda di sini...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundLight,
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Aduan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitComplaint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: AppTheme.backgroundWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Kirim Aduan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // History Title
          Padding(
            padding: const EdgeInsets.fromLTRB(AppTheme.spaceLG, AppTheme.spaceXL, AppTheme.spaceLG, AppTheme.spaceSM),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Riwayat Aduan Saya',
                style: AppTheme.h3,
              ),
            ),
          ),
          
          // History List
          Expanded(
            child: user == null 
              ? const Center(child: Text('Silakan login untuk melihat riwayat.'))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('complaints')
                      .where('uid', isEqualTo: user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 60, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Belum ada riwayat aduan.', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    // Sort documents in-memory to avoid composite index requirement
                    final docs = snapshot.data!.docs.toList();
                    docs.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTimestamp = aData['timestamp'] as Timestamp?;
                      final bTimestamp = bData['timestamp'] as Timestamp?;
                      
                      if (aTimestamp == null && bTimestamp == null) return 0;
                      if (aTimestamp == null) return 1;
                      if (bTimestamp == null) return -1;
                      
                      return bTimestamp.compareTo(aTimestamp); // Descending order
                    });

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLG, vertical: AppTheme.spaceSM),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return _buildComplaintCard(data);
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> data) {
    final String message = data['message'] ?? '';
    final String status = data['status'] ?? 'Baru';
    final String reply = data['reply'] ?? '';
    final Timestamp? timestamp = data['timestamp'] as Timestamp?;
    
    // Format date simple
    String dateStr = '';
    if (timestamp != null) {
        final dt = timestamp.toDate();
        dateStr = "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    }

    Color statusColor = Colors.grey;
    if (status == 'Baru') statusColor = Colors.red;
    else if (status == 'Dibaca') statusColor = Colors.orange;
    else if (status == 'Dibalas') statusColor = Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            if (reply.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  border: Border(left: BorderSide(color: Colors.blue.shade600, width: 4)),
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balasan Admin:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reply,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
