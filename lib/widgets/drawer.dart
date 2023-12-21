
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.deepPurple[300],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.pink,
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
