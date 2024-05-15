import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportProblemPage extends StatefulWidget {

  @override
  _ReportProblemPageState createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  final _reportController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;
    final report = _reportController.text;
    final timestamp = DateTime.now();

    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'userId': userId,
        'report': report,
        'timestamp': timestamp,
      });

      _showSnackbar('Successfully reported');
      Navigator.pop(context);

    } catch (error) {
      print('Error submitting report: $error');
      _showSnackbar('Failed to report the problem');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a Problem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _reportController,
                decoration: const InputDecoration(
                  labelText: 'Report',
                  hintText: 'Enter your report message',
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your report';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitReport,
                child: const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
