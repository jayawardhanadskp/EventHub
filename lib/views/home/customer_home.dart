
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eventhub/widgets/drawer.dart';
import 'package:lottie/lottie.dart';
import '../../model/services_all.dart';
import '../../widgets/banner_customer_home.dart';
import '../../widgets/notifications.dart';
import '../../widgets/popular_services.dart';
import '../../widgets/show_feedbacks.dart';


class customerHomePage extends StatefulWidget {



  @override
  State<customerHomePage> createState() => _customerHomePageState();
}

class _customerHomePageState extends State<customerHomePage> {

  // get user data
  String? name = '';
  String? email = '';
  String? proImage = '';
  File? imageXFile;
  
  Future _getDataFromDatabase() async {
    await FirebaseFirestore.instance.collection('customers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async {

          if(snapshot.exists) {
            setState(() {
              name = snapshot.data()!['fullName'];
              email = snapshot.data()!['email'];
              proImage = snapshot.data()!['profilePicture'];
            });
          }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDataFromDatabase();
  }

  TextEditingController _number = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.pink,
            expandedHeight: 130,
            floating: false,
            pinned: true,
            snap: false,
            leading: IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 34,
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'E V E N T  H U B',
                  style: GoogleFonts.rubik(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsPage() ));
                  },
                  child: const Icon(Icons.notifications_active,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color (0xFF5E35B1),Color (0xFFB39DDB) ],
                  begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    stops: [0.0,1.0],
                    tileMode: TileMode.clamp
                  )
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(
                height: 14,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, left: 10,top: 5),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ServicesAll()));
                    },
                    child: Container(
                      height: 70,
                      width: double.infinity,
                      color: Colors.deepPurple[50],
                      child:  Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Lottie.network('https://lottie.host/545ac7c8-9849-45c5-b7a7-404405ca3832/8LN3lAjtbg.json'),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 25.0),
                            child: Text('Search Services', style: TextStyle(color: Colors.black45,fontSize: 21),),
                          )
                        ],
                      ),

                    ),
                  ),
                ),
              ),
            ]),
          ),


          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: popularServiceList(), // popular service list
                ),
              ),
            ),
          ),




          SliverToBoxAdapter(

              child : Banners()
          ),



          SliverToBoxAdapter(
            child: Container(

              color: Colors.deepPurple[50],
              padding: const EdgeInsets.symmetric(horizontal: 16.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Users Feedbacks',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),

                    ApprovedFeedbackPage(),
                  ],
                ),

            ),
          ),
        ],
      ),
      drawer: const AppDrawer(), // Use the AppDrawer widget
    );
  }
}
