import 'package:eventhub/views/login/serviceprovider_login/serviceprovider_signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/icons.dart';
import 'package:flutter/src/material/icon_button.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../model/customer_home.dart';
import '../../profile/serviceprovider_profile.dart';
import '../../onbord_screen.dart';
import '../firebase_auth_implementation/firebase_auth_services_customer.dart';


class ServiceProviderLogin extends StatefulWidget {
  const ServiceProviderLogin({super.key});

  @override
  State<ServiceProviderLogin> createState() => _CustomerLoginState();
}

class _CustomerLoginState extends State<ServiceProviderLogin> {

  bool _isSigning = false;

  // Firebase
  final FirebaseAuthServicesCustomer _auth = FirebaseAuthServicesCustomer();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // for password visibility button
  bool _isObstract = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(

            children: [
              const SizedBox(
                height: 50,
              ),

              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  OnbordScreen()),
                  );
                },
                child: Image.asset('assets/logo_home.jpg'),
              ),

              const SizedBox(
                height: 50,
              ),

              const Icon(
                Icons.lock,
                size: 70,
                color: Colors.white,
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                "Welcome Back You\'ve been missed!",
                style: TextStyle(color: Colors.white,
                  fontSize: 17,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Container(
                width: 350,
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.white,
                    ),
                  ),
                  controller: _emailController,

                  // email validator
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Plese Enter Email';
                    } else {
                      return null;
                    }

                  },
                ),
              ),


              const SizedBox(
                height: 20,
              ),
              Container(
                width: 350,
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  obscureText: _isObstract,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    prefixIcon: const Icon(
                      Icons.password,
                      color: Colors.white,
                    ),
                    suffixIcon: IconButton(
                      padding: EdgeInsets.only(right: 0.0), // Adjust padding
                      iconSize: 25.0, // Set the desired icon size
                      icon: _isObstract
                          ? Icon(Icons.visibility_off, color: Colors.white)
                          : Icon(Icons.visibility, color: Colors.white),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  controller: _passwordController,
                ),
              ),

              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: _signIn,
                child:
                _isSigning ? CircularProgressIndicator(color: Colors.blue.shade900): Text("LOGIN"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: EdgeInsets.all(15.0),
                  fixedSize: Size(230, 60),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  primary: Colors.white,
                  onPrimary: Colors.blue.shade900,
                  elevation: 10,
                  shadowColor: Colors.blue.shade900,
                ),
              ),

              const SizedBox(
                height: 13,
              ),

              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Expanded(child: const Divider(
                      thickness: 0.9,
                      color: Colors.white,
                    ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: const Text("Or Continue With",
                        style: TextStyle(color: Colors.white),),
                    ),

                    Expanded(child: const Divider(
                      thickness: 0.9,
                      color: Colors.white,
                    ),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  InkWell(
                    onTap: _signInWithGoogle,
                    borderRadius: BorderRadius.circular(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/google-logo-for_button.jpg',
                        height: 70,

                      ),
                    ),
                  ),


                  const SizedBox(
                    width: 30,
                  ),

                  InkWell(
                    onTap: _signInWithFacebook,
                    borderRadius: BorderRadius.circular(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/facebook-f-logo-for-button.jpg',
                        height: 70,

                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => serviceProviderSignUp()),
                  );
                },
                child: const Text('Don\'t have an account? Sign Up',
                  style: TextStyle(color: Colors.white, fontSize: 17),),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // SignIn Method
  void _signIn() async {

    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      User? user = await _auth.signInWithEmailAndPassword(email, password);

      setState(() {
        _isSigning = false;
      });

      if (user != null) {
        Fluttertoast.showToast(msg: 'User is Successfully SigndIn',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 17.0);
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => ServiceProviderProfile())
        );

      } else {
        Fluttertoast.showToast(msg: 'Some Error Occurred',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.red,
            fontSize: 17.0);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e ',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.red,
          fontSize: 17.0);
    }
  }

  //password visibility button
  void _togglePasswordVisibility() => setState(() => _isObstract = !_isObstract);

  // sign in with google
  _signInWithGoogle()async{
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    try{
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await
        googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
  //      Navigator.push(
  //        context,
  //        MaterialPageRoute(builder: (context) =>  customerHomePage()),
  //      );
      }

    } catch(e) {

      Fluttertoast.showToast(msg: 'Error: $e ',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.red,
          fontSize: 17.0);
    }
  }



// Sign in with Facebook
  Future<void> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
        await FirebaseAuth.instance.signInWithCredential(credential);
  //      Navigator.push(
  //        context,
  //        MaterialPageRoute(builder: (context) => customerHomePage()),
  //      );
      } else if (result.status == LoginStatus.cancelled) {

        Fluttertoast.showToast(
          msg: 'Facebook login cancelled',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.red,
          fontSize: 17.0,
        );
      } else {

        Fluttertoast.showToast(
          msg: 'Error: ${result.message}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.red,
          fontSize: 17.0,
        );
      }
    } catch (e) {

      Fluttertoast.showToast(
        msg: 'Error: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.red,
        fontSize: 17.0,
      );
    }
  }


}
