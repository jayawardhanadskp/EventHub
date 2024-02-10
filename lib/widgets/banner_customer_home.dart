import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Banners extends StatefulWidget {
  @override
  State<Banners> createState() => _BannersState();
}

class _BannersState extends State<Banners> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List _bannerImage = [];
  final PageController _pageController = PageController();
  late Timer _timer;
  int _currentPage = 0;

  getBanners() {
    return _firestore
        .collection('banners')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          _bannerImage.add(doc['image']);
        });
      });
    });
  }

  @override
  void initState() {
    getBanners();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _bannerImage.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Colors.deepPurple[300],
            height: 400,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _bannerImage.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      _bannerImage[index],
                      fit: BoxFit.cover,
                    );
                  },
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                ),
                const Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 180.0, left: 10),
                      child: Text(
                        "Dream it,         plan it,               live it...",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.w900
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Text(
                    "${_currentPage + 1}/${_bannerImage.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
