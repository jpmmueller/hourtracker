// lib/daily_entry_page.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/expo_customer.dart';
import 'models/project.dart';
import 'models/work_day.dart';

class DailyEntryPage extends StatefulWidget {
  final Project project;
  final List<ExpoCustomer> expoCustomers;

  const DailyEntryPage({
    Key? key,
    required this.project,
    required this.expoCustomers,
  }) : super(key: key);

  @override
  _DailyEntryPageState createState() => _DailyEntryPageState();
}

class _DailyEntryPageState extends State<DailyEntryPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Map<int, TextEditingController> _hourControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each expo customer
    for (var customer in widget.expoCustomers) {
      _hourControllers[customer.id] = TextEditingController();
    }
  }

  Future<void> _saveHours() async {
    final db = await _dbHelper.database;
    final DateTime today = DateTime.now();

    for (var customer in widget.expoCustomers) {
      final controller = _hourControllers[customer.id];
      if (controller!.text.isNotEmpty) {
        final hours = double.tryParse(controller.text) ?? 0.0;
        if (hours > 0) {
          await db.insert('work_days', {
            'date': today.toIso8601String(),
            'hours_worked': hours,
            'expo_customer_id': customer.id,
            'project_id': widget.project.id,
          });
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hours saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log Hours for ${widget.project.name}')),
      body: ListView.builder(
        itemCount: widget.expoCustomers.length,
        itemBuilder: (context, index) {
          final customer = widget.expoCustomers[index];
          return ListTile(
            title: Text(customer.name),
            trailing: SizedBox(
              width: 100,
              child: TextField(
                controller: _hourControllers[customer.id],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Hours',
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveHours,
        child: const Icon(Icons.save),
      ),
    );
  }
}