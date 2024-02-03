
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {

  //log out
  void logout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushNamed(context, '/onbord_screen');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.deepPurple[400],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple[400],
              ),
              child: Column(
                children: [
                  Text(
                    'Event Hub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),


            ListTile(
              leading: Icon(
                Icons.home_rounded,
                color: Colors.white, size: 20,
              ),
              title: Text('H O M E',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),),
              onTap: () {

                Navigator.pop(context); // Close the drawer
              },
            ),

            ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.white, size: 20,
              ),
              title: Text('P R O F I L E',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),),
              onTap: () {
                Navigator.pop(context); // Close the drawer

                // navigate profilepage
                Navigator.pushNamed(context, '/customer_profile');
              },
            ),

            ListTile(
              leading: Icon(
                Icons.queue_play_next_outlined,
                color: Colors.white, size: 20,
              ),
              title: Text('S E R V I C E S',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),),
              onTap: () {
                Navigator.pop(context); // Close the drawer

                Navigator.pushNamed(context, '/services_all');
              },
            ),

            ListTile(
              leading: Icon(
                Icons.favorite_outlined,
                color: Colors.white, size: 20,
              ),
              title: Text('F A V O R I T E S',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),),
              onTap: () {
                Navigator.pop(context); // Close the drawer

                Navigator.pushNamed(context, '/customer_favorites');
              },
            ),





            ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: Colors.white, size: 20,
              ),
              title: Text('L O G  O U T',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),),
              onTap: () {

                Navigator.pop(context); // Close the drawer

                //logout
                logout();
              },
            ),



          ],
        ),
      ),
    );
  }
}
