import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../views/onbord_screen.dart';


class customerHomePagee extends StatelessWidget {
  const customerHomePagee({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Home Page"),
      ),
      body: Container(
        child: Center(


          child: ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context) => OnbordScreen()));
            },
            child: Text("LOGOUT"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(15.0),
              fixedSize: Size(230, 60),
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              primary: Colors.white,
              onPrimary: Colors.blue.shade900,
              elevation: 10,
              shadowColor: Colors.blue.shade900,
            ),
          ),
        ),
      ),
    );
  }
}
