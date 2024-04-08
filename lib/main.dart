
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
import 'model/customer_favorites.dart';
import 'model/services_all.dart';
import 'views/events/customer/finished_customer.dart';
import 'views/events/customer/upcoming_customer.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // for web Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA71UrBPlvvzsW2VIT9MAfhxUPNY_dTQjk",
        appId: "1:951945595901:web:f7f2c165726610e89da794",
        messagingSenderId: "951945595901",
        projectId: "eventhub-2beb6",
      ),



    );

  } else {
    // for (iOS, Android)
    await Firebase.initializeApp(

    );

  }




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


      },
    );
  }
}
