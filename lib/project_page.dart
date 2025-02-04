import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/main_customer.dart';
import 'models/project.dart';

class ProjectPage extends StatefulWidget {
  final MainCustomer mainCustomer;

  const ProjectPage({
    Key? key,
    required this.mainCustomer,
  }) : super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _projectNameController = TextEditingController();
  DateTime? _setupStartDate;
  DateTime? _setupEndDate;
  DateTime? _dismantleStartDate;
  DateTime? _dismantleEndDate;

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
    if (_projectNameController.text.isEmpty ||
        _setupStartDate == null ||
        _setupEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _projectNameController.text,
      mainCustomerId: widget.mainCustomer.id,
      setupStartDate: _setupStartDate!,
      setupEndDate: _setupEndDate!,
      dismantleStartDate: _dismantleStartDate ?? _setupEndDate!,
      dismantleEndDate: _dismantleEndDate ?? _setupEndDate!,
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

    Navigator.pop(context); // Return to ProjectListPage
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
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Setup Dates'),
              subtitle: Text(
                _setupStartDate == null || _setupEndDate == null
                    ? 'Select dates'
                    : '${_setupStartDate!.toLocal().toString().split(' ')[0]} '
                        'to ${_setupEndDate!.toLocal().toString().split(' ')[0]}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  await _pickDate(context, true); // Setup start
                  await _pickDate(context, false); // Setup end
                },
              ),
            ),
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