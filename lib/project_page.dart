import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Correct import for DateFormat
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

  // Format dates (e.g., "2023-10-05")
  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('yyyy-MM-dd').format(date) : 'Not set';
  }

  Future<void> _pickDate(BuildContext context, String dateType) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        switch (dateType) {
          case 'setupStart':
            _setupStartDate = picked;
            break;
          case 'setupEnd':
            _setupEndDate = picked;
            break;
          case 'dismantleStart':
            _dismantleStartDate = picked;
            break;
          case 'dismantleEnd':
            _dismantleEndDate = picked;
            break;
        }
      });
    }
  }

  Future<void> _saveProject() async {
    if (_projectNameController.text.isEmpty ||
        _setupStartDate == null ||
        _setupEndDate == null ||
        _dismantleStartDate == null ||
        _dismantleEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select all dates.'),
        ),
      );
      return;
    }

    try {
      final project = Project(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _projectNameController.text,
        mainCustomerId: widget.mainCustomer.id,
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

      Navigator.pop(context, true); // Pass "true" to trigger a refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving project: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Project')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _projectNameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _buildDateSection(
              'Setup Dates',
              _setupStartDate,
              _setupEndDate,
              onStartPressed: () => _pickDate(context, 'setupStart'),
              onEndPressed: () => _pickDate(context, 'setupEnd'),
            ),
            const SizedBox(height: 20),
            _buildDateSection(
              'Dismantle Dates',
              _dismantleStartDate,
              _dismantleEndDate,
              onStartPressed: () => _pickDate(context, 'dismantleStart'),
              onEndPressed: () => _pickDate(context, 'dismantleEnd'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveProject,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Save Project',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(
    String title,
    DateTime? startDate,
    DateTime? endDate, {
    required VoidCallback onStartPressed,
    required VoidCallback onEndPressed,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(_formatDate(startDate)),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: onStartPressed,
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(_formatDate(endDate)),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: onEndPressed,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}