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
        title: const Text('Service Provider Bookings'),
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
            return const Center(
              child: Text('No bookings available.'),
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

                  return ListTile(
                    leading: CircleAvatar(

                      backgroundImage: NetworkImage(customerData['photo']),
                    ),
                    title: Text('Customer Name: ${customerData['name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selected Plan: ${bookingData['selectedPlan']}'),

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


class BookingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> bookingData;
  final Map<String, dynamic> customerData;

  const BookingDetailsPage({
    required this.bookingData,
    required this.customerData,
  });

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.parse(bookingData['selectedDay']);
    DateTime currentDate = DateTime.now();

    bool isDateInPast = selectedDate.isBefore(currentDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Customer Name: ${customerData['name']}'),
          Text('Selected Plan: ${bookingData['selectedPlan']}'),
          Text('Selected Day: ${bookingData['selectedDay']}'),
          Text('Selected Time: ${bookingData['selectedTime']}'),
          Text('Address: ${bookingData['address']}'),
          Text('Notes: ${bookingData['notes']}'),
          if (isDateInPast)
            ElevatedButton(
              onPressed: () {

                FirebaseFirestore.instance
                    .collection('bookings')
                    .doc(bookingData['bookingId']) // Replace 'bookingId' with your actual field name
                    .update({'status': 'success'});
              },
              child: const Text('Done'),
            )
          else
            Text('Status: ${bookingData['status'] ?? 'Unknown'}'),
        ],
      ),
    );
  }
}

