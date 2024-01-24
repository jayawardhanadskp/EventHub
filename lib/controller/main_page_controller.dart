import 'package:eventhub/views/onbord_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../views/home/customer_home.dart';
import '../views/home/serviceprovider_home.dart';
import '../views/login/customer_login/customer_login.dart';


class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User? user = snapshot.data;

          // Check if the user has a role
          if (user != null && user.email != null) {
            // You may replace this logic with your actual data retrieval logic
            // For example, if using Firebase Firestore, you might fetch user data like this:
            // var userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
            // var userRole = userData['userRole'];

            // For the sake of example, let's assume you have a field named 'userRole'
            var userRole = "customer"; // Replace with actual user role retrieval logic

            if (userRole == "customer") {
              return customerHomePage();
            } else if (userRole == "serviceProvider") {
              return serviceproviderHomePage();
            } else {
              // Handle unknown user roles
              return Container();
            }
          } else {
            // Handle the case where user data is not available
            return Container();
          }
        } else {
          // User is not signed in
          return OnbordScreen();
        }
      },
    );
  }
}
