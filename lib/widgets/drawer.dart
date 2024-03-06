import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  void logout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushNamed(context!, '/onbord_screen');
  }

  late String userEmail;
  late String userName;
  late String userPhoto;

  @override
  void initState() {
    super.initState();
    userEmail = "";
    userName = "";
    userPhoto = "";
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('customers')
          .doc(userId)
          .get();

      setState(() {
        userEmail = snapshot['email'];
        userName = snapshot['name'];
        userPhoto = snapshot['photo'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.deepPurple[400],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountEmail: Text(userEmail),
              accountName: Text(userName),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _getImageUrl(userPhoto),
              ),
              decoration: BoxDecoration(
                color: Colors.deepPurple[400],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 20,
              ),
              title: const Text(
                'H O M E',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
              title: const Text(
                'P R O F I L E',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                // navigate profile page
                Navigator.pushNamed(context, '/customer_profile');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.queue_play_next_outlined,
                color: Colors.white,
                size: 20,
              ),
              title: const Text(
                'S E R V I C E S',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.pushNamed(context, '/services_all');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.favorite_outlined,
                color: Colors.white,
                size: 20,
              ),
              title: const Text(
                'F A V O R I T E S',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.pushNamed(context, '/customer_favorites');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.chat,
                color: Colors.white,
                size: 20,
              ),
              title: const Text(
                'M A S S A G E S',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.pushNamed(context, '/inbox_customer');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.shopping_bag,
                color: Colors.white,
                size: 20,
              ),
              title: const Text(
                'B O O K I N G S',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.pushNamed(context, '/bookings_customer');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.event,
                color: Colors.white,
                size: 20,
              ),
              title: const Text(
                'U P C O M I N G    E V N T S',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.pushNamed(context, '/upcoming_customer');
              },
            ),ListTile(
              leading: const Icon(
                Icons.event_available,
                color: Colors.white,
                size: 20,
              ),
              title: const Text(
                'F I N I S H E D    E V N T S',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.pushNamed(context, '/finished_customer');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 20,
              ),
              title: const Text(
                'L O G  O U T',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                // logout
                logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  // image
  ImageProvider<Object>? _getImageUrl(String url) {
    try {
      if (url.startsWith('http') || url.startsWith('https')) {

        return NetworkImage(url);
      }
    } catch (e) {
      return null;
    }
  }
}
