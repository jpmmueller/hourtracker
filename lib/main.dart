// lib/main.dart
import 'package:flutter/material.dart';
import 'main_customer_page.dart'; // Ensure this import exists
import 'project_list_page.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hour Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainCustomerPage(), // Use MainCustomerPage temporarily
    );
  }
}