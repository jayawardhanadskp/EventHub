import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'login/customer_login/customer_login.dart';
import 'login/serviceprovider_login/serviceprovider_login.dart';

class OnbordScreen extends StatelessWidget {
  const OnbordScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('assets/logo_home.jpg'),
              ],
            ),
          ),
          Expanded(
            child: ClipPath(
              clipper: CurvedShapeClipper(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                color: Colors.lightBlue.shade50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Lottie.network(
                      'https://lottie.host/5cdd36cc-4b30-4943-951a-c398b402ef75/q7ReKCNFB5.json',
                      height: 300,
                      width: double.infinity,
                      repeat: true,
                      reverse: false,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Platform for EVENT Collaboration",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black54,
                        fontFamily: 'anton',
                      ),
                    ),
                    SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomerLogin(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: EdgeInsets.all(20.0),
                        textStyle: TextStyle(
                          fontSize: 23.5,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade900,
                        elevation: 15,
                        shadowColor: Colors.blue.shade900,
                        fixedSize: Size(400, 80),
                      ),
                      child: const Text("SERVICE SEEKER"),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ServiceProviderLogin(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: EdgeInsets.all(20.0),
                        textStyle: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade900,
                        elevation: 15,
                        shadowColor: Colors.blue.shade900,
                        fixedSize: Size(400, 80),
                      ),
                      child: const Text("SERVICE PROVIDER"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurvedShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width / 4, size.height, size.width / 2, size.height - 30);
    path.quadraticBezierTo(3 * size.width / 4, size.height - 60, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
