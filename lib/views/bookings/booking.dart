import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventhub/views/bookings/paymet_sucess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingPage extends StatefulWidget {
  final String customerId;
  final String serviceproviderId;
  final String selectedPlan;
  final String selectedPrice;

  const BookingPage({
    required this.customerId,
    required this.serviceproviderId,
    required this.selectedPlan,
    required this.selectedPrice,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {

  // store selected values
  String selectedDayText = '';
  String selectedTimeText = '';
  String address = '';
  String notes = '';

  // Stepper variables
  int _currentStep = 0;
  bool _completedStep1 = false;

  // Calendar variables
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> events = {};

  // Form Key for Step 1
  final _step1FormKey = GlobalKey<FormState>();

  // Define the _getEventsForDay method
  List<Event> _getEventsForDay(DateTime day) {
    return (events[day] ?? []);
  }

  // For time picker
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Function to show time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // initialize Firebase Messaging and request notification permission
    _initFirebaseMessaging();
  }

  // function to initialize Firebase Messaging and request permission
  Future<void> _initFirebaseMessaging() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // Function to send notification to service provider using FCM

  Future<void> sendNotificationToServiceProvider(String serviceproviderId) async {
    try {
      // Fetch service provider data
      DocumentSnapshot<Map<String, dynamic>> serviceProviderSnapshot =
      await FirebaseFirestore.instance
          .collection('service_providers')
          .doc(serviceproviderId)
          .get();

      print('Service Provider Snapshot: $serviceProviderSnapshot');

      if (serviceProviderSnapshot.exists && serviceProviderSnapshot.data() != null) {
        // Get FCM token from the service provider data
        String? serviceProviderToken = serviceProviderSnapshot.data()!['fcmToken'];

        print('FCM Token: $serviceProviderToken');

        if (serviceProviderToken != null) {
          // Send notification
          await FirebaseMessaging.instance.subscribeToTopic('service_provider_topic');

          await FirebaseMessaging.instance.sendMessage(
            to: serviceProviderToken,
            data: <String, String>{
              'title': 'New Booking!',
              'body': 'You have a new booking from a customer.',
            },
          );

          await FirebaseMessaging.instance.unsubscribeFromTopic('service_provider_topic');
        } else {
          print('FCM Token is null for service provider with ID: $serviceproviderId');
        }
      } else {
        print('Service provider not found with ID: $serviceproviderId');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }









  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Page'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        type: StepperType.horizontal,
        onStepContinue: () {
          if (_currentStep == 0) {
            if (_focusedDay != null &&
                _selectedTime != null &&
                address.isNotEmpty) {
              setState(() {
                _completedStep1 = true;
                _currentStep++;
              });
            } else {
              Fluttertoast.showToast(
                msg: 'Please fill required fields.',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 17.0,
              );
            }
          } else if (_currentStep == 1) {
            // Handle Step 2 logic if needed
          }
          // Add additional conditions for other steps if needed
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          } else {
            // Handle going back from the first step, if needed
          }
        },
        steps: [
          Step(
            title: const Text('Booking Information'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fetching service provider data
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance
                      .collection('service_providers')
                      .doc(widget.serviceproviderId)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      // Error state
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      // Data available
                      Map<String, dynamic>? serviceProviderData =
                      snapshot.data!.data();

                      if (serviceProviderData != null &&
                          serviceProviderData['events'] != null) {
                        // Convert date strings to DateTime
                        Map<String, dynamic> eventsData =
                        Map<String, dynamic>.from(
                            serviceProviderData['events']);
                        events = Map<DateTime, List<Event>>.from(
                          eventsData.map(
                                (key, value) => MapEntry(
                              DateTime.parse(key),
                              (value as List<dynamic>)
                                  .map((event) => Event(event['title']))
                                  .toList(),
                            ),
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dates',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          // Table Calendar
                          TableCalendar(
                            locale: "en_US",
                            rowHeight: 50,
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),
                            availableGestures: AvailableGestures.all,
                            selectedDayPredicate: (day) =>
                            isSameDay(day, _focusedDay) &&
                                !events.containsKey(day) &&
                                _getEventsForDay(day).isEmpty &&
                                _currentStep == 0,

                            focusedDay: _focusedDay,
                            firstDay: DateTime.utc(2024, 2, 1),
                            lastDay: DateTime.utc(2030, 3, 14),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            calendarStyle: CalendarStyle(
                              selectedDecoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.deepPurple[400],
                              ),
                              selectedTextStyle: const TextStyle(
                                  color: Colors.white),
                              todayDecoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.deepPurple[100],
                              ),
                              todayTextStyle: const TextStyle(
                                  color: Colors.black),
                            ),
                            eventLoader: (day) => _getEventsForDay(day),
                          ),
                        ],
                      );
                    } else {
                      return const Text(
                        'No data',
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "Selected Day: ${_selectedDay != null && !_getEventsForDay(_selectedDay!).isNotEmpty ? DateFormat('yyyy-MM-dd').format(_selectedDay!) : 'No day selected'}",
                  style: const TextStyle(fontSize: 17),
                ),

                const SizedBox(
                  height: 15,
                ),
                Divider(thickness: 2, color: Colors.black38),
                const SizedBox(
                  height: 15,
                ),
                const Text('Starting Time',
                    style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: const Text('Select Time'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "Selected Time: ${_selectedTime.format(context)}",
                  style: const TextStyle(fontSize: 17),
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(thickness: 2, color: Colors.black38),
                const SizedBox(
                  height: 15,
                ),
                const Text('Address',
                    style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: '',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Update the address variable as the text changes
                    address = value;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Divider(thickness: 2, color: Colors.black38),
                const SizedBox(
                  height: 15,
                ),
                const Text('Informations',
                    style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  maxLines: null, // Set maxLines to null for an unlimited number of lines
                  decoration: const InputDecoration(
                    labelText: 'Write your notes',
                    hintText: 'Type your notes here...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    // Add any validation logic if needed
                    return null; // Return null if the input is valid
                  },
                  // Handle user input using onChanged or onSaved callbacks
                  onChanged: (value) {
                    notes = value;
                  },
                ),
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Payment'),
            content: Column(
              children: [
                const Text('Step 2 - Payment Gateway'),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Convert selectedPrice to double
                    double originalPrice = double.parse(widget.selectedPrice);

                    // Add service charge of $2
                    double serviceCharge = 2.0;

                    double totalAmount = originalPrice + serviceCharge;



                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => PaypalCheckout(
                        sandboxMode: true,
                        clientId:
                        "AUYd9LGSPshX4rSN7c1WdhRajOVzkmIV0AEyOix-O_TiDok6yBjsjEPskKf52Id3637b_lIKMRQHptCb",
                        secretKey:
                        "EMuLSvPDDSmLcbCHfNgJdYCTCz4od7APmodIGrw1aV7K9ivJGQVaw2P2xnSN2Z66_uHXm0DkgM9idEhI",
                        returnURL: "success.snippetcoder.com",
                        cancelURL: "cancel.snippetcoder.com",
                        transactions: [
                          {
                            "amount": {
                              "total": totalAmount.toStringAsFixed(
                                  2), // Format total amount to 2 decimal places
                              "currency": "USD",
                            },
                            "description":
                            "The payment transaction description.",
                            "item_list": {
                              "items": [
                                {
                                  "name": "Your Item",
                                  "quantity": 1,
                                  "price": originalPrice.toStringAsFixed(
                                      2), // Format original price to 2 decimal places
                                  "currency": "USD"
                                },
                                {
                                  "name": "Service Charge",
                                  "quantity": 1,
                                  "price": serviceCharge.toStringAsFixed(
                                      2), // Format service charge to 2 decimal places
                                  "currency": "USD"
                                }
                              ],
                            }
                          }
                        ],
                        note: "PAYMENT_NOTE",
                        onSuccess: (Map params) async {
                          print("onSuccess: $params");


                          // Save booking details to firestore
                          await FirebaseFirestore.instance
                              .collection('bookings')
                              .add({
                            'customerId': widget.customerId,
                            'serviceproviderId': widget.serviceproviderId,
                            'selectedPlan': widget.selectedPlan,
                            'selectedPrice': widget.selectedPrice,
                            'selectedDay': _selectedDay != null
                                ? DateFormat('yyyy-MM-dd').format(_selectedDay!)
                                : 'No day selected',
                            'selectedTime': _selectedTime.format(context),
                            'address': address,
                            'notes': notes,
                            'paymentDetails': params,
                            'timestamp': FieldValue.serverTimestamp(),
                            'status': 'waiting',
                          });

                          // Send FCM message to service provider
                          await sendNotificationToServiceProvider(widget.serviceproviderId);

                        /*  Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => ConfirmationPage(),
                            ),
                          ); */
                        },
                        onError: (error) {
                          print("onError: $error");
                          Navigator.pop(context);
                        },
                        onCancel: () {
                          print('cancelled:');
                        },
                      ),
                    ));
                  },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),

                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Lottie.network('https://lottie.host/a22da8aa-c68c-4965-b697-67779a134a02/hixW9cz6zq.json',
                      height: 50
                    ),
                  )
                )
              ],
            ),
            isActive: _completedStep1,
          ),
        ],
      ),
    );
  }
}

// calendar event class
class Event {
  final String title;
  Event(this.title);
  Map<String, dynamic> toJson() => {'title': title};
}

//  sb-oyg5h29658934@personal.example.com
//  WoVH$I+3