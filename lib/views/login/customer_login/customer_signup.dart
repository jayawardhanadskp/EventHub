
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventhub/views/login/firebase_auth_implementation/firebase_auth_services_customer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../../home/customer_home.dart';
import '../../onbord_screen.dart';
import 'customer_login.dart';
import 'package:eventhub/controller/image_pick_reg.dart';




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

  // image picker
  Uint8List? _image;
  void selectImage() async{
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }


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
                  height: 10,
                ),

                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  const OnbordScreen()),
                    );
                  },
                  child: Image.asset('assets/logo_home.jpg'),
                ),



                const Text(
                  "A Service Seeker ? Just Fill It ! ",
                  style: TextStyle(color: Colors.white,
                    fontSize: 19,
                  ),
                ),

                const SizedBox(
                  height: 1,
                ),

                Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(70),
                    gradient: const LinearGradient(
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
                      _image != null ?
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: MemoryImage(_image! ),
                          )
                      :
                      const CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/avatar.png'),
                      ),
                      Positioned(
                          bottom: -10,
                        left: 65,
                          child: IconButton(
                            onPressed: selectImage,
                            icon: const Icon(Icons.add_a_photo,
                              color: Colors.white, size: 40,),
                          ),
                      )
                    ],
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Container(

                  width: 350,
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixIcon: Icon(
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
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixIcon: Icon(
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
                    style: const TextStyle(color: Colors.white),
                    obscureText: _isObstract,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixIcon: const Icon(
                        Icons.password,
                        color: Colors.white,
                      ),
                      suffixIcon: IconButton(
                        padding: const EdgeInsets.only(right: 0.0),
                        iconSize: 25.0, // Set the desired icon size
                        icon: _isObstract
                            ? const Icon(Icons.visibility_off, color: Colors.white)
                            : const Icon(Icons.visibility, color: Colors.white),
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
                    style: const TextStyle(color: Colors.white),
                    obscureText: _isObstract,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixIcon: const Icon(
                        Icons.confirmation_number_outlined,
                        color: Colors.white,
                      ),
                      suffixIcon: IconButton(
                        padding: const EdgeInsets.only(right: 0.0),
                        iconSize: 25.0, // Set the desired icon size
                        icon: _isObstract
                            ? const Icon(Icons.visibility_off, color: Colors.white)
                            : const Icon(Icons.visibility, color: Colors.white),
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
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: const EdgeInsets.all(15.0),
                    fixedSize: const Size(230, 60),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade900,
                    elevation: 10,
                    shadowColor: Colors.blue.shade900,
                  ),

                  child: _isSigninUp ? CircularProgressIndicator(color: Colors.blue.shade900,):
                  const Text("SIGN UP"),
                ),

                const SizedBox(
                  height: 5,
                ),

                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      Expanded(child: Divider(
                        thickness: 0.9,
                        color: Colors.white,
                      ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text("Or Continue With",
                          style: TextStyle(color: Colors.white),),
                      ),

                      Expanded(child: Divider(
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
                      onTap: () => _signInWithGoogle(),
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
                      MaterialPageRoute(builder: (context) =>  const CustomerLogin()),
                    );
                  },
                  child: const Text('Have an account? Log In',
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
      User? user = await _auth.signUpWithEmailAndPassword( email, username, password, _image!);

      setState(() {
        _isSigninUp = false;
      });

      //password and confirm password validation
      if (_passwordController.text != _confirmPassController.text) {
        Fluttertoast.showToast(
          msg: 'Passwords Do Not Match ',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 17.0,
        );
        return;
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

  // to get google and facebook sign in to save data on firestore
  void saveUserDataToFirestore(User? user) async {
    if (user != null) {
      String uid = user.uid;
      String username = user.displayName ?? '';
      String email = user.email ?? '';
      String imageUrl = user.photoURL ?? '';

      await FirebaseFirestore.instance.collection('customers').doc(uid).set({
        'email': email,
        'name': username,
        'photo': imageUrl,

      });
    }
  }

  // sign in with google
  _signInWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = authResult.user;

        saveUserDataToFirestore(user);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => customerHomePage()),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e ',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.red,
        fontSize: 17.0,
      );
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
