import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../views/profile/serviceprovider_profile_view.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late User currentUser;

  late Future<List<String>> _favoriteStatusFuture;

  @override
  void initState() {
    super.initState();
    _favoriteStatusFuture = getFavoriteStatus();

    currentUser = FirebaseAuth.instance.currentUser!;
  }

  Future<String?> getCurrentUserId() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? currentUser = _auth.currentUser;

    return currentUser?.uid;
  }

  Future<List<String>> getFavoriteStatus() async {
    final String? userId = await getCurrentUserId();
    if (userId != null) {
      DocumentSnapshot<Object?> userDocument =
      await FirebaseFirestore.instance.collection('customers').doc(userId).get();

      if (userDocument.exists) {
        List<String> favorites = List<String>.from(userDocument['favorites'] ?? []);
        return favorites;
      }
    }
    return [];
  }

  Future<void> addToFavorite(String userId) async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      var currentUser = _auth.currentUser;

      if (currentUser != null) {
        CollectionReference _collectionRef = FirebaseFirestore.instance.collection('customers');

        // check if the document exists before updating
        DocumentSnapshot<Object?> userDocument = await _collectionRef.doc(currentUser.uid).get();

        if (userDocument.exists) {
          // document exists, update the field
          await _collectionRef.doc(currentUser.uid).update({
            'favorites': FieldValue.arrayUnion([userId]),
          });
        } else {
          //  doesn't exist, create
          await _collectionRef.doc(currentUser.uid).set({
            'favorites': [userId],
          });
        }


        _showFavoriteAnimation('Added to favorites!');
      } else {
        print('User not authenticated');
      }
    } catch (error) {
      print('Error adding to favorites: $error');
    }
  }

  Future<void> removeFromFavorite(String userId) async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      var currentUser = _auth.currentUser;

      if (currentUser != null) {
        CollectionReference _collectionRef = FirebaseFirestore.instance.collection('customers');

        // check if the document exists before updating
        DocumentSnapshot<Object?> userDocument = await _collectionRef.doc(currentUser.uid).get();

        if (userDocument.exists) {
          // document exists, update the 'favorites' field
          await _collectionRef.doc(currentUser.uid).update({
            'favorites': FieldValue.arrayRemove([userId]),
          });
        }


        _showFavoriteAnimation('Removed from favorites!');
      } else {
        print('User not authenticated');
      }
    } catch (error) {
      print('Error removing from favorites: $error');
    }
  }


  void _showFavoriteAnimation(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('customers').doc(currentUser.uid).get(),
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
            List<String> favorites = List<String>.from(userData?['favorites'] ?? []);

            if (favorites.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    const SizedBox(height: 100,),
                    Image.asset('assets/favorite.png', scale: 5,),
                    const Text('No favorites', style: TextStyle(fontSize: 25, ),),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance.collection('service_providers').doc(favorites[index]).get(),
                  builder: (context, providerSnapshot) {
                    if (providerSnapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        title: Text('Loading...'),
                      );
                    } else if (providerSnapshot.hasError) {
                      return ListTile(
                        title: Text('Error: ${providerSnapshot.error}'),
                      );
                    } else if (providerSnapshot.hasData && providerSnapshot.data!.exists) {
                      Map<String, dynamic>? serviceProviderData = providerSnapshot.data!.data();
                      List<String> photoUrls = List<String>.from(serviceProviderData?['photos'] ?? []);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceProviderProfileView(
                                userId: favorites[index],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[200],
                              borderRadius: const BorderRadius.all(Radius.circular(12)),
                            ),
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 170,
                                      height: double.infinity,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8.0),
                                          bottomLeft: Radius.circular(8.0),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          bottomLeft: Radius.circular(8),
                                        ),
                                        child: Image.network(
                                          photoUrls.isNotEmpty ? photoUrls[0] : '',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 30,
                                            decoration: const BoxDecoration(),
                                            child: Text(serviceProviderData?['business_Name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            ),
                                          ),


                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 30,
                                            decoration: const BoxDecoration(),
                                            child: Text(
                                              serviceProviderData?['service'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 30,
                                            decoration: const BoxDecoration(),
                                            child: Text(
                                              serviceProviderData?['address'],
                                              style: const TextStyle(
                                                color: Colors.white60,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: FutureBuilder<List<String>>(
                                    future: _favoriteStatusFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {

                                        return const CircularProgressIndicator();
                                      } else {

                                        if (snapshot.hasError) {
                                          print('Error: ${snapshot.error}');
                                          return const Text('Error loading favorite status');
                                        } else {

                                          List<String> favorites = snapshot.data ?? [];
                                          bool isFavorite = favorites.contains(favorites[index]);
                                          return GestureDetector(
                                            onTap: () {
                                              if (isFavorite) {
                                                removeFromFavorite(favorites[index]);
                                              } else {
                                                addToFavorite(favorites[index]);
                                              }
                                            },
                                            child: FavoriteButton(
                                              isFavorite: isFavorite,
                                              valueChanged: (isFavorite) {
                                                if (isFavorite) {
                                                  addToFavorite(favorites[index]);
                                                } else {
                                                  removeFromFavorite(favorites[index]);
                                                }
                                              },
                                              iconDisabledColor: Colors.white,
                                              iconSize: 50,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const ListTile(
                        title: Text('No Data'),
                      );
                    }
                  },
                );
              },
            );
          } else {
            return const Center(
              child: Text('No Favorites'),
            );
          }
        },
      ),
    );
  }
}
