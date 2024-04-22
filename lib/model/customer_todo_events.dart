import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerTodoCalendar extends StatefulWidget {
  const CustomerTodoCalendar({Key? key}) : super(key: key);

  @override
  State<CustomerTodoCalendar> createState() => _CustomerTodoCalendarState();
}

class _CustomerTodoCalendarState extends State<CustomerTodoCalendar> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<dynamic>> _events;
  late TextEditingController _eventController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _eventController = TextEditingController();
    _events = {};
    // load events from Firestore
    _loadEvents();
  }



// Save events to Firestore
  void _saveEvents() async {
    final user = _auth.currentUser;
    if (user != null) {
      final eventsCollection = _firestore.collection('customers').doc(user.uid).collection('events');
      for (final entry in _events.entries) {
        final date = entry.key;
        final events = entry.value;
        await eventsCollection.doc(date.toString()).set({
          'date': date,
          'events': events,
        });
      }
    }
  }

// load events from Firestore
  void _loadEvents() async {
    final user = _auth.currentUser;
    if (user != null) {
      final eventsCollection = _firestore.collection('customers').doc(user.uid).collection('events');
      final snapshot = await eventsCollection.get();
      setState(() {
        _events = Map<DateTime, List<dynamic>>.fromEntries(snapshot.docs.map((doc) {
          final date = DateTime.parse(doc.id);
          final events = List<dynamic>.from(doc.data()!['events']);
          return MapEntry(date, events);
        }));
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Calendar',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _buildCalendar(),
                const SizedBox(height: 20),
                _buildEventList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(2, 10, 2, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0x593ED3FF), Color(0xFF7B1FA2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF593ED3),
            blurRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TableCalendar(
        calendarStyle: const CalendarStyle(
          canMarkersOverflow: true,
          weekNumberTextStyle: TextStyle(color: Colors.white38),
          defaultTextStyle: TextStyle(color: Colors.white),
        ),
        headerStyle: const HeaderStyle(
          titleTextStyle: TextStyle(color: Colors.white),
          formatButtonDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          formatButtonTextStyle: TextStyle(color: Colors.deepPurple),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.white),
          weekendStyle: TextStyle(color: Colors.white),
        ),
        firstDay: DateTime.utc(2021, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
          });
        },
        eventLoader: _getEventsForDay,
      ),
    );
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  Widget _buildEventList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Events for the selected day',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        for (final event in _events[_selectedDay] ?? [])
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.deepPurple[50],

              child: ListTile(

                title: Text(event),
                onTap: () {

                },
              ),
            ),
          ),
        const SizedBox(height: 10),
        TextField(
          controller: _eventController,
          decoration: const InputDecoration(
            hintText: 'Enter an event',
            suffixIcon: Icon(Icons.add),
          ),
          onSubmitted: (value) {
            setState(() {
              if (_events[_selectedDay] == null) {
                _events[_selectedDay] = [];
              }
              _events[_selectedDay]!.add(value);
              _eventController.clear();
              _saveEvents();
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }
}
