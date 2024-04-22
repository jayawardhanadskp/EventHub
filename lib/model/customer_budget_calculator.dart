import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';

class BudgetCalculatePage extends StatefulWidget {
  const BudgetCalculatePage({Key? key}) : super(key: key);

  @override
  _BudgetCalculatePageState createState() => _BudgetCalculatePageState();
}

class _BudgetCalculatePageState extends State<BudgetCalculatePage> {
  double _result = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SimpleCalculator(
                value: 0,
                hideExpression: true,
                onChanged: (key, value, expression) {
                  /*...*/
                },
                theme: const CalculatorThemeData(
                  displayColor: Colors.white,
                  displayStyle: const TextStyle(fontSize: 80, color: Colors.black),
                ),
              )
            ),
            SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}
