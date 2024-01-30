import 'package:eventhub/views/profile/serviceprovider_profile_edit.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProviderProfile extends StatefulWidget {
  final String? userId;

  const ServiceProviderProfile({Key? key, this.userId}) : super(key: key);

  @override
  _ServiceProviderProfileState createState() => _ServiceProviderProfileState();
}

class _ServiceProviderProfileState extends State<ServiceProviderProfile>
with SingleTickerProviderStateMixin {

  // for banners
  final PageController _pageController = PageController();
  int _currentPage = 0;

  //for pricing tab bar
  late TabController _tabController;

  late User? _user;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    _getUserDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      backgroundColor: Colors.deepPurple[100],
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
          future: FirebaseFirestore.instance
              .collection('service_providers')
              .doc(_user?.uid)
              .get(),
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
              Map<String, dynamic>? serviceProviderData = snapshot.data!.data();
              List<String> photoUrls =
              List<String>.from(serviceProviderData?['photos'] ?? []);

              String serviceProviderId = _user?.uid ?? '';

              return Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 280,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: photoUrls.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                photoUrls[index],
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Text(
                              "${_currentPage + 1}/${photoUrls.length}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 90,
                      width: double.infinity,
                      color: Colors.deepPurple[400],
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                  photoUrls.isNotEmpty ? photoUrls[0] : ''),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${serviceProviderData?['name']}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Service: ${serviceProviderData?['service']}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        color: Colors.deepPurple[200],
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(13.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Business Name: ${serviceProviderData?['business_Name']}',
                                style: const TextStyle(color: Colors.white, fontSize: 17),),
                              const SizedBox(height: 5,),
                              Text('Description: ${serviceProviderData?['description']}',
                                style: const TextStyle(color: Colors.white, fontSize: 17),),
                              const SizedBox(height: 10, ),
                              const Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        thickness: 5.0,
                                        color: Colors.white,
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            Container(
                              height: 120,
                              width: MediaQuery.of(context).size.height,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: TabBar(
                                      controller: _tabController,
                                        labelColor: Colors.deepPurple,
                                        unselectedLabelColor: Colors.white,
                                        indicatorColor: Colors.white,
                                        indicatorWeight: 2,
                                        indicatorSize: TabBarIndicatorSize.tab,
                                        indicator: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(5)
                                        ),
                                        tabs: const [
                                          Tab(
                                            text: 'Plan 1',
                                          ),
                                          Tab(
                                            text: 'Plan 2',
                                          ),
                                          Tab(
                                            text: 'Plan 3',
                                          ),
                                        ]
                                    ),
                                  ),
                                  Expanded(
                                      child: TabBarView(
                                        controller: _tabController,
                                        children: [
                                          Column(
                                            children: [
                                              Text('Pricing: ${serviceProviderData?['pricing_plan_1']}',
                                                style: const TextStyle(color: Colors.white, fontSize: 17),),
                                              Text('Pricing: ${serviceProviderData?['pricing_plan_1_price']}',
                                                style: const TextStyle(color: Colors.white, fontSize: 17),),
                                            ],
                                          ),

                                          Column(
                                            children: [
                                              Text('Pricing: ${serviceProviderData?['pricing_plan_2']}',
                                                style: const TextStyle(color: Colors.white, fontSize: 17),),
                                              Text('Pricing: ${serviceProviderData?['pricing_plan_2_price']}',
                                                style: const TextStyle(color: Colors.white, fontSize: 17),),
                                            ],
                                          ),

                                          Column(
                                            children: [
                                              Text('Pricing: ${serviceProviderData?['pricing_plan_3']}',
                                                style: const TextStyle(color: Colors.white, fontSize: 17),),
                                              Text('Pricing: ${serviceProviderData?['pricing_plan_3_price']}',
                                                style: const TextStyle(color: Colors.white, fontSize: 17),),
                                            ],
                                          ),
                                        ],
                                      ),
                                  )

                                ],
                              ),
                            ),

                              const SizedBox(height: 10,),
                              ElevatedButton(
                                onPressed: () async {
                                  bool dataUpdated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ServiceProviderProfileEdit(userId: _user?.uid),
                                    ),
                                  );
                                  if (dataUpdated == true) {
                                    await _getUserDetails();
                                    setState(() {});
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  padding: const EdgeInsets.all(15.0),
                                  fixedSize: const Size(380, 60),
                                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  primary: Colors.deepPurple[400],
                                  onPrimary: Colors.white,
                                  elevation: 10,
                                  shadowColor: Colors.blue.shade900,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit, color: Colors.white),
                                    SizedBox(width: 10),
                                    Text("Add or Change Description and Pricing"),
                                  ],
                                ),
                              ),



                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10, ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 13.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10, ),
                              Text('Email: ${serviceProviderData?['email']}',
                                style: const TextStyle(color: Colors.black45, fontSize: 17),),
                              Text('Phone: ${serviceProviderData?['phone']}',
                                style: const TextStyle(color: Colors.black45, fontSize: 17),),
                              Text('Address: ${serviceProviderData?['address']}',
                                style: const TextStyle(color: Colors.black45, fontSize: 17),),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            bool dataUpdated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceProviderProfileEdit(
                                    userId: _user?.uid,
                                  initialTabIndex: 1,
                                ),
                              ),
                            );
                            if (dataUpdated == true) {
                              await _getUserDetails();
                              setState(() {});
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: const EdgeInsets.all(15.0),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            primary: Colors.deepPurple[400],
                            onPrimary: Colors.white,
                            elevation: 10,
                            shadowColor: Colors.blue.shade900,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit, color: Colors.white),
                              SizedBox(width: 10),
                              Text("Edit Profile"),
                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
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
    );
  }
}
