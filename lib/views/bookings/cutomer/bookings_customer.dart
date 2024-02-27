import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/review.dart';

class CustomerBookingPage extends StatefulWidget {
  final String customerId;

  const CustomerBookingPage({
    required this.customerId,
  });

  @override
  _CustomerBookingPageState createState() => _CustomerBookingPageState();
}

class _CustomerBookingPageState extends State<CustomerBookingPage> {
  late Stream<QuerySnapshot> _customerBookingsStream;

  @override
  void initState() {
    super.initState();

    _customerBookingsStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('customerId', isEqualTo: widget.customerId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Bookings'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _customerBookingsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('You have no bookings.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var bookingData =
              snapshot.data!.docs[index].data() as Map<String, dynamic>;
              var serviceProviderId = bookingData['serviceproviderId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('service_providers')
                    .doc(serviceProviderId)
                    .get(),
                builder: (context, serviceProviderSnapshot) {
                  if (serviceProviderSnapshot.hasError) {
                    return Text(
                        'Error loading service provider: ${serviceProviderSnapshot.error}');
                  }

                  if (serviceProviderSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  var serviceProviderData =
                  serviceProviderSnapshot.data?.data() as Map<String, dynamic>;

                  var serviceProviderBuisnessName =
                      serviceProviderData?['business_Name'] ?? 'Unknown';
                  var serviceProviderPhoto = serviceProviderData?['photo'] ?? '';
                  var bookedPlan = bookingData['selectedPlan'] ?? 'Unknown';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(serviceProviderPhoto),
                    ),
                    title: Text('$serviceProviderBuisnessName'),
                    subtitle: Text('Booked Plan: $bookedPlan'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerBookingDetailsPage(
                            bookingData: bookingData,
                            serviceProviderData: serviceProviderData,
                            serviceProviderId: serviceProviderId,
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

class CustomerBookingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> bookingData;
  final Map<String, dynamic> serviceProviderData;
  final String serviceProviderId;

  const CustomerBookingDetailsPage({
    required this.bookingData,
    required this.serviceProviderData,
    required this.serviceProviderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service Provider: ${serviceProviderData['name']}'),
          Text('Booked Plan: ${bookingData['selectedPlan']}'),
          Text('Selected Day: ${bookingData['selectedDay'] ?? 'Unknown'}'),
          Text('Selected Time: ${bookingData['selectedTime'] ?? 'Unknown'}'),
          Text('Address: ${bookingData['address'] ?? 'Unknown'}'),
          Text('Notes: ${bookingData['notes'] ?? 'Unknown'}'),
          Text('Status: ${bookingData['status'] ?? 'Unknown'}'),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewPage(
                    bookingData: bookingData,
                    serviceProviderData: serviceProviderData,
                    customerId: FirebaseAuth.instance.currentUser!.uid,
                    serviceProviderId: serviceProviderId,
                  ),
                ),
              );
            },
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }
}
