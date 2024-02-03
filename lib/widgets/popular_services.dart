import 'package:flutter/material.dart';

import '../views/profile/customer_profile.dart';



class popularServiceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Popular Services',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileCustomer()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[600],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/event-planners.png',
                            width: 120,
                            height: 108,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 2), // Optional spacing
                        const Text(
                          'Event Planners',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 3,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[600],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/venus.jpg',
                            width: 120,
                            height: 108,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 2), // Optional spacing
                        const Text(
                          'Venues',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 3,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[600],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/photographer.jpg',
                            width: 120,
                            height: 108,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 2), // Optional spacing
                        const Text(
                          'Photographers',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 3,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[600],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/florists.jpeg',
                            width: 120,
                            height: 108,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Florists',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 3,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[600],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/entertainers.png',
                            width: 120,
                            height: 108,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Entertainers',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 3,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[600],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/wedding-planner.png',
                            width: 120,
                            height: 108,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Wedding Planner',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[600],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/bar-service.jpg',
                            width: 120,
                            height: 108,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Bar Services',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 3,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
