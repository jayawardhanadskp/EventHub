
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class FirebaseAuthServicesCustomer {

  FirebaseAuth _auth = FirebaseAuth.instance;

  // firestore database to send data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //SignUp
  Future<User?> signUpWithEmailAndPassword(String email, String username, String password) async {

    try{
      UserCredential credential =await _auth.createUserWithEmailAndPassword(email: email, password: password);

          // firestore database to send data
          await _firestore.collection('customers').doc(credential.user!.uid).set({
            'email' : email,
            'fullName' : username,
          });

      return credential.user;

          // toast massage
    } on FirebaseAuthException catch (e) {

      if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(msg: 'The Email Alredy In Use ',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.red,
            fontSize: 17.0);
      } else {
        Fluttertoast.showToast(msg: 'Some Error Occurred : ${e.code} ',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.red,
            fontSize: 17.0);
      }

    }
    return null;

  }

  //SignIn
  Future<User?> signInWithEmailAndPassword(String email, String password) async {

    try{
      UserCredential credential =await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrond-password') {
        Fluttertoast.showToast(msg: 'InvalinEmail Or Password ',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.red,
        fontSize: 17.0);
    } else {
        Fluttertoast.showToast(msg: 'Some Error Occurred : ${e.code} ',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            textColor: Colors.red,
            fontSize: 17.0);
      }
    }
    return null;

  }

}