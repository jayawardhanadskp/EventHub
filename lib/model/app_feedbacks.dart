import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 0;
  List<File> _images = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _sendFeedback() async {
    final User? user = _auth.currentUser;
    if (user != null && _feedbackController.text.isNotEmpty) {
      try {
        List<String> imageUrls = [];

        // upload images to Firebase Storage
        for (File imageFile in _images) {
          String imageName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          Reference ref = FirebaseStorage.instance.ref().child('app_feedback_photos').child(imageName);
          await ref.putFile(imageFile);
          String imageUrl = await ref.getDownloadURL();
          imageUrls.add(imageUrl);
        }

        // save feedback details in Firestore
        await FirebaseFirestore.instance.collection('app_feedbacks').add({
          'userId': user.uid,
          'feedback': _feedbackController.text,
          'rating': _rating,
          'imageUrls': imageUrls,
          'timestamp': DateTime.now(),
          'status': 'waiting',
        });

        // clear the text field and images after sending feedback
        _feedbackController.clear();
        setState(() {
          _images = [];
        });

        // show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback sent successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (error) {
        // show error if feedback couldn't sent
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send feedback. Please try again later.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your feedback before sending.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(0.0),
              child: Text('Rate app', style: TextStyle(fontSize: 17, color: Colors.black54),),
            ),
            const SizedBox(height: 20,),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 40,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback here...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImage,
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(50, 50),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 10,),
                  Text('Add Feedback Image'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 150,
                      height: 150,
                      child: Image.file(
                        _images[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendFeedback,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                padding: const EdgeInsets.all(8.0),
                fixedSize: const Size(200, 60),
                textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                backgroundColor: Colors.deepPurple[400],
                foregroundColor: Colors.white,
                elevation: 10,
                shadowColor: Colors.blue.shade900,
              ),
              child: const Text('Send Feedback'),
            ),
            const SizedBox(height: 100,)
          ],
        ),
      ),
    );
  }
}
