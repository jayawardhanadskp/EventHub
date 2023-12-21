
import 'package:eventhub/views/login/firebase_auth_implementation/firebase_auth_services_customer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../model/customer_home.dart';
import '../../home/customer_home.dart';
import '../../onbord_screen.dart';
import 'customer_login.dart';



class customerSignUpPage extends StatefulWidget {
  const customerSignUpPage({super.key});

  @override
  State<customerSignUpPage> createState() => _customerSignUpPageState();
}





class _customerSignUpPageState extends State<customerSignUpPage> {

  bool _isSigninUp = false;

  // firebase
  final FirebaseAuthServicesCustomer _auth = FirebaseAuthServicesCustomer();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
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
          child: Form(

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
                  height: 20,
                ),

                const Text(
                  "A Service Seeker ? Just Fill It ! ",
                  style: TextStyle(color: Colors.white,
                    fontSize: 19,
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
                      labelText: 'Full Name',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),

                    controller: _usernameController,

                    validator: (value) {
                      if (value == null || value.isEmpty){
                        return "Please Enter Your Name";
                      } return null;
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
                    decoration: InputDecoration(
                      labelText: 'Email',
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
                        padding: EdgeInsets.only(right: 0.0),
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
                  height: 20,
                ),

                Container(
                  width: 350,
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    obscureText: _isObstract,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixIcon: const Icon(
                        Icons.confirmation_number_outlined,
                        color: Colors.white,
                      ),
                      suffixIcon: IconButton(
                        padding: EdgeInsets.only(right: 0.0),
                        iconSize: 25.0, // Set the desired icon size
                        icon: _isObstract
                            ? Icon(Icons.visibility_off, color: Colors.white)
                            : Icon(Icons.visibility, color: Colors.white),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    controller: _confirmPassController,

                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                ElevatedButton(
                  onPressed: _signUp,

                  child: _isSigninUp ? CircularProgressIndicator(color: Colors.blue.shade900,):
                  Text("SIGN UP"),
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
                  height: 9,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  CustomerLogin()),
                    );
                  },
                  child: Text('Have an account? Log In',
                    style: TextStyle(color: Colors.white, fontSize: 17),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // signup
  void _signUp() async {

    setState(() {
      _isSigninUp = true;
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmpass = _confirmPassController.text;


    try {
      User? user = await _auth.signUpWithEmailAndPassword( email, username, password);

      setState(() {
        _isSigninUp = false;
      });

      //password and confirm password validation
      if (_passwordController.text != _confirmPassController.text) {
        Fluttertoast.showToast(msg: 'Passwords DoNot Match ',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 17.0);
      }

      if (user != null) {
        Fluttertoast.showToast(msg: 'User Is Successfully Created ',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 17.0);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  customerHomePage()),
        );
      } else {
        Fluttertoast.showToast(msg: 'Check All The Fields Are Filled',
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  customerHomePage()),
        );
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => customerHomePage()),
        );
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
