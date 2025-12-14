import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // Required for StreamController
import 'package:cemas/features/umkm/models/registration_model.dart';
import 'package:flutter/foundation.dart'; // For debug print if needed

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- 1. GET ALL SELLERS (UMKM) ---
  // --- 1. GET ALL SELLERS (UMKM) ---
  // Modified to optionally filter by status
  Stream<List<RegistrationData>> getSellersStream({String? status}) {
    Query query = _firestore.collection('sellers');
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return RegistrationData()
          ..namaUmkm = data['namaToko'] ?? ''
          ..deskripsi = data['deskripsi'] ?? ''
          ..nomor = '' 
          ..blok = ''
          ..alamatLengkap = data['alamat'] ?? ''
          ..kategori = data['kategori'] ?? ''
          ..whatsapp = data['noWhatsapp'] ?? ''
          ..fotoUmkmUrl = data['fotoUmkm'] ?? ''
          ..status = data['status'] ?? 'Menunggu'
          // Mapped New Fields
          ..nik = data['nik'] ?? ''
          ..namaPemilik = data['namaPemilik'] ?? ''
          ..fotoKtpUrl = data['fotoKtp'] ?? ''
          ..instagram = data['instagram'] ?? ''
          ..facebook = data['facebook'] ?? ''
          ..tiktok = data['tiktok'] ?? ''
          ..uid = doc.id;
      }).toList();
    });
  }

  // --- 2. VERIFIKASI SELLER ---
  Future<void> verifySeller(String uid, bool isApproved) async {
    try {
      final status = isApproved ? 'Terverifikasi' : 'Ditolak';
      await _firestore.collection('sellers').doc(uid).update({
        'status': status,
      });
      
      // Log Activity
      final statusText = isApproved ? 'disetujui' : 'ditolak';
      await logActivity('Verifikasi UMKM (ID: ${uid.substring(0, 5)}...) $statusText.', isApproved ? 'success' : 'warning');
      
    } catch (e) {
      rethrow;
    }
  }

  // --- 3. HAPUS SELLER ---
  Future<void> deleteSeller(String uid) async {
    try {
      await _firestore.collection('sellers').doc(uid).delete();
      await logActivity('Menghapus data UMKM (ID: ${uid.substring(0, 5)}...).', 'error');
    } catch (e) {
      rethrow;
    }
  }
    
  // --- 4. DATA PEMBELI ---
  Stream<List<Map<String, dynamic>>> getAllBuyersStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'pembeli')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'name': '${data['namaPertama'] ?? ''} ${data['namaTerakhir'] ?? ''}'.trim(),
          'email': data['email'] ?? '',
          'phone': data['nomorHp'] ?? '',
          'status': 'Aktif', // Logic status bisa dikembangkan
        };
      }).toList();
    });
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  // --- 5. DASHBOARD STATS ---
  Stream<Map<String, int>> getDashboardStats() {
    // Using StreamController to combine multiple streams for real-time updates
    // This ensures that changes in sellers, buyers, or complaints trigger a UI update
    late StreamController<Map<String, int>> controller;
    
    // Store latest values
    int totalUmkm = 0;
    int pendingVerification = 0;
    int totalBuyers = 0;
    int totalComplaints = 0;
    
    // Subscriptions
    // ignore: cancel_subscriptions
    var subs = <dynamic>[];

    void emitStats() {
      if (!controller.isClosed) {
        controller.add({
          'totalUmkm': totalUmkm,
          'pendingVerification': pendingVerification,
          'totalBuyers': totalBuyers,
          'totalComplaints': totalComplaints,
        });
      }
    }

    controller = StreamController<Map<String, int>>(
      onListen: () {
        // 1. Sellers Stream
        subs.add(_firestore.collection('sellers').snapshots().listen((snapshot) {
          totalUmkm = snapshot.docs.where((doc) => doc.data()['status'] == 'Terverifikasi').length;
          pendingVerification = snapshot.docs.where((doc) => doc.data()['status'] == 'Menunggu').length;
          emitStats();
        }));

        // 2. Buyers Stream
        subs.add(_firestore.collection('users').where('role', isEqualTo: 'pembeli').snapshots().listen((snapshot) {
          totalBuyers = snapshot.docs.length;
          emitStats();
        }));

        // 3. Complaints Stream
        subs.add(_firestore.collection('complaints').snapshots().listen((snapshot) {
          totalComplaints = snapshot.docs.length;
          emitStats();
        }));
      },
      onCancel: () {
        for (var sub in subs) {
          sub.cancel();
        }
      },
    );

    return controller.stream;
  }

  // --- 6. ACTIVITY LOGS ---
  Future<void> logActivity(String text, String type) async {
    try {
      await _firestore.collection('activities').add({
        'text': text,
        'type': type, // 'success', 'warning', 'error', 'info'
        'timestamp': FieldValue.serverTimestamp(), // Use server timestamp for consistency
      });
    } catch (e) {
      debugPrint("Failed to log activity: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> getActivityLogsStream() {
    return _firestore
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(20) // Increased limit slightly
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id, // Added ID for deletion
          'text': data['text'] ?? '',
          'type': data['type'] ?? 'info',
          'time': _formatTimestamp(data['timestamp']),
          'fullTimestamp': data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString() : '',
        };
      }).toList();
    });
  }

  Future<void> deleteActivity(String docId) async {
    try {
      await _firestore.collection('activities').doc(docId).delete();
    } catch (e) {
      rethrow;
    }
  }
  
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  // --- 7. COMPLAINTS ---
  Stream<List<Map<String, dynamic>>> getComplaintsStream() {
    return _firestore
        .collection('complaints')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'uid': data['uid'] ?? '', // Sender UID
          'sender': data['sender'] ?? 'Unknown',
          'message': data['message'] ?? '',
          'date': _formatTimestamp(data['timestamp']),
          'status': data['status'] ?? 'Baru',
          'reply': data['reply'] ?? '',
        };
      }).toList();
    });
  }

  Future<void> markComplaintAsRead(String id) async {
    try {
      final doc = await _firestore.collection('complaints').doc(id).get();
      if (doc.exists && doc.data()!['status'] == 'Baru') {
        await _firestore.collection('complaints').doc(id).update({
          'status': 'Dibaca',
        });
      }
    } catch (e) {
      debugPrint("Error marking complaint as read: $e");
    }
  }

  Future<void> replyToComplaint(String id, String replyMessage, String userId, String senderName) async {
    try {
      // 1. Update Complaint Document
      await _firestore.collection('complaints').doc(id).update({
        'status': 'Dibalas',
        'reply': replyMessage,
        'replyTimestamp': FieldValue.serverTimestamp(),
      });

      // 2. Create Notification for User
      await _firestore.collection('notifications').add({
        'uid': userId,
        'title': 'Aduan Anda Dibalas',
        'message': 'Admin telah membalas aduan Anda: "$replyMessage"',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'complaint_reply',
      });

      // 3. Log Activity
      await logActivity('Membalas aduan dari $senderName', 'success');

    } catch (e) {
      debugPrint("Error replying to complaint: $e");
      rethrow;
    }
  }
}
