import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventhub/views/chat/chat_page.dart';

class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>?> _getUserData(String userId) async {
    try {
      // find the user is customer or service_provider
      String collectionName = '';

      // check user is customer
      DocumentSnapshot<Map<String, dynamic>> customerSnapshot = await _firestore.collection('customers').doc(userId).get();
      if (customerSnapshot.exists) {
        collectionName = 'customers';
      }

      // if not customer, check if user is service provider
      if (collectionName.isEmpty) {
        DocumentSnapshot<Map<String, dynamic>> serviceProviderSnapshot = await _firestore.collection('service_providers').doc(userId).get();
        if (serviceProviderSnapshot.exists) {
          collectionName = 'service_providers';
        }
      }

      if (collectionName.isNotEmpty) {
        // get user data from collection
        DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore.collection(collectionName).doc(userId).get();
        if (snapshot.exists) {
          print('User data found for user ID $userId');
          return snapshot;
        } else {
          print('User data not found for user ID $userId');

          return null;
        }
      } else {
        print('User ID $userId not found in any collection');
        return null;
      }
    } catch (error) {
      print('Error fetching user data for user ID $userId: $error');
     
      return null;
    }
  }


  Widget _buildChatItem(QueryDocumentSnapshot room) {
    List<String> participants = List<String>.from(room['participants']);
    participants.remove(_firebaseAuth.currentUser!.uid);

    String chatRoomId = participants.join("_");

    print('Participants: $participants');
    print('Chat Room ID: $chatRoomId');

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>?>?>(
      future: _getUserData(participants.first),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          print('Error fetching user data: ${snapshot.error}');
          return const SizedBox.shrink();
        }

        DocumentSnapshot<Map<String, dynamic>?>? userDataSnapshot = snapshot.data;

        if (userDataSnapshot == null || !userDataSnapshot.exists) {
          print('User data is null or does not exist for user ID ${participants.first}');
          return const SizedBox.shrink();
        }

        Map<String, dynamic>? userData = userDataSnapshot.data();
        if (userData == null) {
          print('User data is null for user ID ${participants.first}');
          return const SizedBox.shrink();
        }

        print('User Data: $userData');

        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  reciverUserId: participants.first,
                  senderId: _firebaseAuth.currentUser!.uid,
                  picture: userData['photo'] ?? '',
                  reciverName: userData['name'] ?? 'Unknown',
                ),
              ),
            );
          },
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(userData['photo'] ?? ''),
          ),
          title: Text(userData['name'] ?? 'Unknown'),
          subtitle: const Text('Last message goes here'),
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chat_rooms')
            .where('participants', arrayContains: _firebaseAuth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<QueryDocumentSnapshot> rooms = snapshot.data!.docs;
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              return _buildChatItem(rooms[index]);
            },
          );
        },
      ),
    );
  }
}
