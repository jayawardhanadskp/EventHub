import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';





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
  bool _completedStep1 = false; // Flag to check if Step 1 is completed

  // Calendar variables
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> events = {}; // Placeholder for events


  // Form Key for Step 1
  final _step1FormKey = GlobalKey<FormState>();


  // Define the _getEventsForDay method
  List<Event> _getEventsForDay(DateTime day) {
    return (events[day] ?? []);
  }

  // for time picker
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
            if (_focusedDay != null && _selectedTime != null && address.isNotEmpty) {
              setState(() {
                _completedStep1 = true;
                _currentStep++;
              });
            } else {
              print('Please fill in all the required fields.');
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
            title: const Text('Booking Information',),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              (value as List<dynamic>).map((event) => Event(event['title'])).toList(),
                            ),
                          ),
                        );

                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text('Dates', style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900
                          ),
                            textAlign: TextAlign.left,),

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
                              selectedTextStyle: const TextStyle(color: Colors.white),
                              todayDecoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.deepPurple[100],
                              ),
                              todayTextStyle: const TextStyle(color: Colors.black),
                            ),
                            eventLoader: (day) => _getEventsForDay(day),
                          ),
                        ],
                      );
                    } else {
                      return const Text('No data',
                          style: TextStyle(fontSize: 17, color: Colors.white));
                    }
                  },

                ),


                const SizedBox(height: 15,),
                Text(
                  "Selected Day: ${_selectedDay != null ? DateFormat('yyyy-MM-dd').format(_selectedDay!) : 'No day selected'}",
                  style: const TextStyle(fontSize: 17),
                ),





                const SizedBox(height: 15,),
                Divider(thickness: 2, color: Colors.black38),
                const SizedBox(height: 15,),

                const Text('Starting Time', style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900
                )),
                const SizedBox(height: 15,),

                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: const Text('Select Time'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),

                const SizedBox(height: 15,),
                Text(
                  "Selected Time: ${_selectedTime.format(context)}",
                  style: const TextStyle(fontSize: 17),
                ),

                const SizedBox(height: 10,),
                Divider(thickness: 2,color: Colors.black38),
                const SizedBox(height: 15,),

                const Text('Address', style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900
                ),),

                const SizedBox(height: 15,),

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

                const SizedBox(height: 15,),
                Divider(thickness: 2,color: Colors.black38),
                const SizedBox(height: 15,),
                const Text('Informations', style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900
                )),
                const SizedBox(height: 15,),

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
            content: const Text('Step 2 - Payment Gateway'),
            isActive: _completedStep1,
          ),
        ],
      ),
    );
  }
}

// calender
class Event {
  final String title;
  Event(this.title);
  Map<String, dynamic> toJson() => {'title': title};
}
