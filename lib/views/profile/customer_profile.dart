import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../widgets/clipper_customer.dart';

class ProfileCustomer extends StatefulWidget {
  const ProfileCustomer({Key? key}) : super(key: key);

  @override
  _ProfileCustomerState createState() => _ProfileCustomerState();
}

class _ProfileCustomerState extends State<ProfileCustomer> {
  late User? _user;
  late GoogleSignInAccount? _googleUser;
  late AccessToken? _facebookAccessToken;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (user.providerData.isNotEmpty) {
        var providerData = user.providerData.first;
        if (providerData.providerId == 'google.com') {
          //  Google
          _googleUser = await GoogleSignIn().signInSilently();
        } else if (providerData.providerId == 'facebook.com') {
          //  Facebook
          _facebookAccessToken = await FacebookAuth.instance.accessToken;
        }
      }
    }

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
        children: [
          SingleChildScrollView(
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
                  String profilePhotoUrl = userData?['photo'] ?? '';
                  String name = _getName(userData);
                  String email = _getEmail(userData);

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
                                backgroundImage: _getImageUrl(profilePhotoUrl),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Name: $name',
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Email: $email',
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
                    child: Text('No Data'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider<Object>? _getImageUrl(String profilePhotoUrl) {
    if (_user != null && _user!.providerData.isNotEmpty) {
      var providerData = _user!.providerData.first;
      if (providerData.providerId == 'google.com' && _googleUser != null) {
        return NetworkImage(_googleUser!.photoUrl ?? profilePhotoUrl);
      } else if (providerData.providerId == 'facebook.com' && _facebookAccessToken != null) {
        return NetworkImage('https://graph.facebook.com/${_facebookAccessToken!.userId}/picture');
      }
    }
    return NetworkImage(profilePhotoUrl);
  }

  String _getName(Map<String, dynamic>? userData) {
    if (_user != null && _user!.providerData.isNotEmpty) {
      var providerData = _user!.providerData.first;
      if (providerData.providerId == 'google.com' && _googleUser != null) {
        return _googleUser!.displayName ?? userData?['name'] ?? 'N/A';
      } else if (providerData.providerId == 'facebook.com' && _facebookAccessToken != null) {

        return userData?['name'] ?? 'N/A';
      }
    }
    return userData?['name'] ?? 'N/A';
  }

  String _getEmail(Map<String, dynamic>? userData) {
    if (_user != null && _user!.providerData.isNotEmpty) {
      var providerData = _user!.providerData.first;
      if (providerData.providerId == 'google.com' && _googleUser != null) {
        return _googleUser!.email ?? userData?['email'] ?? 'N/A';
      } else if (providerData.providerId == 'facebook.com' && _facebookAccessToken != null) {
        
        return userData?['email'] ?? '';
      }
    }
    return userData?['email'] ?? '';
  }
}
