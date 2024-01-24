
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../views/profile/serviceprovider_profile.dart';

class ServicesAll extends StatefulWidget {
  const ServicesAll({Key? key}) : super(key: key);

  @override
  State<ServicesAll> createState() => _ServicesAllState();
}

class _ServicesAllState extends State<ServicesAll> {


  // for search
  final TextEditingController _searchController = TextEditingController();
  List _resultList = [];

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _allResults = [];

  @override
  void initState() {

    // searcher
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  _onSearchChanged() {
    print(_searchController.text);
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
    searchResultList();
  }

  // get from firebase
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
  @override
  void didChangeDependencies() {
    getServiceStream();
    super.didChangeDependencies();
  }


  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],

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

            title: const Text('All Services', style:
              TextStyle(color: Colors.white, fontSize: 25),),

          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 80,
                child: Padding(
                  padding:  const EdgeInsets.only(right: 8, left: 8, bottom: 20,),
                  child: CupertinoSearchTextField(
                    controller: _searchController,
                    decoration:  const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),

                    ),

                  ),
                ),
              ),
            ],
          ),
          ),




          SliverList.builder(
            itemCount: _resultList.length,
            itemBuilder: (BuildContext context, int index) {
              List<String> photoUrls = List<String>.from(_allResults[index]['photos'] ?? []);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceProviderProfile(
                        userId: _resultList[index]['user_id'],
                      ),
                    ),
                  );
                },

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[200],
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Row(
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                height: 40,
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
                            SizedBox(
                              height: 40,
                              child: Text(
                                _resultList[index]['service'],
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                              child: Text(_resultList[index]['address']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

        ],
      ),






    );
  }
}
