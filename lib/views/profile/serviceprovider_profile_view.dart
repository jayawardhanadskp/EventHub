import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../model/review/review_retrive.dart';
import '../bookings/booking.dart';
import '../chat/chat_page.dart';

class ServiceProviderProfileView extends StatefulWidget {
  final String userId;

  const ServiceProviderProfileView({Key? key, required this.userId})
      : super(key: key);

  @override
  _ServiceProviderProfileViewState createState() =>
      _ServiceProviderProfileViewState();
}

class _ServiceProviderProfileViewState extends State<ServiceProviderProfileView>
    with TickerProviderStateMixin {
  // for photos
  final PageController _pageController = PageController();
  int _currentPage = 0;

  //for pricing tabs
  late TabController _tabController;

  // Track favorite state
  bool isFavorite = false;

  //  variable as class-level for send to chat page
  List<String> photoUrls = [];
  Map<String, dynamic>? serviceProviderData;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    // get calendar
    _fetchEventsFromFirestore();
    super.initState();
    // check if the current user has this provider in favorites
    checkFavoriteStatus();
  }

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

  // for calendar view get from firebase
  Map<DateTime, List<Event>> events = {};

  Future<void> _fetchEventsFromFirestore() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('service_providers')
        .doc(widget.userId)
        .get();

    Map<String, dynamic>? data = snapshot.data();
    if (data != null && data['events'] != null) {
      Map<String, dynamic> eventsData =
          Map<String, dynamic>.from(data['events']);
      events = eventsData.map((key, value) {
        DateTime date = DateTime.parse(key);
        List<Event> eventList = (value as List<dynamic>).map((event) {
          return Event(event['title']);
        }).toList();
        return MapEntry(date, eventList);
      });
    }
  }

  Future<void> checkFavoriteStatus() async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      var currentUser = _auth.currentUser;

      if (currentUser != null) {
        DocumentSnapshot<Object?> userDocument = await FirebaseFirestore
            .instance
            .collection('customers')
            .doc(currentUser.uid)
            .get();

        if (userDocument.exists) {
          List<String> favorites =
              List<String>.from(userDocument['favorites'] ?? []);
          setState(() {
            isFavorite = favorites.contains(widget.userId);
          });
        }
      }
    } catch (error) {
      print('Error checking favorite status: $error');
    }
  }

  Future<void> addToFavorite() async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      var currentUser = _auth.currentUser;

      if (currentUser != null) {
        CollectionReference _collectionRef =
            FirebaseFirestore.instance.collection('customers');

        // check if the document exists before updating
        DocumentSnapshot<Object?> userDocument =
            await _collectionRef.doc(currentUser.uid).get();

        if (userDocument.exists) {
          // document exists, update the 'favorites' field
          await _collectionRef.doc(currentUser.uid).update({
            'favorites': FieldValue.arrayUnion([widget.userId]),
          });
        } else {
          // document doesn't exist, create 'favorites' field
          await _collectionRef.doc(currentUser.uid).set({
            'favorites': [widget.userId],
          });
        }

        setState(() {
          isFavorite = true;
        });

        // show a popup animation
        _showFavoriteAnimation('Added to favorites!');
      } else {
        print('User not authenticated');
      }
    } catch (error) {
      print('Error adding to favorites: $error');
    }
  }

  Future<void> removeFromFavorite() async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      var currentUser = _auth.currentUser;

      if (currentUser != null) {
        CollectionReference _collectionRef =
            FirebaseFirestore.instance.collection('customers');

        // check if the document exists before updating
        DocumentSnapshot<Object?> userDocument =
            await _collectionRef.doc(currentUser.uid).get();

        if (userDocument.exists) {
          // document exists, update the 'favorites' field
          await _collectionRef.doc(currentUser.uid).update({
            'favorites': FieldValue.arrayRemove([widget.userId]),
          });
        }

        setState(() {
          isFavorite = false;
        });

        // Show a popup animation
        _showFavoriteAnimation('Removed from favorites!');
      } else {
        print('User not authenticated');
      }
    } catch (error) {
      print('Error removing from favorites: $error');
    }
  }

  // Show a popup animation when adding to favorites
  void _showFavoriteAnimation(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // function to calculate average rating
  Future<double> _calculateAverageRating() async {
    QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('serviceProviderId', isEqualTo: widget.userId)
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
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Stack(
        children: [
          SingleChildScrollView(
            child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('service_providers')
                  .doc(widget.userId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  Map<String, dynamic>? serviceProviderData =
                      snapshot.data!.data();
                  List<String> photoUrls =
                      List<String>.from(serviceProviderData?['photos'] ?? []);



                  return Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Stack(
                            children: [
                              Container(
                                height: 320,
                                child: Stack(
                                  children: [
                                    PageView.builder(
                                      controller: _pageController,
                                      itemCount: photoUrls.length,
                                      itemBuilder: (context, index) {
                                        return Image.network(
                                          photoUrls[index],
                                          fit: BoxFit.cover,
                                        );
                                      },
                                      onPageChanged: (index) {
                                        setState(() {
                                          _currentPage = index;
                                        });
                                      },
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: Text(
                                        "${_currentPage + 1}/${photoUrls.length}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 18,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back_sharp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 30,
                                right: 15,
                                child: GestureDetector(
                                  onTap: () {
                                    if (isFavorite) {
                                      removeFromFavorite();
                                    } else {
                                      addToFavorite();
                                    }
                                  },
                                  child: FavoriteButton(
                                    isFavorite: isFavorite,
                                    valueChanged: (isFavorite) {
                                      if (isFavorite) {
                                        addToFavorite();
                                      } else {
                                        removeFromFavorite();
                                      }
                                    },
                                    iconDisabledColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 90,
                          width: double.infinity,
                          color: Colors.deepPurple[300],
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                      photoUrls.isNotEmpty ? photoUrls[0] : ''),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Owner  ',
                                          style: TextStyle(
                                              color: Colors.white60, fontSize: 17),
                                        ),
                                        Text(
                                          ' ${serviceProviderData?['name']}',
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 17),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Service  ',
                                          style: TextStyle(
                                              color: Colors.white60, fontSize: 17),
                                        ),
                                        Text(
                                          '${serviceProviderData?['service']}',
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 17),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          color: Colors.deepPurple[50],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(

                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text(
                                          ' ${serviceProviderData?['business_Name']}',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        '  Description: ',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      const SizedBox(height: 7,),
                                      Text(
                                        ' ${serviceProviderData?['description'] ?? 'Not Added'}',
                                        style: const TextStyle(
                                            fontSize: 17,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Divider(
                                  thickness: 2,
                                  color: Colors.deepPurple[400],
                                ),
                                Container(
                                  height: 200,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: TabBar(
                                          controller: _tabController,
                                          labelColor: Colors.deepPurple,
                                          unselectedLabelColor: Colors.black87,
                                          indicatorColor: Colors.white,
                                          indicatorWeight: 2,
                                          indicatorSize:
                                              TabBarIndicatorSize.tab,
                                          indicator: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          tabs: const [
                                            Tab(
                                              text: 'Plan 1',
                                            ),
                                            Tab(
                                              text: 'Plan 2',
                                            ),
                                            Tab(
                                              text: 'Plan 3',
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                          controller: _tabController,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  'Plan: ${serviceProviderData?['pricing_plan_1'] ?? 'Not added'}',
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                                Text(
                                                  'Pricing: ${serviceProviderData?['pricing_plan_1_price'] ?? 'Not added'}',
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                                const SizedBox(height: 10,),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    String selectedPlan = serviceProviderData?['pricing_plan_1'] ?? 'Not added';
                                                    String selectedPrice = serviceProviderData?['pricing_plan_1_price'] ?? 'Not added';

                                                    if (selectedPlan != 'Not added' && selectedPrice != 'Not added') {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => BookingPage(
                                                            serviceproviderId: widget.userId,
                                                            customerId: FirebaseAuth.instance.currentUser!.uid,
                                                            selectedPlan: selectedPlan,
                                                            selectedPrice: selectedPrice,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      Fluttertoast.showToast(msg: 'Cannot Book Pricing plan is not added.',
                                                          toastLength: Toast.LENGTH_SHORT,
                                                          gravity: ToastGravity.BOTTOM,
                                                          timeInSecForIosWeb: 1,
                                                          backgroundColor: Colors.white,
                                                          textColor: Colors.black,
                                                          fontSize: 17.0);
                                                    }
                                                  },
                                                  child: Text(
                                                    'Book ${serviceProviderData?['pricing_plan_1_price'] ?? 'Not added'} Plan',
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                    ),
                                                    padding: const EdgeInsets.all(12.0),
                                                    fixedSize: const Size(380, 60),
                                                    textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                                                    backgroundColor: Colors.deepPurple[400],
                                                    foregroundColor: Colors.white,
                                                    elevation: 10,
                                                    shadowColor: Colors.blue.shade900,
                                                  ),
                                                ),

                                              ],
                                            ),

                                            Column(
                                              children: [
                                                Text(
                                                  'Pricing: ${serviceProviderData?['pricing_plan_2']  ?? 'Not added'}',
                                                  style: const TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 17),
                                                ),
                                                Text(
                                                  'Pricing: ${serviceProviderData?['pricing_plan_2_price']  ?? 'Not added'}',
                                                  style: const TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 17),
                                                ),
                                                const SizedBox(height: 10,),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    String selectedPlan = serviceProviderData?['pricing_plan_2'] ?? 'Not added';
                                                    String selectedPrice = serviceProviderData?['pricing_plan_2_price'] ?? 'Not added';

                                                    if (selectedPlan != 'Not added' && selectedPrice != 'Not added') {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => BookingPage(
                                                            serviceproviderId: widget.userId,
                                                            customerId: FirebaseAuth.instance.currentUser!.uid,
                                                            selectedPlan: selectedPlan,
                                                            selectedPrice: selectedPrice,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      Fluttertoast.showToast(msg: 'Cannot Book Pricing plan is not added.',
                                                          toastLength: Toast.LENGTH_SHORT,
                                                          gravity: ToastGravity.BOTTOM,
                                                          timeInSecForIosWeb: 1,
                                                          backgroundColor: Colors.white,
                                                          textColor: Colors.black,
                                                          fontSize: 17.0);
                                                    }
                                                  },
                                                  child: Text(
                                                    'Book ${serviceProviderData?['pricing_plan_2_price'] ?? 'Not added'} Plan',
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                    ),
                                                    padding: const EdgeInsets.all(12.0),
                                                    fixedSize: const Size(380, 60),
                                                    textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                                                    backgroundColor: Colors.deepPurple[400],
                                                    foregroundColor: Colors.white,
                                                    elevation: 10,
                                                    shadowColor: Colors.blue.shade900,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  'Pricing: ${serviceProviderData?['pricing_plan_3']  ?? 'Not added'}',
                                                  style: const TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 17),
                                                ),
                                                Text(
                                                  'Pricing: ${serviceProviderData?['pricing_plan_3_price']  ?? 'Not added'}',
                                                  style: const TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 17),
                                                ),
                                                const SizedBox(height: 10,),

                                                ElevatedButton(
                                                  onPressed: () {
                                                    String selectedPlan = serviceProviderData?['pricing_plan_3'] ?? 'Not added';
                                                    String selectedPrice = serviceProviderData?['pricing_plan_3_price'] ?? 'Not added';

                                                    if (selectedPlan != 'Not added' && selectedPrice != 'Not added') {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => BookingPage(
                                                            serviceproviderId: widget.userId,
                                                            customerId: FirebaseAuth.instance.currentUser!.uid,
                                                            selectedPlan: selectedPlan,
                                                            selectedPrice: selectedPrice,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      Fluttertoast.showToast(msg: 'Cannot Book Pricing plan is not added.',
                                                          toastLength: Toast.LENGTH_SHORT,
                                                          gravity: ToastGravity.BOTTOM,
                                                          timeInSecForIosWeb: 1,
                                                          backgroundColor: Colors.white,
                                                          textColor: Colors.black,
                                                          fontSize: 17.0);
                                                    }
                                                  },
                                                  child: Text(
                                                    'Book ${serviceProviderData?['pricing_plan_3_price'] ?? 'Not added'} Plan',
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                    ),
                                                    padding: const EdgeInsets.all(12.0),
                                                    fixedSize: const Size(380, 60),
                                                    textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                                                    backgroundColor: Colors.deepPurple[400],
                                                    foregroundColor: Colors.white,
                                                    elevation: 10,
                                                    shadowColor: Colors.blue.shade900,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),


                                const SizedBox(height: 10),
                                const SizedBox(height: 10),
                                Column(
                                  children: [
                                    Container(
                                      color: Colors.white,
                                      child: TableCalendar(
                                        locale: "en_US",
                                        rowHeight: 50,
                                        headerStyle: const HeaderStyle(
                                            formatButtonVisible: false,
                                            titleCentered: true),
                                        availableGestures:
                                            AvailableGestures.all,
                                        selectedDayPredicate: (day) =>
                                            isSameDay(day, _focusedDay),
                                        focusedDay: _focusedDay,
                                        firstDay: DateTime.utc(2024, 2, 1),
                                        lastDay: DateTime.utc(2030, 3, 14),
                                        onDaySelected: _onDaySelected,
                                        calendarStyle: CalendarStyle(
                                          selectedDecoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: Colors.deepPurple[400],
                                          ),
                                          selectedTextStyle: const TextStyle(
                                              color: Colors.white),
                                          todayDecoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            color: Colors.deepPurple[100],
                                          ),
                                          todayTextStyle: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    // display select day
                                    Text(
                                      "Selected Day : ${DateFormat('yyyy-MM-dd').format(_focusedDay)}",
                                      style: const TextStyle(
                                          fontSize: 17, color: Colors.black87),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // display events for the selected day
                                    if (_selectedDay != null)
                                      FutureBuilder<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>>(
                                        future: FirebaseFirestore.instance
                                            .collection('service_providers')
                                            .doc(widget.userId)
                                            .get(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {

                                            return const CircularProgressIndicator();
                                          } else if (snapshot.hasError) {

                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else if (snapshot.hasData) {
                                                Map<String, dynamic>?
                                                serviceProviderData =
                                                snapshot.data!.data();

                                            if (serviceProviderData != null && serviceProviderData['events'] != null) {
                                              Map<String, dynamic> eventsData = Map<String, dynamic>.from(
                                                      serviceProviderData[
                                                          'events']);

                                              // get events for selected day
                                              List<Event> selectedDayEvents =
                                                  [];
                                              String selectedDayString =
                                                  _selectedDay!
                                                      .toIso8601String();

                                              if (eventsData.containsKey(
                                                  selectedDayString)) {
                                                List<dynamic> eventsList =
                                                    eventsData[
                                                        selectedDayString];
                                                selectedDayEvents =
                                                    eventsList.map((event) {
                                                  return Event(event['title']);
                                                }).toList();
                                              }

                                              // display events
                                              if (selectedDayEvents
                                                  .isNotEmpty) {
                                                return Column(
                                                  children: [
                                                    Text(
                                                      "Events for ${DateFormat('yyyy-MM-dd').format(_selectedDay!)}:",
                                                      style: const TextStyle(
                                                          fontSize: 17,
                                                          color: Colors.black87),
                                                    ),
                                                    ...selectedDayEvents
                                                        .map((event) => Text(
                                                              event.title,
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  color: Colors.black87),
                                                            )),
                                                  ],
                                                );
                                              } else {
                                                return const Text(
                                                    'No events for the selected day.',
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.black87));
                                              }
                                            } else {
                                              return const Text(
                                                  'No events data available.',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white));
                                            }
                                          } else {
                                            return const Text('No data',
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white));
                                          }
                                        },
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Divider(
                                  thickness: 2,
                                  color: Colors.black,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                    'Email: ${serviceProviderData?['email'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Text(
                                    'Phone: ${serviceProviderData?['phone'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Text(
                                    'Address: ${serviceProviderData?['address'] ?? 'N/A'}'),
                              ],
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
                              // display the average rating using RatingBar
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

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ServiceProviderReviewsPage(
                                        serviceProviderId: widget.userId,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),


                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(''),
                  );
                }
              },
            ),
          ),
          Positioned(
            bottom: 16,
            right: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance
                        .collection('service_providers')
                        .doc(widget.userId)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (snapshot.hasData) {
                        Map<String, dynamic>? serviceProviderData =
                            snapshot.data!.data();
                        List<String> photoUrls = List<String>.from(
                            serviceProviderData?['photos'] ?? []);

                        return ElevatedButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  reciverUserId: widget.userId,
                                  senderId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                  picture:
                                      photoUrls.isNotEmpty ? photoUrls[0] : '',
                                  reciverName:
                                      serviceProviderData?['name'] ?? 'Unknown',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            textStyle: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w600),
                            backgroundColor: Colors.deepPurple[400],
                            foregroundColor: Colors.white,
                            elevation: 10,
                            shadowColor: Colors.blue.shade900,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat, color: Colors.white, size: 33),
                              SizedBox(width: 5),
                              Text("Chat"),
                            ],
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// for calendar events
class Event {
  final String title;

  Event(this.title);

  // convert Event to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
    };
  }
}

