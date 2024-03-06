import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServiceProviderEventsPage extends StatefulWidget {
  @override
  _ServiceProviderEventsPageState createState() =>
      _ServiceProviderEventsPageState();
}

class _ServiceProviderEventsPageState
    extends State<ServiceProviderEventsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: const Text('My Events')),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming Events'),
              Tab(text: 'Finished Events'),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: TabBarView(
          children: [
            UpcomingEventsServiceProviderPage(),
            FinishedEventsServiceProviderPage(),
          ],
        ),
      ),
    );
  }
}



class UpcomingEventsServiceProviderPage extends StatefulWidget {
  @override
  _UpcomingEventsServiceProviderPageState createState() =>
      _UpcomingEventsServiceProviderPageState();
}

class _UpcomingEventsServiceProviderPageState
    extends State<UpcomingEventsServiceProviderPage> {
  late Stream<QuerySnapshot> _upcomingEventsStream;

  @override
  void initState() {
    super.initState();

    var currentServiceProviderID =
        FirebaseAuth.instance.currentUser!.uid;

    _upcomingEventsStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('serviceproviderId', isEqualTo: currentServiceProviderID)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
            event['selectedDay'] as String; // Adjust the field name
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
                    const Text('No upcoming events', style: TextStyle(fontSize: 25, ),),
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
              var customerId = eventData['customerId'];

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

                  return ListTile(
                    title: Text('Customer: $customerName'),
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


class FinishedEventsServiceProviderPage extends StatefulWidget {
  @override
  _FinishedEventsServiceProviderPageState createState() =>
      _FinishedEventsServiceProviderPageState();
}

class _FinishedEventsServiceProviderPageState
    extends State<FinishedEventsServiceProviderPage> {
  late Stream<QuerySnapshot> _finishedEventsStream;

  @override
  void initState() {
    super.initState();

    var currentServiceProviderID =
        FirebaseAuth.instance.currentUser!.uid;

    _finishedEventsStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('serviceproviderId', isEqualTo: currentServiceProviderID)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
            return  Center(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 100,),
                    Image.asset('assets/finishedevent.jpg', scale: 2,),
                    const SizedBox(height: 10,),
                    const Text('No finished events', style: TextStyle(fontSize: 25, ),),
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
              var customerId = eventData['customerId'];

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

                  return ListTile(
                    title: Text('Customer: $customerName'),
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
