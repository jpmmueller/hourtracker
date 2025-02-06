import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('yyyy-MM-dd').format(date) : 'Not set';
  }

  Future<void> _pickDateRange(String dateType) async {
    final result = await showDialog<List<DateTime>>(
      context: context,
      builder: (context) => _DateRangePickerDialog(
        label: dateType == 'setup' ? 'Setup' : 'Dismantle',
      ),
    );

    if (result != null) {
      setState(() {
        if (dateType == 'setup') {
          _setupStartDate = result[0];
          _setupEndDate = result[1];
        } else {
          _dismantleStartDate = result[0];
          _dismantleEndDate = result[1];
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
          duration: Duration(seconds: 2),
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

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving project: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _projectNameController,
              decoration: InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDateSection('Setup Dates', _setupStartDate, _setupEndDate, 'setup'),
            const SizedBox(height: 20),
            _buildDateSection('Dismantle Dates', _dismantleStartDate, _dismantleEndDate, 'dismantle'),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Project', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _saveProject,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(String title, DateTime? startDate, DateTime? endDate, String dateType) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month, size: 20),
                  onPressed: () => _pickDateRange(dateType),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Date',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _formatDate(startDate),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End Date',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _formatDate(endDate),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
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

class _DateRangePickerDialog extends StatefulWidget {
  final String label;

  const _DateRangePickerDialog({required this.label});

  @override
  __DateRangePickerDialogState createState() => __DateRangePickerDialogState();
}

class __DateRangePickerDialogState extends State<_DateRangePickerDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _currentStep = 'start';

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentStep == 'start' 
          ? _startDate ?? DateTime.now() 
          : _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (_currentStep == 'start') {
          _startDate = picked;
          _currentStep = 'end';
        } else {
          if (picked.isAfter(_startDate!)) {
            _endDate = picked;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('End date must be after start date'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        }
      });
    }
  }

  void _resetDates() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _currentStep = 'start';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.label} Dates'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(_currentStep == 'start' 
                ? 'Select Start Date' 
                : 'Select End Date'),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _selectDate,
            ),
          ),
          if (_startDate != null)
            ListTile(
              title: const Text('Selected Start Date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_startDate!)),
            ),
          if (_endDate != null)
            ListTile(
              title: const Text('Selected End Date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_endDate!)),
            ),
          if (_startDate != null || _endDate != null)
            TextButton(
              onPressed: _resetDates,
              child: const Text('Reset Dates'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_startDate != null && _endDate != null) {
              Navigator.pop(context, [_startDate, _endDate]);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select both dates'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}