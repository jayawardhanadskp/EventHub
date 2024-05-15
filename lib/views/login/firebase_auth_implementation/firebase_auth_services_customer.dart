import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class FirebaseAuthServicesCustomer {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // upload profile image
  Future<String> uploadImageToStorage(String uid, Uint8List file) async {
    Reference ref = _storage.ref().child('customer_profile_pic').child(uid).child('profilePicture.jpg');
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // sign Up with email and password
  Future<User?> signUpWithEmailAndPassword(String email, String username, String password, Uint8List file) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // store profile image
      String imageUrl = await uploadImageToStorage(credential.user!.uid, file);

      // firestore database to send data
      await _firestore.collection('customers').doc(credential.user!.uid).set({
        'email': email,
        'name': username,
        'photo': imageUrl,
        'signupTimestamp': FieldValue.serverTimestamp(),
      });

      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
          msg: 'The Email Already In Use ',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 17.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Some Error Occurred : ${e.code} ',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 17.0,
        );
      }
    }
    return null;
  }

  // sign In with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      // check if user exists in customers collection
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await _firestore.collection('customers').doc(credential.user!.uid).get();

      if (userSnapshot.exists) {

        return credential.user;
      } else {
        // user not found in the customers collection
        await _auth.signOut();
        Fluttertoast.showToast(
          msg: 'Invalid Email Or Password ',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 17.0,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        Fluttertoast.showToast(
          msg: 'Invalid Email Or Password ',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 17.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Some Error Occurred : ${e.code} ',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: Colors.black,
          fontSize: 17.0,
        );
      }
    }
    return null;
  }

}
