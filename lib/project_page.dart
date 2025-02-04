// lib/project_page.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/main_customer.dart';
import 'models/project.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({Key? key}) : super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

// ... rest of the code from the previous answer ...

class _ProjectPageState extends State<ProjectPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _projectNameController = TextEditingController();
  List<MainCustomer> _mainCustomers = [];
  MainCustomer? _selectedMainCustomer;
  DateTime? _setupStartDate;
  DateTime? _setupEndDate;
  DateTime? _dismantleStartDate;
  DateTime? _dismantleEndDate;

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

  Future<void> _pickDate(BuildContext context, bool isSetupStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isSetupStart) {
          _setupStartDate = picked;
        } else {
          _setupEndDate = picked;
        }
      });
    }
  }

  Future<void> _saveProject() async {
    if (_projectNameController.text.isEmpty || _selectedMainCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _projectNameController.text,
      mainCustomerId: _selectedMainCustomer!.id,
      setupStartDate: _setupStartDate!,
      setupEndDate: _setupEndDate!,
      dismantleStartDate: _dismantleStartDate!,
      dismantleEndDate: _dismantleEndDate!,
    );

    final db = await _dbHelper.database;
    await db.insert('projects', {
      'id': project.id,
      'name': project.name,
      'main_customer_id': project.mainCustomerId,
      'setup_start_date': project.setupStartDate.toIso8601String(),
      'setup_end_date': project.setupEndDate.toIso8601String(),
      'dismantle_start_date': project.dismantleStartDate.toIso8601String(),
      'dismantle_end_date': project.dismantleEndDate.toIso8601String(),
    });

    Navigator.pop(context); // Return to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Project')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _projectNameController,
              decoration: const InputDecoration(labelText: 'Project Name'),
            ),
            DropdownButton<MainCustomer>(
              hint: const Text('Select Main Customer'),
              value: _selectedMainCustomer,
              items: _mainCustomers.map((customer) {
                return DropdownMenuItem<MainCustomer>(
                  value: customer,
                  child: Text(customer.name),
                );
              }).toList(),
              onChanged: (customer) {
                setState(() => _selectedMainCustomer = customer);
              },
            ),
            ListTile(
              title: Text(_setupStartDate == null
                  ? 'Select Setup Start Date'
                  : 'Setup Start: ${_setupStartDate!.toLocal()}'),
              onTap: () => _pickDate(context, true),
            ),
            ListTile(
              title: Text(_setupEndDate == null
                  ? 'Select Setup End Date'
                  : 'Setup End: ${_setupEndDate!.toLocal()}'),
              onTap: () => _pickDate(context, false),
            ),
            // Add similar fields for dismantle dates
            ElevatedButton(
              onPressed: _saveProject,
              child: const Text('Save Project'),
            ),
          ],
        ),
      ),
    );
  }
}