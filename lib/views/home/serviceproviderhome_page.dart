import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../events/serviceprovider/events.dart';
import '../onbord_screen.dart';

class HomePageServiceprovider extends StatefulWidget {
  const HomePageServiceprovider({Key? key});

  @override
  State<HomePageServiceprovider> createState() =>
      _HomePageServiceproviderState();
}

class _HomePageServiceproviderState extends State<HomePageServiceprovider> {
  Map<String, dynamic>? serviceProviderData;

  // for calendar
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  // store events from calendar
  Map<DateTime, List<Event>> events = {};
  TextEditingController _eventController = TextEditingController();


  // user initialization for get events
  late User? _user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  // function to calculate average rating
  Future<double> _calculateAverageRating() async {
    QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('serviceProviderId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (reviewsSnapshot.docs.isNotEmpty) {
      double totalRating = 0;
      for (var review in reviewsSnapshot.docs) {
        totalRating += (review['rating'] as num).toDouble();
      }

      return totalRating / reviewsSnapshot.docs.length;
    } else {
      return 0.0;
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.deepPurple[600],
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Row(
                      children: [
                        FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance
                              .collection('service_providers')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              serviceProviderData = snapshot.data!.data();
                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(
                                      serviceProviderData?['photo'] as String? ?? '',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Hey ${serviceProviderData?['name'] ?? ''}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },

                        ),

                      ],
                    ),



                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const OnbordScreen()));
                    },
                    alignment: Alignment.topRight,
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upcoming Event',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceProviderEventsPage(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.4),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Take a look at upcoming events',
                                style: TextStyle(fontSize: 18),
                              ),
                              Icon(Icons.arrow_forward, size: 25,)
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            ' ',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          const Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: Text(
              'Your Calender',
              style: TextStyle(
                fontSize: 18,
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
                    color: Colors.deepPurple.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TableCalendar(
                  locale: "en_US",
                  rowHeight: 50,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  availableGestures: AvailableGestures.all,
                  selectedDayPredicate: (day) => isSameDay(day, _focusedDay),
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2024, 2, 1),
                  lastDay: DateTime.utc(2030, 3, 14),
                  onDaySelected: _onDaySelected,
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.deepPurple[400],
                    ),
                    selectedTextStyle: const TextStyle(color: Colors.white),
                    todayDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.deepPurple[100],
                    ),
                    todayTextStyle: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 0,),

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 5
                  )
                ]
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        // display select day
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Selected Day : ${DateFormat('yyyy-MM-dd').format(_focusedDay)}",
                            style: const TextStyle(fontSize: 17, color: Colors.black87), ),
                        ),
                        const SizedBox(width: 20,),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FloatingActionButton(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    scrollable: true,
                                    title: const Text('Enter Event'),
                                    content: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: _eventController,
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (_selectedDay != null) {
                                            // Add the event to the calendar map
                                            events.update(
                                              _selectedDay!,
                                                  (eventsList) {
                                                eventsList.add(Event(_eventController.text));
                                                return eventsList;
                                              },
                                              ifAbsent: () => [Event(_eventController.text)],
                                            );


                                            // convert events map to a JSON-serializable format
                                            Map<String, dynamic> eventsJson = {};
                                            events.forEach((key, value) {
                                              eventsJson[key.toIso8601String()] =
                                                  value.map((event) => event.toJson()).toList();
                                            });

                                            // update firestore collection
                                            await FirebaseFirestore.instance
                                                .collection('service_providers')
                                                .doc(_user?.uid)
                                                .update({'events': eventsJson});

                                            Navigator.pop(context); // Close the dialog

                                            _eventController.clear();
                                          }
                                        },
                                        child: const Text('Submit'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        // display events for the selected day retrieving from Firebase
                        if (_selectedDay != null) FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance
                              .collection('service_providers')
                              .doc(_user?.uid)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              // loading
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              // error state
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              Map<String, dynamic>? serviceProviderData = snapshot.data!.data();

                              if (serviceProviderData != null &&
                                  serviceProviderData['events'] != null) {
                                Map<String, dynamic> eventsData = Map<String, dynamic>.from(serviceProviderData['events']);

                                // get events for the selected day
                                List<Event> selectedDayEvents = [];
                                String selectedDayString = _selectedDay!.toIso8601String();

                                if (eventsData.containsKey(selectedDayString)) {
                                  List<dynamic> eventsList = eventsData[selectedDayString];
                                  selectedDayEvents = eventsList.map((event) {
                                    return Event(event['title']);
                                  }).toList();
                                }

                                // display events
                                if (selectedDayEvents.isNotEmpty) {
                                  return Column(
                                    children: [
                                      Text(
                                        "Events for ${DateFormat('yyyy-MM-dd').format(_selectedDay!)}",
                                        style: const TextStyle(fontSize: 17),
                                      ),
                                      ...selectedDayEvents.map((event) => Text(event.title,
                                        style: const TextStyle(fontSize: 17),
                                      )),
                                    ],
                                  );
                                } else {
                                  return const Text('No events for the selected day.');
                                }
                              } else {
                                return const Text('No events data available.');
                              }
                            } else {
                              return const Text('No data');
                            }
                          },
                        ),

                        const SizedBox(height: 10,),

                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10,),
          const Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: Text(
              'Your Rating',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10,),
          FutureBuilder<double>(
            future: _calculateAverageRating(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                // Display the average rating using RatingBar
                double averageRating = snapshot.data ?? 0.0;
                String formattedRating = averageRating.toStringAsFixed(2);


                return ListTile(
                  title: Center(child: Text('Average Rating $formattedRating'
                    ,style: const TextStyle(color: Colors.black45),
                  ),
                  ),

                  subtitle: Center(
                    child: RatingBar.builder(
                      initialRating: averageRating,
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
                  ),
                  onTap: () {

                  },
                );
              }
            },
          ),

        ],
      ),
    );
  }
}


class Event {
  final String title;

  Event(this.title);

  // Convert Event to JSON format
  Map<String, dynamic> toJson() {
    return {
      'title': title,
    };
  }
}