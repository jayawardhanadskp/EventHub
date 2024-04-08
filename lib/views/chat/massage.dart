import 'package:cloud_firestore/cloud_firestore.dart';
class Massage {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String massage;
  final Timestamp timestamp;
  String? imageUrl;
  bool seen;

  Massage({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.massage,
    required this.timestamp,
    this.imageUrl,
    this.seen = false,
  });

  // convert to map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail' : senderEmail,
      'receiverId' : receiverId,
      'massage' : massage,
      'timestamp' : timestamp,
      'imageUrl' : imageUrl,
      'seen': seen,
    };
  }
}