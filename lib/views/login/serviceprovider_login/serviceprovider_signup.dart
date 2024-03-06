import 'dart:collection';
import 'dart:typed_data';
import 'dart:io';

import 'package:eventhub/views/login/serviceprovider_login/serviceprovider_login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:popover/popover.dart';
import 'package:image_picker/image_picker.dart';

import '../../../widgets/description_services.dart';
import '../../onbord_screen.dart';
import 'package:eventhub/controller/image_pick_reg.dart';

class serviceProviderSignUp extends StatefulWidget {
  @override
  _serviceProviderSignUpState createState() => _serviceProviderSignUpState();
}

class _serviceProviderSignUpState extends State<serviceProviderSignUp> {

  // for password visibility button
  bool _isObstract = true;
  void _togglePasswordVisibility() => setState(() => _isObstract = !_isObstract);

  // for sing up animation
  bool _isSigninUp = false;

  // for validator
 final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  String _name = '';
  String _email = '';
  var _phone = '';
  String _selectedService = '';
  String _address = '';
  String _buisnessName = '';
  String _password = '';



  // image picker
  List<Uint8List?> _photos = [null, null, null, null];




  final FirebaseStorage _storage = FirebaseStorage.instance;

  void selectImage(int index) async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _photos[index] = img;
    });
  }

  // for images
  Future<List<String>> uploadImagesToStorage(String uid, List<Uint8List?> files) async {
    List<String> downloadUrls = [];

    for (int i = 0; i < files.length; i++) {
      if (files[i] != null) {
        Reference ref = _storage.ref().child('serviceprovider_photos').child(uid).child('servicePicture_$i.jpg');
        UploadTask uploadTask = ref.putData(files[i]!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }
    }

    return downloadUrls;
  }

  Uint8List? file;
  // image picker profile photo
  Uint8List? _image;
  void selectPhoto() async{
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  // upload profile image
  Future<String> uploadImageToStorage(String uid, Uint8List file) async {
    Reference ref = _storage.ref().child('serviceprovider_photo').child(uid).child('photo.jpg');
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }


  String selectedValue = 'default';

  Widget _controlsBuilder(context, details) {
    if (_currentStep == 2) {
      // sign Up button on last step
      return Row(
        children: [
          ElevatedButton(
            onPressed: details.onStepCancel,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.all(15.0),
              fixedSize: const Size(80, 60),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              elevation: 10,
              shadowColor: Colors.blue.shade900,
            ),
            child: const Text("Back"),
          ),
          const SizedBox(width: 5,),
          ElevatedButton(
            onPressed: () async {

             
              setState(() {
                _isSigninUp = true;
              });


                try {
                  UserCredential userCredential =
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: _email,
                    password: _password,


                  );


                  // store  images
                  List<String> imageUrls = await uploadImagesToStorage(userCredential.user!.uid, _photos);

                  // store profile image
                  String imageUrl = await uploadImageToStorage(userCredential.user!.uid, _image!);


                  // Store user details in Firestore
                  await FirebaseFirestore.instance.collection('service_providers').doc(userCredential.user!.uid).set({
                    'name': _name,
                    'email': _email,
                    'phone': _phone,
                    'service': _selectedService,
                    'address': _address,
                    'business_Name' : _buisnessName,
                    'photos': imageUrls,
                    'photo': imageUrl,
                    'signupTimestamp': FieldValue.serverTimestamp(),
                  });

                  Fluttertoast.showToast(msg: 'User Is Successfully Created ',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 17.0);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  const ServiceProviderLogin()),
                  );

                } on FirebaseAuthException catch (e) {
                  Fluttertoast.showToast(msg: 'Error: $e ',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.white,
                      textColor: Colors.red,
                      fontSize: 17.0);
                }

            },
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
              shadowColor: Colors.white,
            ),
            child: _isSigninUp ? CircularProgressIndicator(color: Colors.blue.shade900,):
            const Text(
              'Sign Up',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    } else {
      //  Next and Back buttons
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: details.onStepCancel,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.all(15.0),
              fixedSize: const Size(150, 60),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              elevation: 10,
              shadowColor: Colors.blue.shade900,
            ),
            child: const Text("Back"),
          ),
          const SizedBox(width: 10,),
          ElevatedButton(
            onPressed: details.onStepContinue,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.all(15.0),
              fixedSize: const Size(150, 60),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade900,
              elevation: 10,
              shadowColor: Colors.blue.shade900,
            ),
            child: const Text("Next"),
          ),
        ],
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Container(
        child: SingleChildScrollView(
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
              Stepper(
                key:_formKey,
                currentStep: _currentStep,
                onStepContinue: () {


                  if (_currentStep == 0) {
                    if (_name.isNotEmpty && _email.isNotEmpty && _password.isNotEmpty && _phone.isNotEmpty ) {
                      setState(() {
                        _currentStep += 1;
                      });
                    } else {
                      print('Name, Email, and Password are required.');
                    }
                  } else if (_currentStep == 1) {
                    if (_selectedService.isNotEmpty && _buisnessName.isNotEmpty && _address.isNotEmpty) {
                      setState(() {
                        _currentStep += 1;
                      });
                    } else {
                      print('Please select a service.');
                    }
                  } else if (_currentStep == 2) {
                    if (_photos.isEmpty) {
                      print('Please add at least one photo.');
                    } else {
                      setState(() {
                        _currentStep += 1;
                      });
                    }
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep -= 1;
                    });
                  }
                },
                controlsBuilder: _controlsBuilder,
                steps: [
                  Step(
                    title: const Text(
                      'Personal Information',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                      ),
                    ),
                    content: Column(
                      children: [
                        const SizedBox(
                          height: 10,
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
                                  onPressed: selectPhoto,
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
                            onChanged: (value) => _name = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Full Name is required';
                              }
                              return null;
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
                            onChanged: (value) => _email = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
                                return 'Enter a valid email address';
                              }
                              return null;
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
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              prefixIcon: Icon(
                                Icons.phone,
                                color: Colors.white,
                              ),
                            ),
                            onChanged: (value) => _phone = value,
                            validator: (value) {
                              if ((value ?? '').length < 1 && (value ?? '').length > 12) {
                                return 'Enter Valid Phone Number';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Container(
                          width: 350,
                          child: TextFormField(
                            obscureText: _isObstract, // Hide the password
                            style: const TextStyle(color: Colors.white),
                            decoration:  InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.white),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock,
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
                            onChanged: (value) => _password = value,
                            validator: (value) {
                              if ((value ?? '').length < 6) {
                                return 'Password must be at least six characters';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20,),

                      ],
                    ),
                    isActive: _currentStep == 0,
                  ),


                  Step(
                    title: const Text(
                      'Business Information',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                      ),
                    ),
                    content: Container(


                      child: Column(

                        children: [
                          GestureDetector(

                            onTap: () => showDialog(
                                context: context,
                                builder: (context) => const desciptionServices(),
                            ),
                            child: const Icon(Icons.report_problem, color: Colors.white,),
                          ),

                          DropdownButtonFormField<String>(
                            value: selectedValue,
                            onChanged: (String? value) {
                              setState(() {
                                selectedValue = value!;
                                _selectedService = value;
                              });
                            },
                            dropdownColor: Colors.deepPurple[400],
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 20), // Style for the selected value
                            icon: const Icon(Icons.arrow_drop_down_outlined, color: Colors.white),


                            items: const [
                              DropdownMenuItem<String>(
                                value: 'default',
                                child: Text('Select Service', style: TextStyle(color: Colors.white38)),
                              ),

                              DropdownMenuItem<String>(
                                value: 'Event Planner',
                                child:Text('Event Planner', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'A Venues Provider',
                                child: Text('A Venues Provider', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Caterer',
                                child: Text('Caterer', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Bakers and Cake Designer',
                                child: Text('Bakers and Cake Designer', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Bar Services',
                                child: Text('Bar Services', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Photographer',
                                child: Text('Photographer', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Videographer',
                                child: Text('Videographer', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Makeup Artists / Hair Stylist',
                                child: Text('Makeup Artists / Hair Stylist', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Decorator',
                                child: Text('Decorator', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Florist',
                                child: Text('Florist', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Entertainer',
                                child: Text('Entertainer', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Rental',
                                child: Text('Rental', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Technical Supporter',
                                child: Text('Technical Supporter', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Transportation Service',
                                child: Text('Transportation Service', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Event Staff Provider',
                                child: Text('Event Staff Provider', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Printers / Stationery Designer',
                                child: Text('Printers / Stationery Designer', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Security Services',
                                child: Text('Security Services', style: TextStyle(color: Colors.white)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Wedding Planner',
                                child: Text('Wedding Planner', style: TextStyle(color: Colors.white)),
                              ),


                            ],
                          ),

                          const SizedBox(height: 20,),

                          Container(
                            width: 350,
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Business Address',
                                labelStyle: TextStyle(color: Colors.white),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                ),
                              ),
                              onChanged: (value) => _address = value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Address is required';
                                }
                                return null;
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
                                labelText: 'Business Name',
                                labelStyle: TextStyle(color: Colors.white),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                prefixIcon: Icon(
                                  Icons.business_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              onChanged: (value) => _buisnessName = value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Business Name is required';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                        ],
                      ),
                    ),
                    isActive: _currentStep == 1,
                  ),


                  Step(
                    title: const Text(
                      'Add Photos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                      ),
                    ),
                    content: Container(
                      height: 340,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 18.0),
                            child: Row(
                              children: [
                                Text("Add Your Logo First", style: TextStyle(color: Colors.white54),)
                              ],
                            ),
                          ),
                          const SizedBox(height: 7,),
                          Row(
                            children: [
                              for (int i = 0; i < 2; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Container(
                                    width: 120,
                                    height: 140,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white60,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: _photos[i] != null
                                              ? Image.memory(_photos[i]!, fit: BoxFit.cover, width: 120, height: 140,)
                                              : Image.asset('assets/add_photo.jpg', fit: BoxFit.cover, width: 120, height: 140,),
                                        ),
                                        Positioned(
                                          bottom: -8,
                                          left: 62,
                                          child: IconButton(
                                            onPressed: () => selectImage(i),
                                            icon: const Icon(Icons.add_a_photo, color: Colors.black45, size: 40,),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20,width: 20,),
                          Row(
                            children: [
                              for (int i = 2; i < 4; i++) // Adjust the number of image slots
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Container(
                                    width: 120,
                                    height: 140,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white60,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: _photos[i] != null
                                              ? Image.memory(_photos[i]!, fit: BoxFit.cover, width: 120, height: 140,)
                                              : Image.asset('assets/add_photo.jpg', fit: BoxFit.cover, width: 120, height: 140,),
                                        ),
                                        Positioned(
                                          bottom: -8,
                                          left: 62,
                                          child: IconButton(
                                            onPressed: () => selectImage(i),
                                            icon: const Icon(Icons.add_a_photo, color: Colors.black45, size: 40,),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isActive: _currentStep == 2,
                  ),

                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  const ServiceProviderLogin()),
                  );
                },
                child: const Text('Have an account? Log In',
                  style: TextStyle(color: Colors.white, fontSize: 17),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


