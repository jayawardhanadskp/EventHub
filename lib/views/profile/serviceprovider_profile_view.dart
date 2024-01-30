import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProviderProfileView extends StatefulWidget {
  final String userId;

  const ServiceProviderProfileView({Key? key, required this.userId}) : super(key: key);

  @override
  _ServiceProviderProfileViewState createState() => _ServiceProviderProfileViewState();
}

class _ServiceProviderProfileViewState extends State<ServiceProviderProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Provider Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('service_providers')
            .doc(widget.userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            Map<String, dynamic>? serviceProviderData = snapshot.data!.data();
            List<String> photoUrls = List<String>.from(serviceProviderData?['photos'] ?? []);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(photoUrls.isNotEmpty ? photoUrls[0] : ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Business Name: ${serviceProviderData?['business_Name']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Description: ${serviceProviderData?['description'] ?? 'N/A'}'),
                  SizedBox(height: 10),
                  Divider(
                    thickness: 2,
                    color: Colors.black,
                  ),
                  SizedBox(height: 10),
                  Text('Pricing Plan: ${serviceProviderData?['pricing_plan'] ?? 'N/A'}'),
                  SizedBox(height: 10),
                  Divider(
                    thickness: 2,
                    color: Colors.black,
                  ),
                  SizedBox(height: 10),
                  Text('Email: ${serviceProviderData?['email'] ?? 'N/A'}'),
                  SizedBox(height: 10),
                  Text('Phone: ${serviceProviderData?['phone'] ?? 'N/A'}'),
                  SizedBox(height: 10),
                  Text('Address: ${serviceProviderData?['address'] ?? 'N/A'}'),
                ],
              ),
            );
          } else {
            return Center(
              child: Text('No Data'),
            );
          }
        },
      ),
    );
  }
}
