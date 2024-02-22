import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventhub/views/chat/massage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  ChatService() {
    _configureFirebaseMessaging();
    _retrieveDeviceToken();
  }

  Future<void> _retrieveDeviceToken() async {
    try {
      // retrieve the FCM  token
      String? token = await _firebaseMessaging.getToken();
      print("Device Token: $token");
    } catch (e) {
      print('Error retrieving device token: $e');
    }
  }



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

      // trigger local notification for a new message
      _showNotification(newMassage.senderEmail, newMassage.massage);
    } catch (e) {
      print('Error sending message: $e');
    }
  }


  Future<String> uploadImage(File imageFile) async {
    String fileName = const Uuid().v1();

    var ref = FirebaseStorage.instance.ref().child('chat_images').child('$fileName.jpg');
    var uploadTask = await ref.putFile(imageFile);

    // return the download URL
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


  Future<void> _showNotification(String sender, String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'EventHub',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'drawable/logo_',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'New Message from $sender',
      message,
      platformChannelSpecifics,
    );
  }



  Future<void> _configureFirebaseMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessageOpenedApp: $message");

      // extract receiverId from data
      String? reciverId = message.data['receiverId'];
      String? currentUserUid = _firebaseAuth.currentUser?.uid;

      // check current user is the receiver
      if (reciverId == currentUserUid) {
        _showNotification(
          message.notification?.title ?? "Default Title",
          message.notification?.body ?? "Default Body",
        );
      }
    });

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onResume: $message");
    });
  }





  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print("onLaunch: $message");
    _showNotification(message.data['senderEmail'], message.data['massage']);
  }


}
