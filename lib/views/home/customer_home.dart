
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eventhub/widgets/drawer.dart';
import '../../model/services_all.dart';
import '../../widgets/banner_customer_home.dart';
import '../../widgets/popular_services.dart';


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
      backgroundColor: Colors.deepPurple[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.pink,
            expandedHeight: 130,
            floating: false,
            pinned: true,
            snap: false,
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
                size: 34,
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            title: Text(
              'E V E N T  H U B',
              style: GoogleFonts.rubik(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.deepPurple[600],
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
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ServicesAll()));
                    },
                    child: Container(
                      height: 70,
                      width: double.infinity,
                      color: Colors.white,
                      child: const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Icon(Icons.search, color: Colors.black45, size: 30,),
                          ),
                          Padding(
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
                color: Colors.deepPurple[50],
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: popularServiceList(), // popular service list
                ),
              ),
            ),
          ),


          SliverToBoxAdapter(
            
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                ],
              ),
            ),
          ),



          SliverToBoxAdapter(

              child : Banners()
          ),



          SliverToBoxAdapter(
            child: Container(
              height: 400,
              color: Colors.deepPurple[300],
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                color: Colors.deepPurple[300],
                height: 400,



              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.deepPurple[300],
                  height: 400,

                ),
              ),
            ),
          ),


        ],
      ),
      drawer: AppDrawer(), // Use the AppDrawer widget
    );
  }
}
