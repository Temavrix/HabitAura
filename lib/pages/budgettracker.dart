import 'package:flutter/material.dart';

class BudgetTracker extends StatelessWidget {
  const BudgetTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text("Budget Tracker"),
      ),
      body: Center(
        child: Text(
          "Budget Tracker Page",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
