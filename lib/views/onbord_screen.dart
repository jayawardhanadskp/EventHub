import 'package:flutter/material.dart';

import 'login/customer_login/customer_login.dart';
import 'login/serviceprovider_login/serviceprovider_login.dart';

class OnbordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue.shade900,
        body: Container(
          width: double.infinity,
          child: Column(

            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              SizedBox(
                height: 200,
              ),

              Image.asset('assets/logo_home.jpg'),

              SizedBox(
                height: 180,
              ),

              Expanded(
                child: Container(
                  width: double.infinity,

                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        spreadRadius: 4,
                      )
                    ],
                    color: Colors.lightBlue.shade50,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(16),topLeft: Radius.circular(16))
                  ),

                  child: Column(
                    children: [

                      SizedBox(
                        height: 30,
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 15,right: 15),
                        child: Text("Platform for EVENT Collaboration",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                            fontFamily:'anton',
                          ),),
                      ),

                      SizedBox(
                        height: 60,
                      ),

                     Padding(padding: EdgeInsets.only(
                       left: 15,
                       right: 15,
                     ),
                       child: ElevatedButton(

                           onPressed: () {
                             Navigator.push(
                                 context,
                                 MaterialPageRoute(builder: (context) => const CustomerLogin()),
                             );
                           },
                           child: Text("CUSTOMER"),

                         style: ElevatedButton.styleFrom(
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(20.0),
                           ),
                           padding: EdgeInsets.all(20.0),
                           fixedSize: Size(400, 80),
                           textStyle: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                           primary: Colors.white,
                           onPrimary: Colors.blue.shade900,
                           elevation: 15,
                           shadowColor: Colors.blue.shade900,

                         ),

                       ),
                     ),

                      SizedBox(
                        height: 30,
                      ),

                      Padding(padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                        child: ElevatedButton(

                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ServiceProviderLogin()),
                            );
                          },
                          child: Text("PLANNER"),

                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: EdgeInsets.all(20.0),
                            fixedSize: Size(400, 80),
                            textStyle: TextStyle(fontSize: 24.5, fontWeight: FontWeight.bold),
                            primary: Colors.white,
                            onPrimary: Colors.blue.shade900,
                            elevation: 15,
                            shadowColor: Colors.blue.shade900,

                          ),

                        ),
                      ),

                    ],
                  ),
                ),
              )
            ],



          ),
        ),
      );
  }
}
