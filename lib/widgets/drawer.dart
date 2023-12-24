
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue.shade900,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple[700],
              ),
              child: Text(
                'Event Hub',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Item 1',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {

                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              title: Text(
                'Item 2',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {

                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
    );
  }
}
