import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              InkWell(
                onTap: () {
                  // Handle image selection
                },
                child: Container(
                  width: 120,
                  height: 120,
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade900,
                    borderRadius: BorderRadius.circular(70),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xff7DDCFB),
                        Color(0xffBC67F2),
                        Color(0xffACF6AF),
                        Color(0xffF95549),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.blue,
                          size: 50,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
              // Add text fields for First Name, Last Name, Mobile Number, and Date of Birth
              // TextField for First Name
              // TextField for Last Name
              // TextField for Mobile Number
              // TextField for Date of Birth
              // Add radio buttons for gender selection
              // ElevatedButton for Save
              ElevatedButton(
                onPressed: () {
                  // Add save functionality here
                },
                child: Text("Save"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(15.0),
                  fixedSize: Size(200, 50),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  primary: Colors.blue.shade900,
                  onPrimary: Colors.white,
                  elevation: 10,
                  shadowColor: Colors.blue.shade900,
                ),
              ),
              SizedBox(height: 20),
              // Add a text for terms and policies
              Text(
                'By signing up, you agree to our terms, Data policy, and cookies policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff262628),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
