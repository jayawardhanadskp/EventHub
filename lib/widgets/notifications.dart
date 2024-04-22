import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('admin_messages')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          var messages = snapshot.data!.docs;

          if (messages.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Lottie.network('https://lottie.host/fe045f10-9a0a-49c3-bd79-b5c6ff096869/4IIJ7X6Y4B.json'),
                  Text('No notifications', style: TextStyle(fontSize: 28, color: Colors.black45),),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var message = messages[index];
              var messageText = message['message'];
              var timestamp = message['timestamp'] as Timestamp;


              var dateTime = timestamp.toDate();

              return Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 15, left: 15),
                child: Container(
                  color: Colors.deepPurple[50],
                  child: ListTile(
                    title: Text(messageText),
                    subtitle: Text(_formatDateTime(dateTime)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }
}
