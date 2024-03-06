import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../views/home/customer_home.dart';
import '../views/home/serviceprovider_home.dart';
import '../views/login/customer_login/customer_login.dart';
import '../views/onbord_screen.dart';
import '../views/splash_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User? user = snapshot.data;

          if (user != null && user.uid != null) {
            return FutureBuilder<DocumentSnapshot>(
              // Check the customers collection
              future: FirebaseFirestore.instance.collection('customers').doc(user.uid).get(),
              builder: (context, customerSnapshot) {
                if (customerSnapshot.hasData && customerSnapshot.data != null) {
                  // User is found in the customers collection
                  return customerHomePage();
                } else {
                  // Check the service_providers collection
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('service_providers').doc(user.uid).get(),
                    builder: (context, serviceProviderSnapshot) {
                      if (serviceProviderSnapshot.hasData && serviceProviderSnapshot.data != null) {
                        // User is found in the service_providers collection
                        return serviceproviderHomePage();
                      } else {
                        // Handle the case where user is not found in either collection
                        return SplachScreen();
                      }
                    },
                  );
                }
              },
            );
          } else {
            // Handle the case where the user UID is not available
            return SplachScreen();
          }
        } else {
          // User is not signed in
          return SplachScreen();
        }
      },
    );
  }
}
