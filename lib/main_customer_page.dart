import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // Add this import
import 'database_helper.dart';
import 'models/main_customer.dart';
import 'project_list_page.dart';

class MainCustomerPage extends StatefulWidget {
  const MainCustomerPage({Key? key}) : super(key: key);

  @override
  _MainCustomerPageState createState() => _MainCustomerPageState();
}

class _MainCustomerPageState extends State<MainCustomerPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  List<MainCustomer> _mainCustomers = [];

  @override
  void initState() {
    super.initState();
    _loadMainCustomers();
  }

  Future<void> _loadMainCustomers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('main_customers');

    setState(() {
      _mainCustomers = List.generate(maps.length, (i) {
        return MainCustomer(
          id: maps[i]['id'],
          name: maps[i]['name'],
        );
      });
    });
  }

  Future<void> _addMainCustomer() async {
    if (_nameController.text.isEmpty) return;

    try {
      var mainCustomer = MainCustomer(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _nameController.text,
      );

      final db = await _dbHelper.database;
      await db.insert(
        'main_customers',
        {
          'id': mainCustomer.id,
          'name': mainCustomer.name,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await _loadMainCustomers();
      _nameController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Customers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Main Customer Name',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addMainCustomer,
            child: const Text('Add Main Customer'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _mainCustomers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_mainCustomers[index].name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectListPage(
                          mainCustomer: _mainCustomers[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}