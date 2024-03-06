import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FinishedEventsCustomerPage extends StatefulWidget {
  @override
  _FinishedEventsCustomerPageState createState() =>
      _FinishedEventsCustomerPageState();
}

class _FinishedEventsCustomerPageState
    extends State<FinishedEventsCustomerPage> {
  late Stream<QuerySnapshot> _finishedEventsStream;

  @override
  void initState() {
    super.initState();

    var currentUserID = FirebaseAuth.instance.currentUser!.uid;

    _finishedEventsStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('customerId', isEqualTo: currentUserID)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finished Events'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _finishedEventsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }


          var finishedEvents = snapshot.data!.docs
              .where((event) {
            var eventDate =
            event['selectedDay'] as String;
            return DateTime.parse(eventDate).isBefore(DateTime.now());
          })
              .toList();

          if (finishedEvents.isEmpty) {
            return Center(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 100,),
                    Image.asset('assets/finishedevent.jpg', scale: 2,),
                    const SizedBox(height: 10,),
                    const Text('No finished events.', style: TextStyle(fontSize: 25, ),),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: finishedEvents.length,
            itemBuilder: (context, index) {
              var eventData =
              finishedEvents[index].data() as Map<String, dynamic>;
              var serviceProviderId = eventData['serviceproviderId'];
              var eventDate = DateTime.parse(eventData['selectedDay']);

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
                    subtitle: Text('Event Date: ${eventData['selectedDay']}'),

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
