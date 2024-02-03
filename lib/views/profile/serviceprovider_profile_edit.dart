import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ServiceProviderProfileEdit extends StatefulWidget {
  final String? userId;
  final int initialTabIndex;

  const ServiceProviderProfileEdit({Key? key, this.userId, this.initialTabIndex = 0,}) : super(key: key);


  @override
  _ServiceProviderProfileEditState createState() =>
      _ServiceProviderProfileEditState();
}

class _ServiceProviderProfileEditState
    extends State<ServiceProviderProfileEdit>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController serviceController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController pricing1Controller = TextEditingController();
  TextEditingController pricing1LKRController = TextEditingController();
  TextEditingController pricing2Controller = TextEditingController();
  TextEditingController pricing2LKRController = TextEditingController();
  TextEditingController pricing3Controller = TextEditingController();
  TextEditingController pricing3LKRController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex,);

    if (widget.userId != null) {
      _loadData();
    } else {

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance
          .collection('service_providers')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();
        nameController.text = data?['name'] ?? '';
        phoneController.text = data?['phone'] ?? '';
        serviceController.text = data?['service'] ?? '';
        addressController.text = data?['address'] ?? '';
        businessNameController.text = data?['business_Name'] ?? '';
        descriptionController.text = data?['description'] ?? '';
        pricing1Controller.text = data?['pricing_plan_1'] ?? '';
        pricing1LKRController.text = data?['pricing_plan_1_price'] ?? '';
        pricing2Controller.text = data?['pricing_plan_2'] ?? '';
        pricing2LKRController.text = data?['pricing_plan_2_price'] ?? '';
        pricing3Controller.text = data?['pricing_plan_3'] ?? '';
        pricing3LKRController.text = data?['pricing_plan_3_price'] ?? '';
      } else {
        Navigator.pop(context); // Close the current page
      }
    } catch (error) {
      print('Error loading data: $error');
      // Handle the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Description & Pricing'),
            Tab(text: 'Other Details'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDescriptionTab(),
          _buildOtherDetailsTab(),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(height: 16.0),
          InputLabel('Description'),
          TextFormField(
            controller: descriptionController,
            maxLines: 7,
            decoration: InputDecoration(
              hintText: 'Enter your description',
            ),
          ),
          SizedBox(height: 16,),

          InputLabel('Pricing Plan 1'),
          TextFormField(
            controller: pricing1Controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter pricing plan details 1',
            ),
          ),
          TextFormField(
            controller: pricing1LKRController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Enter pricing in LKR for plan 1',
            ),
          ),

          SizedBox(height: 16.0),
          InputLabel('Pricing Plan 2'),
          TextFormField(
            controller: pricing2Controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter pricing plan details 2',
            ),
          ),
          TextFormField(
            controller: pricing2LKRController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Enter pricing in LKR for plan 2',
            ),
          ),

          SizedBox(height: 16.0),
          InputLabel('Pricing Plan 3'),
          TextFormField(
            controller: pricing3Controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter pricing plan details 3',
            ),
          ),
          TextFormField(
            controller: pricing3LKRController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Enter pricing in LKR for plan 3',
            ),
          ),
          SizedBox(height: 32.0),
          ElevatedButton(
            onPressed: () {
              _saveChanges();
            },
            child: Text(
              'Save Changes',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.all(15.0),
              fixedSize: const Size(380, 60),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              primary: Colors.deepPurple[400],
              onPrimary: Colors.white,
              elevation: 10,
              shadowColor: Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherDetailsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputLabel('Name'),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
            ),
          ),
          SizedBox(height: 16.0),
          InputLabel('Phone'),
          TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
              hintText: 'Enter your phone number',
            ),
          ),
          SizedBox(height: 16.0),
          InputLabel('Business Name'),
          TextFormField(
            controller: businessNameController,
            decoration: InputDecoration(
              hintText: 'Enter your business name',
            ),
          ),          SizedBox(height: 16.0),
          InputLabel('Service'),
          TextFormField(
            controller: serviceController,
            decoration: InputDecoration(
              hintText: 'Enter your service',
            ),
          ),
          SizedBox(height: 16.0),
          InputLabel('Address'),
          TextFormField(
            controller: addressController,
            decoration: InputDecoration(
              hintText: 'Enter your address',
            ),
          ),
          SizedBox(height: 16.0),

          SizedBox(height: 32.0),
          ElevatedButton(
            onPressed: () {
              _saveChanges();
            },
            child: Text(
              'Save Changes',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.all(15.0),
              fixedSize: const Size(380, 60),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              primary: Colors.deepPurple[400],
              onPrimary: Colors.white,
              elevation: 10,
              shadowColor: Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() async {
    try {
      await FirebaseFirestore.instance
          .collection('service_providers')
          .doc(widget.userId)
          .update({
        'name': nameController.text,
        'phone': phoneController.text,
        'service': serviceController.text,
        'address': addressController.text,
        'business_Name': businessNameController.text,
        'description': descriptionController.text,
        'pricing_plan_1': pricing1Controller.text,
        'pricing_plan_1_price': pricing1LKRController.text,
        'pricing_plan_2': pricing2Controller.text,
        'pricing_plan_2_price': pricing2LKRController.text,
        'pricing_plan_3': pricing3Controller.text,
        'pricing_plan_3_price': pricing3LKRController.text,
      });


      Navigator.pop(context, true);
    } catch (error) {
      print('Error updating user profile: $error');

      Navigator.pop(context, false); // Indicate that data was not updated
    }
  }
}

class InputLabel extends StatelessWidget {
  final String label;

  const InputLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
      ),
    );
  }
}
