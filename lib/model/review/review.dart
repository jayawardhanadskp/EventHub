import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:eventhub/controller/image_pick_reg.dart';
import 'package:image_picker/image_picker.dart';

class ReviewPage extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final Map<String, dynamic> serviceProviderData;
  final String customerId;
  final String serviceProviderId;

  const ReviewPage({
    required this.bookingData,
    required this.serviceProviderData,
    required this.customerId,
    required this.serviceProviderId,
  });

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  TextEditingController _reviewController = TextEditingController();
  double _rating = 0.0;
  List<Uint8List?> _photos = [null];

  final FirebaseStorage _storage = FirebaseStorage.instance;

  void selectImage(int index) async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _photos[index] = img;
    });
  }

  Future<List<String>> uploadImagesToStorage(String uid, List<Uint8List?> files) async {
    List<String> downloadUrls = [];

    for (int i = 0; i < files.length; i++) {
      if (files[i] != null) {
        Reference ref = _storage.ref().child('review_photos').child(uid).child('reciew$i.jpg');
        UploadTask uploadTask = ref.putData(files[i]!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }
    }

    return downloadUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Service Provider: ${widget.serviceProviderData['name']}'),
              Text('Booked Plan: ${widget.bookingData['selectedPlan']}'),
              const SizedBox(height: 16),
              const Text('Rating:'),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
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
              const SizedBox(height: 16),
              TextField(
                controller: _reviewController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Leave a Review',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _submitReview();
                  Navigator.pop(context);
                },
                child: const Text('Submit Review'),
              ),
              const SizedBox(height: 16),
              _buildPhotosSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add Photos:'),
        Column(
          children: [
            for (int i = 0; i < _photos.length; i++)
              _buildPhotoContainer(i),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _photos.add(null);
            });
          },
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPhotoContainer(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 18.0),
              child: Row(
                children: [
                  Text("", style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    width: 120,
                    height: 140,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white60,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _photos[index] != null
                              ? Image.memory(_photos[index]!, fit: BoxFit.cover, width: 120, height: 140)
                              : Image.asset('assets/add_photo.jpg', fit: BoxFit.cover, width: 120, height: 140),
                        ),
                        Positioned(
                          bottom: -8,
                          left: 62,
                          child: IconButton(
                            onPressed: () => selectImage(index),
                            icon: const Icon(Icons.add_a_photo, color: Colors.black45, size: 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    try {
      List<String> photoUrls = await uploadImagesToStorage(widget.serviceProviderId, _photos);

      await FirebaseFirestore.instance.collection('reviews').add({
        'serviceProviderId': widget.serviceProviderId,
        'customerId': widget.customerId,
        'rating': _rating,
        'review': _reviewController.text,
        'photos': photoUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Review submitted successfully!'),
        duration: Duration(seconds: 2),
      ));
    } catch (error) {
      print('Error submitting review: $error');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error submitting review. Please try again.'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
