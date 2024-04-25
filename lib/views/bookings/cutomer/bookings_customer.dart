import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/review/review.dart';

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
        .orderBy('timestamp', descending: true)
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
                      serviceProviderData?['business_Name'] ?? '';
                  var serviceProviderPhoto = serviceProviderData?['photo'] ?? '';
                  var bookedPlan = bookingData['selectedPlan'] ?? '';
                  var bookedDate = bookingData['selectedDay'] ?? '';
                  var status = bookingData['status'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(serviceProviderPhoto),
                        ),
                        title: Text('$serviceProviderBuisnessName'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Booked Plan: $bookedPlan'),
                            Text('Booked Date: $bookedDate')
                          ],
                        ),
                        trailing: Text('$status', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerBookingDetailsPage(
                                bookingData: bookingData,
                                serviceProviderData: serviceProviderData,
                                serviceProviderId: serviceProviderId,
                                bookingId: snapshot.data!.docs[index].id,
                              ),
                            ),
                          );
                        },
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

class CustomerBookingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> bookingData;
  final Map<String, dynamic> serviceProviderData;
  final String serviceProviderId;
  final String bookingId;

  const CustomerBookingDetailsPage({
    required this.bookingData,
    required this.serviceProviderData,
    required this.serviceProviderId,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: Padding(
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
                            color: Colors.deepPurple,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text('Status ', style: TextStyle(color: Colors.white),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8.0, left: 8.0, right: 8.0),
                                child: Text(
                                  '${bookingData['status']}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),

                                ),
                              ),
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
                          const Text('Service Provider',
                              style: TextStyle(color: Colors.black45)),
                          Text('${serviceProviderData['business_Name']}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 7),
                          const Text('Selected Plan',
                              style: TextStyle(color: Colors.black45)),
                          Text('${bookingData['selectedPlan']}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 7),
                          const Text('Date',
                              style: TextStyle(color: Colors.black45)),
                          Text('${bookingData['selectedDay']}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 7),
                          const Text('Time',
                              style: TextStyle(color: Colors.black45)),
                          Text('${bookingData['selectedTime']}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 7),
                          const Text('Address',
                              style: TextStyle(color: Colors.black45)),
                          Text('${bookingData['address']}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 7),
                          const Text('Notes',
                              style: TextStyle(color: Colors.black45)),
                          Text('${bookingData['notes'] ?? ''}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 7),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewPage(
                            bookingData: bookingData,
                            serviceProviderData: serviceProviderData,
                            customerId: FirebaseAuth.instance.currentUser!.uid,
                            serviceProviderId: serviceProviderId,
                            bookingId: bookingId,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),

                      fixedSize: const Size(150, 55),
                      textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black54,
                      elevation: 10,
                      shadowColor: Colors.blue.shade900,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow,),
                        SizedBox(width: 5,),
                        Text('Review'),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
