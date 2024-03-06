import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpcomingEventCustomerPage extends StatefulWidget {
  @override
  _UpcomingEventCustomerPageState createState() =>
      _UpcomingEventCustomerPageState();
}

class _UpcomingEventCustomerPageState
    extends State<UpcomingEventCustomerPage> {
  late Stream<QuerySnapshot> _upcomingEventsStream;

  @override
  void initState() {
    super.initState();

    var currentUserID = FirebaseAuth.instance.currentUser!.uid;

    _upcomingEventsStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('customerId', isEqualTo: currentUserID)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _upcomingEventsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }


          var upcomingEvents = snapshot.data!.docs
              .where((event) {
            var eventDate =
            event['selectedDay'] as String;
            return DateTime.parse(eventDate).isAfter(DateTime.now());
          })
              .toList();

          if (upcomingEvents.isEmpty) {
            return Center(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 100,),
                    Image.asset('assets/upcomingevent.jpg', scale: 2,),
                    const SizedBox(height: 10,),
                    const Text('No upcoming events.', style: TextStyle(fontSize: 25, ),),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: upcomingEvents.length,
            itemBuilder: (context, index) {
              var eventData =
              upcomingEvents[index].data() as Map<String, dynamic>;
              var serviceProviderId = eventData['serviceproviderId'];
              var eventDate = DateTime.parse(eventData['selectedDay']);

              var remainingDays =
                  eventDate.difference(DateTime.now()).inDays;

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
                  var serviceProviderName =
                      serviceProviderData?['name'] ?? 'Unknown';

                  return ListTile(
                    title: Text('Service Provider: $serviceProviderName'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Event Date: ${eventData['selectedDay']}'),
                        Text('Remaining Days: $remainingDays'),
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
}
