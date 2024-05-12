import 'dart:io';

import 'package:eventhub/views/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'image_view_screen.dart';

class ChatPage extends StatefulWidget {


  final String reciverUserId;
  final String senderId;
  final String reciverName;
  final String picture;


  const ChatPage({Key? key,

    required this.reciverUserId,
    required this.senderId,
    required this.reciverName,
    required this.picture,

  })
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {


  // scrollController at the beginning
  final ScrollController _scrollController = ScrollController();


  final TextEditingController _massageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMassage() async {
    if (_massageController.text.isNotEmpty || imageFile != null) {
      await _chatService.sendMassage(
          widget.reciverUserId,
          _massageController.text,
          imageFile,
      );

      _massageController.clear();
      imageFile = null;
    }
  }

  // for send image
  File? imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
        sendMassage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = const Uuid().v1();

    var ref =
        FirebaseStorage.instance.ref().child('chat_images').child('$fileName.jpg');
    var uploadTask = await ref.putFile(imageFile!);

    String ImageUrl = await uploadTask.ref.getDownloadURL();

    print(ImageUrl);
  }

  @override
  Widget build(BuildContext context) {

    print("Receiver Name: ${widget.reciverName}");
    print("Picture: ${widget.picture}");

    return Scaffold(
      appBar: AppBar(
        title:Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.picture),
            ),
            const SizedBox(width: 10),
            Text(widget.reciverName),
          ],
        ),
      ),

      body: Column(
        children: [

          //massage
          Expanded(
              child: _buildMassageList(),
          ),

          //user input
          _buildMassageInput(),
        ],
      ),
    );
  }

  // build massage list
  Widget _buildMassageList() {
    return StreamBuilder(
      stream: _chatService.getMassages(
          widget.reciverUserId, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading');
        }

        // scroll to the bottom
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((document) => _buildMassageItem(document))
              .toList(),
        );
      },
    );
  }



  // build massage item
  Widget _buildMassageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    bool isSender = data['senderId'] == _firebaseAuth.currentUser!.uid;

    var alignment = isSender ? Alignment.centerRight : Alignment.centerLeft;
    var bgColor = isSender ? Colors.deepPurple : Colors.grey;

    DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
    String formattedTime = DateFormat.jm().add_yMd().format(timestamp);

    return GestureDetector(
      onTap: () {
        if (data['imageUrl'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewScreen(imageUrl: data['imageUrl']),
            ),
          );
        }
      },
      child: Container(
        alignment: alignment,
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data['imageUrl'] != null)
                Image.network(data['imageUrl'], width: 200, height: 200),
              if (data['massage'] != null)
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width / 1.5,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    data['massage'],
                    softWrap: true,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              const SizedBox(height: 5.0),
              Text(
                formattedTime,
                style: const TextStyle(color: Colors.grey, fontSize: 12.0),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // build massage input
  Widget _buildMassageInput() {
    return Column(
      children: [
        // priview selected image
        if (imageFile != null)
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            child: Image.file(imageFile!, width: 100, height: 100),
          ),

        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _massageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    obscureText: false,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: getImage,
              icon: const Icon(Icons.photo),
              color: Colors.blue,
            ),
            IconButton(
              onPressed: sendMassage,
              icon: const Icon(Icons.arrow_upward),
              color: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

}
