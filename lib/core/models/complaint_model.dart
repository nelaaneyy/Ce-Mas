import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String id;
  final String uid; // Sender UID
  final String senderName; // Email or Name
  final String message;
  final DateTime? timestamp;
  final String status; // 'Baru', 'Diproses', 'Selesai'

  ComplaintModel({
    this.id = '',
    required this.uid,
    required this.senderName,
    required this.message,
    this.timestamp,
    this.status = 'Baru',
  });

  factory ComplaintModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ComplaintModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      senderName: data['sender'] ?? 'Anonim',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'Baru',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'sender': senderName,
      'message': message,
      'timestamp': timestamp,
      'status': status,
    };
  }
}
