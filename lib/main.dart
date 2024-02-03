import 'package:eventhub/views/home/customer_home.dart';
import 'package:eventhub/views/onbord_screen.dart';
import 'package:eventhub/views/profile/customer_profile.dart';
import 'package:eventhub/views/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'model/customer_favorites.dart';
import 'model/services_all.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For web Firebase
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
    // For (iOS, Android)
    await Firebase.initializeApp();
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
      routes: {
        '/onbord_screen':(context) => OnbordScreen(),
        '/customer_home':(context) => customerHomePage(),
        '/customer_profile':(context) => ProfileCustomer(),
        '/services_all':(context) => ServicesAll(),
        '/customer_favorites' : (context) => FavoritesPage(),


      },
    );
  }
}
