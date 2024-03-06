import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                            offset: Offset(0, 3)
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingDetailsPage(
                                  bookingData: bookingData,
                                  customerData: customerData,
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

  const BookingDetailsPage({
    required this.bookingData,
    required this.customerData,
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.parse(widget.bookingData['selectedDay']);
    DateTime currentDate = DateTime.now();

    bool isDateInPast = selectedDate.isBefore(currentDate);
    bool isNextDay = selectedDate.isAtSameMomentAs(currentDate.add(Duration(days: 1)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Customer Name: ${widget.customerData['name']}'),
          Text('Selected Plan: ${widget.bookingData['selectedPlan']}'),
          Text('Selected Day: ${widget.bookingData['selectedDay']}'),
          Text('Selected Time: ${widget.bookingData['selectedTime']}'),
          Text('Address: ${widget.bookingData['address']}'),
          Text('Notes: ${widget.bookingData['notes'] ?? ''}'),
          Text('Status: ${widget.bookingData['status']}'),

          // Display the "Finish" button only if the selected day has passed and it's the next day
          if (isDateInPast && !isNextDay && widget.bookingData['status'] != 'finished') ...[
            ElevatedButton(
              onPressed: () async {
                String documentId = widget.bookingData['id'] ?? '';
                print('Document ID: $documentId');

                try {
                  // Get the reference to the document
                  DocumentReference bookingRef = FirebaseFirestore.instance.collection('bookings').doc(documentId);

                  // Update the 'status' field
                  await bookingRef.update({'status': 'finished'});

                  print('Booking status updated successfully.');
                } catch (e) {
                  print('Error updating booking status: $e');
                }

                Navigator.pop(context);
              },




              child: const Text('Finish'),
            ),

          ],
        ],
      ),
    );
  }
}

