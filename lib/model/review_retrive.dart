import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ServiceProviderReviewsPage extends StatefulWidget {
  final String serviceProviderId;

  const ServiceProviderReviewsPage({
    required this.serviceProviderId,
  });

  @override
  _ServiceProviderReviewsPageState createState() =>
      _ServiceProviderReviewsPageState();
}

class _ServiceProviderReviewsPageState
    extends State<ServiceProviderReviewsPage> {
  late Stream<QuerySnapshot> _reviewsStream;

  @override
  void initState() {
    super.initState();


    _reviewsStream = FirebaseFirestore.instance
        .collection('reviews')
        .where('serviceProviderId', isEqualTo: widget.serviceProviderId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Provider Reviews'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _reviewsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No reviews available.'),
            );
          }


          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var reviewData =
              snapshot.data!.docs[index].data() as Map<String, dynamic>;
              var customerId = reviewData['customerId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('customers')
                    .doc(customerId)
                    .get(),
                builder: (context, customerSnapshot) {
                  if (customerSnapshot.hasError) {
                    return Text(
                        'Error loading customer: ${customerSnapshot.error}');
                  }

                  if (customerSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  var customerData =
                  customerSnapshot.data?.data() as Map<String, dynamic>;
                  var customerName = customerData?['name'] ?? 'Unknown';
                  var customerPhoto = customerData?['photo'] ?? '';
                  var customerRating = reviewData['rating'].toDouble();

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(customerPhoto),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$customerName'),
                        RatingBar.builder(
                          initialRating: customerRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          ignoreGestures: true,
                          onRatingUpdate: (double value) {},
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Review: ${reviewData['review']}'),
                        _buildReviewPhotos(context, reviewData['photos'] ?? <String>[]),

                        const SizedBox(height: 10),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }


  Widget _buildReviewPhotos(BuildContext context, List<dynamic> photos) {
    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }

    List<String> photoUrls = List<String>.from(photos);

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: photoUrls.map((photoUrl) {
        return GestureDetector(
          onTap: () {
            _showFullScreenImage(context, photoUrl);
          },
          child: Hero(
            tag: photoUrl,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage(photoUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}


// show full screen photo
void _showFullScreenImage(BuildContext context, String photoUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: Hero(
            tag: photoUrl,
            child: Image.network(photoUrl),
          ),
        ),
      ),
    ),
  );
}

