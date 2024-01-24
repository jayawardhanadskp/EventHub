import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProviderProfile extends StatefulWidget {
  final String? userId;
  const ServiceProviderProfile({Key? key, this.userId}) : super(key: key);
  @override
  _ServiceProviderProfileState createState() => _ServiceProviderProfileState();
}

class _ServiceProviderProfileState extends State<ServiceProviderProfile> {
  late User? _user;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    // Get the current user from Firebase Auth
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
          'Service Provider Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple[600],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance.collection('service_providers').doc(_user?.uid).get(),
          builder: (context, snapshot) {
            // Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            // If Error
            else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            // Data received
            else if (snapshot.hasData) {
              Map<String, dynamic>? serviceProviderData = snapshot.data!.data();
              List<String> photoUrls = List<String>.from(serviceProviderData?['photos'] ?? []);

              // Extracting the user ID from the current user
              String serviceProviderId = _user?.uid ?? '' ;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(photoUrls.isNotEmpty ? photoUrls[0] : ''),
                    ),
                    const SizedBox(height: 16),
                    Text('user ID: $serviceProviderId'),
                    Text('Name: ${serviceProviderData?['name']}'),
                    Text('Email: ${serviceProviderData?['email']}'),
                    Text('Phone: ${serviceProviderData?['phone']}'),
                    Text('Service: ${serviceProviderData?['service']}'),
                    Text('Address: ${serviceProviderData?['address']}'),
                    Text('Business Name: ${serviceProviderData?['business_Name']}'),
                    const SizedBox(height: 16),
                    Text('Photos:'),
                    for (int i = 0; i < photoUrls.length; i++)
                      Image.network(photoUrls[i]),
                  ],
                ),
              );
            }
            // No data
            else {
              return Center(
                child: Text('No Data'),
              );
            }
          },
        ),
      ),
    );
  }
}
