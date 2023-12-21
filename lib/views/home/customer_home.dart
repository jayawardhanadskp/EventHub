import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eventhub/widgets/drawer.dart';

import '../../widgets/services.dart';

class customerHomePage extends StatefulWidget {
  @override
  State<customerHomePage> createState() => _customerHomePageState();
}

class _customerHomePageState extends State<customerHomePage> {
  TextEditingController _number = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.deepPurple[100],
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
                height: 15,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),

                child: TextField(
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search Services',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ]),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ServiceList(), // service list
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
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [],
                  ),
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
