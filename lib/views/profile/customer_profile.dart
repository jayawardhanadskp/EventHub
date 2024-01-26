import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/clipper_customer.dart';

class ProfileCustomer extends StatefulWidget {
  const ProfileCustomer({Key? key}) : super(key: key);

  @override
  _ProfileCustomerState createState() => _ProfileCustomerState();
}

class _ProfileCustomerState extends State<ProfileCustomer> {
  late User? _user;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple[600],
        elevation: 0,
      ),
      body: Stack(
        children: [SingleChildScrollView(
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection('customers').doc(_user?.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData) {
                Map<String, dynamic>? userData = snapshot.data!.data();
                String profilePhotoUrl = userData?['profilePicture'] ?? '';

                return ClipPath(
                  clipper: ClipperCusProfile(),
                  child: Container(
                    color: Colors.deepPurple[600],
                    height: 300,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            CircleAvatar(
                              radius: 80,
                              backgroundImage: NetworkImage(profilePhotoUrl),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Name: ${userData?['fullName']}',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Email: ${userData?['email']}',
                              style: TextStyle(color: Colors.white),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: Text('No Datas'),
                );
              }
            },
          ),
        ),
        ]
      ),
    );
  }
}