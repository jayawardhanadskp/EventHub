import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventhub/views/chat/massage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMassage(String reciverId, String massage, File? imageFile) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // make chat room current user id & receiver id
    List<String> ids = [currentUserId, reciverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // create massage
    Massage newMassage = Massage(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: reciverId,
      massage: massage,
      timestamp: timestamp,
    );

    try {

      if (imageFile != null) {
        String imageUrl = await uploadImage(imageFile);
        newMassage.imageUrl = imageUrl;
      }

      // check chat room exists
      var chatRoomDoc = await _firestore.collection('chat_rooms').doc(chatRoomId).get();

      if (chatRoomDoc.exists) {
        // update existing chat room with new participants
        Set<String> existingParticipants = Set<String>.from(chatRoomDoc['participants']);
        existingParticipants.add(reciverId);

        await _firestore.collection('chat_rooms').doc(chatRoomId).update({
          'participants': existingParticipants.toList(),
        });
      } else {
        // create new chat room with participants
        await _firestore.collection('chat_rooms').doc(chatRoomId).set({
          'participants': ids,
        });
      }

      // add massage to database
      await _firestore.collection('chat_rooms').doc(chatRoomId).collection('massages').add(newMassage.toMap());
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<String> uploadImage(File imageFile) async {
    String fileName = const Uuid().v1();

    var ref = FirebaseStorage.instance.ref().child('chat_images').child('$fileName.jpg');
    var uploadTask = await ref.putFile(imageFile);

    // Return the download URL directly
    return await ref.getDownloadURL();
  }



  Stream<QuerySnapshot> getMassages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('massages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
