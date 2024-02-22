import 'package:flutter/material.dart';

import 'login/customer_login/customer_login.dart';
import 'login/serviceprovider_login/serviceprovider_login.dart';

class OnbordScreen extends StatelessWidget {
  const OnbordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue.shade900,
        body: SizedBox(
          width: double.infinity,
          child: Column(

            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              const SizedBox(
                height: 200,
              ),

              Image.asset('assets/logo_home.jpg'),

              const SizedBox(
                height: 180,
              ),

              Expanded(
                child: Container(
                  width: double.infinity,

                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        spreadRadius: 4,
                      )
                    ],
                    color: Colors.lightBlue.shade50,
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(16),topLeft: Radius.circular(16))
                  ),

                  child: Column(
                    children: [

                      const SizedBox(
                        height: 30,
                      ),

                      const Padding(
                        padding: EdgeInsets.only(left: 15,right: 15),
                        child: Text("Platform for EVENT Collaboration",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                            fontFamily:'anton',
                          ),),
                      ),

                      const SizedBox(
                        height: 60,
                      ),

                     Padding(padding: const EdgeInsets.only(
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

                         style: ElevatedButton.styleFrom(
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(20.0),
                           ),
                           padding: const EdgeInsets.all(20.0),
                           fixedSize: const Size(400, 80),
                           textStyle: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                           backgroundColor: Colors.white,
                           foregroundColor: Colors.blue.shade900,
                           elevation: 15,
                           shadowColor: Colors.blue.shade900,

                         ),
                           child: const Text("CUSTOMER"),

                       ),
                     ),

                      const SizedBox(
                        height: 30,
                      ),

                      Padding(padding: const EdgeInsets.only(
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

                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: const EdgeInsets.all(20.0),
                            fixedSize: const Size(400, 80),
                            textStyle: const TextStyle(fontSize: 24.5, fontWeight: FontWeight.bold),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue.shade900,
                            elevation: 15,
                            shadowColor: Colors.blue.shade900,

                          ),
                          child: const Text("PLANNER"),

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
