import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ServiceProviderBookingPage extends StatefulWidget {
  final String serviceProviderId;

  const ServiceProviderBookingPage({
    required this.serviceProviderId,
  });

  @override
  _ServiceProviderBookingPageState createState() =>
      _ServiceProviderBookingPageState();
}

class _ServiceProviderBookingPageState
    extends State<ServiceProviderBookingPage> {
  late Stream<QuerySnapshot> _bookingsStream;

  @override
  void initState() {
    super.initState();


    _bookingsStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('serviceproviderId', isEqualTo: widget.serviceProviderId)

        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child:  Text('My Bookings')),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _bookingsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }


          if (snapshot.data!.docs.isEmpty) {
            return  Center(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 100,),
                    Image.asset('assets/nobookings.png', scale: 2,),
                    const SizedBox(height: 10,),
                    const Text('You have no bookings.', style: TextStyle(fontSize: 25, ),),
                  ],
                ),
              ),
            );
          }


          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var bookingData =
              snapshot.data!.docs[index].data() as Map<String, dynamic>;
              var customerId = bookingData['customerId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('customers')
                    .doc(customerId)
                    .get(),
                builder: (context, customerSnapshot) {
                  if (customerSnapshot.hasError) {
                    return Text('Error loading customer: ${customerSnapshot.error}');
                  }

                  if (customerSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  var customerData = customerSnapshot.data!.data() as Map<String, dynamic>;

                  return Padding(
                    padding: const EdgeInsets.only(left: 15.0,right: 15.0,top: 10.0,bottom: 10.0,),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3)
                          )
                        ]
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(customerData['photo'] ?? ''),
                          ),
                          title: Text('Customer Name: ${customerData['name']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Selected Plan: ${bookingData['selectedPlan']}'),
                              Text('Date: ${bookingData['selectedDay']}')
                            ],
                          ),
                          trailing: Text('${bookingData['status']}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingDetailsPage(
                                  bookingData: bookingData,
                                  customerData: customerData,
                                  bookingId: snapshot.data!.docs[index].id,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
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
}


class BookingDetailsPage extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final Map<String, dynamic> customerData;
  final String bookingId;

  const BookingDetailsPage({
    required this.bookingData,
    required this.customerData,
    required this.bookingId,
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  @override
  Widget build(BuildContext context) {
    DateTime selectedDate =
    DateTime.parse(widget.bookingData['selectedDay']);
    DateTime currentDate = DateTime.now();

    bool isDateInPast = selectedDate.isBefore(currentDate);
    bool isNextDay =
    selectedDate.isAtSameMomentAs(currentDate.add(const Duration(days: 1)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.deepPurple),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54.withOpacity(0.4),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text('Status '),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, left: 8.0, right: 8.0),
                                  child: Text(
                                    '${widget.bookingData['status']}',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                // display "Finish" button only if the selected day has passed and it's the next day
                                if (isDateInPast &&
                                    !isNextDay &&
                                    widget.bookingData['status'] !=
                                        'finished') ...[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0, bottom: 8.0),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        String documentId = widget.bookingId;
                                        print('Document ID: $documentId');

                                        try {
                                          // get reference to document
                                          DocumentReference bookingRef =
                                          FirebaseFirestore.instance
                                              .collection('bookings')
                                              .doc(documentId);

                                          // update the 'status' field
                                          await bookingRef
                                              .update({'status': 'finished'});

                                          print(
                                              'Booking status updated successfully.');
                                        } catch (e) {
                                          print(
                                              'Error updating booking status: $e');
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(5.0),
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        fixedSize: const Size(75, 30),
                                        textStyle: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        backgroundColor:
                                        Colors.deepPurple[400],
                                        foregroundColor: Colors.white,
                                        elevation: 10,
                                        shadowColor: Colors.blue.shade900,
                                      ),
                                      child: const Text('Finish'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Customer Name',
                                style: TextStyle(color: Colors.black45)),
                            Text('${widget.customerData['name']}',
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 7),
                            const Text('Selected Plan',
                                style: TextStyle(color: Colors.black45)),
                            Text('${widget.bookingData['selectedPlan']}',
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 7),
                            const Text('Date',
                                style: TextStyle(color: Colors.black45)),
                            Text('${widget.bookingData['selectedDay']}',
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 7),
                            const Text('Time',
                                style: TextStyle(color: Colors.black45)),
                            Text('${widget.bookingData['selectedTime']}',
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 7),
                            const Text('Address',
                                style: TextStyle(color: Colors.black45)),
                            Text('${widget.bookingData['address']}',
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 7),
                            const Text('Notes',
                                style: TextStyle(color: Colors.black45)),
                            Text('${widget.bookingData['notes'] ?? ''}',
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Reviews',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('reviews')
                              .where('bookingId', isEqualTo: widget.bookingId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text('No reviews available'),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
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
                                    customerSnapshot.data!.data() as Map<String, dynamic>;
                                    var customerName =
                                        customerData['name'] ?? 'Unknown';
                                    var customerPhoto =
                                        customerData['photo'] ?? '';
                                    var customerRating =
                                    reviewData['rating'].toDouble();

                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(customerPhoto),
                                      ),
                                      title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(customerName),
                                          RatingBar.builder(
                                            initialRating: customerRating,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemSize: 20,
                                            itemPadding:
                                            const EdgeInsets.symmetric(horizontal: 2.0),
                                            itemBuilder: (context, _) => const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (double value) {},
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Review: ${reviewData['review']}'),
                                          _buildReviewPhotos(
                                              context, reviewData['photos'] ?? <String>[]),
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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