import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eventhub/views/chat/inbox_page.dart';

import '../bookings/serviceprovider/bookings_retrive.dart';
import '../profile/serviceprovider_profile.dart';

class serviceproviderHomePage extends StatefulWidget {
  const serviceproviderHomePage({super.key});

  @override
  State<serviceproviderHomePage> createState() =>
      _serviceproviderHomePageState();
}

class _serviceproviderHomePageState extends State<serviceproviderHomePage> {
  PageController _pageController = PageController(initialPage: 0);

  int _pageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.deepPurple,
        animationDuration: Duration(milliseconds: 300),
        items: [
          Icon(Icons.home, size: 35, color: Colors.white),
          Icon(Icons.book_online, size: 35, color: Colors.white),
          Icon(Icons.inbox, size: 35, color: Colors.white),
          Icon(Icons.person, size: 35, color: Colors.white),
        ],
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  final List<Widget> _pages = [
    Container(color: Colors.red),
    ServiceProviderBookingPage(serviceProviderId: FirebaseAuth.instance.currentUser!.uid),
    InboxPage(),
    ServiceProviderProfile(),
  ];
}
