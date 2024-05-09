
import 'package:eventhub/controller/firebase_api.dart';
import 'package:eventhub/views/bookings/cutomer/bookings_customer.dart';
import 'package:eventhub/views/chat/inbox_page.dart';
import 'package:eventhub/views/home/customer_home.dart';
import 'package:eventhub/views/onbord_screen.dart';
import 'package:eventhub/views/profile/customer_profile.dart';
import 'package:eventhub/views/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';




import 'model/app_feedbacks.dart';
import 'model/customer_budget_calculator.dart';
import 'model/customer_favorites.dart';
import 'model/customer_todo_events.dart';
import 'model/report/report.dart';
import 'model/services_all.dart';
import 'views/events/customer/finished_customer.dart';
import 'views/events/customer/upcoming_customer.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize Firebase
    await Firebase.initializeApp();

  // Request permission for receiving notifications
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');


  runApp( MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EventHub',
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),

      home:  SplachScreen(),

      // customer home drawer only
      routes: {
        '/onbord_screen':(context) => OnbordScreen(),
        '/customer_home':(context) => customerHomePage(),
        '/customer_profile':(context) => ProfileCustomer(),
        '/services_all':(context) => ServicesAll(),
        '/customer_favorites' : (context) => FavoritesPage(),
        '/inbox_customer' : (context) => InboxPage(),
        '/bookings_customer' : (context) => CustomerBookingPage(customerId: FirebaseAuth.instance.currentUser!.uid),
        '/upcoming_customer' : (context) => UpcomingEventCustomerPage(),
        '/finished_customer' : (context) => FinishedEventsCustomerPage(),
        '/app_feedbacks' : (context) => FeedbackPage(),
        '/customer_todo_events' : (context) => CustomerTodoCalendar(),
        '/customer_budget_calculator' : (context) => BudgetCalculatePage(),
        '/report' : (context) => ReportProblemPage(),


      },
    );
  }
}
