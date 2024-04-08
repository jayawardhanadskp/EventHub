import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ApprovedFeedbackPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('app_feedbacks').where('status', isEqualTo: 'approved').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            var feedbackDocs = snapshot.data!.docs;
            return Row(
              children: feedbackDocs.map((feedbackDoc) {
                var feedback = feedbackDoc.data() as Map<String, dynamic>;
                var userId = feedback['userId'];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('customers').doc(userId).get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: 200, // Set a fixed width for each feedback card
                        child: ListTile(
                          title: Text('Loading...'),
                        ),
                      );
                    }
                    if (!userSnapshot.hasData) {
                      return Container(
                        width: 200, // Set a fixed width for each feedback card
                        child: ListTile(
                          title: Text('Unknown'),
                        ),
                      );
                    }
                    var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    var customerName = userData['name'];
                    var customerPhoto = userData['photo'];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(

                        color: Colors.white,
                        width: 250,
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(customerPhoto),
                                ),
                                SizedBox(width: 10,),
                                Text('$customerName', style: TextStyle(fontSize: 17),),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 50),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${ feedback['feedback']}', style: TextStyle(fontSize: 17),),
                                  SizedBox(height: 10,),
                                  RatingBarIndicator(
                                    rating: feedback['rating'] != null ? feedback['rating'].toDouble() : 0.0,
                                    itemBuilder: (context, index) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 30.0,
                                    unratedColor: Colors.grey[300]!,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
