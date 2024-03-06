import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../views/profile/serviceprovider_profile_view.dart';

class ServicesAll extends StatefulWidget {
  const ServicesAll({Key? key}) : super(key: key);

  @override
  State<ServicesAll> createState() => _ServicesAllState();
}

class _ServicesAllState extends State<ServicesAll> {
  final TextEditingController _searchController = TextEditingController();
  List _resultList = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _allResults = [];
  late Future<List<String>> _favoriteStatusFuture;

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    super.initState();
    _favoriteStatusFuture = getFavoriteStatus();
    getServiceStream();
  }

  Future<String?> getCurrentUserId() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? currentUser = _auth.currentUser;

    return currentUser?.uid;
  }

  _onSearchChanged() {
    searchResultList();
  }

  searchResultList() {
    var showResults = [];
    if (_searchController.text != "") {
      for (var serviceSnapshot in _allResults) {
        var name = serviceSnapshot['service'].toString().toLowerCase();
        if (name.contains(_searchController.text)) {
          showResults.add(serviceSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }

    setState(() {
      _resultList = showResults;
    });
  }

  getServiceStream() async {
    var data = await FirebaseFirestore.instance
        .collection('service_providers')
        .orderBy('service')
        .get();

    setState(() {
      _allResults = data.docs;
    });
    searchResultList();
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
          // document exists, update the 'favorites' field
          await _collectionRef.doc(currentUser.uid).update({
            'favorites': FieldValue.arrayUnion([userId]),
          });
        } else {
          // document doesn't exist, create 'favorites' field
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

        // Show a popup animation
        _showFavoriteAnimation('Removed from favorites!');
      } else {
        print('User not authenticated');
      }
    } catch (error) {
      print('Error removing from favorites: $error');
    }
  }

  //  popup animation adding to favorites
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
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.deepPurple[600],
            expandedHeight: 190,
            floating: false,
            pinned: true,
            snap: false,
            leading: const BackButton(
              color: Colors.white,
            ),
            title: const Text(
              'All Services',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 8,
                      left: 8,
                      bottom: 20,
                    ),
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _resultList.isNotEmpty
              ? SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                List<String> photoUrls = List<String>.from(_allResults[index]['photos'] ?? []);
                String userId = _resultList[index].id;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceProviderProfileView(
                          userId: userId,
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
                                         child: Text(
                                           _resultList[index]['business_Name'],
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
                                           _resultList[index]['service'],
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
                                           _resultList[index]['address'],
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
                            right: 3,
                            child: FutureBuilder<List<String>>(
                              future: _favoriteStatusFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {

                                  return const CircularProgressIndicator();
                                } else {

                                  if (snapshot.hasError) {
                                    print('Error: ${snapshot.error}');
                                    return FavoriteButton(

                                      valueChanged: (isFavorite) {
                                        if (isFavorite) {
                                          addToFavorite(userId);
                                        } else {
                                          removeFromFavorite(userId);
                                        }
                                      },
                                      iconDisabledColor: Colors.white,
                                      iconSize: 50,
                                    );
                                  } else {

                                    List<String> favorites = snapshot.data ?? [];
                                    bool isFavorite = favorites.contains(userId);
                                    return GestureDetector(
                                      onTap: () {
                                        if (isFavorite) {
                                          removeFromFavorite(userId);
                                        } else {
                                          addToFavorite(userId);
                                        }
                                      },
                                      child: FavoriteButton(
                                        isFavorite: isFavorite,
                                        valueChanged: (isFavorite) {
                                          if (isFavorite) {
                                            addToFavorite(userId);
                                          } else {
                                            removeFromFavorite(userId);
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
              },
              childCount: _resultList.length,
            ),
          )
              : SliverToBoxAdapter(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 100,),
                  Image.asset('assets/noservice.jpg', scale: 2.5,),
                  const Text('No services', style: TextStyle(fontSize: 25, ),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
