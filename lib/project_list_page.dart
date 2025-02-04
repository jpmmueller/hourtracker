// lib/project_list_page.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/project.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({Key? key}) : super(key: key);

  @override
  _ProjectListPageState createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('projects');
    setState(() {
      _projects = List.generate(maps.length, (i) {
        return Project(
          id: maps[i]['id'],
          name: maps[i]['name'],
          mainCustomerId: maps[i]['main_customer_id'],
          setupStartDate: DateTime.parse(maps[i]['setup_start_date']),
          setupEndDate: DateTime.parse(maps[i]['setup_end_date']),
          dismantleStartDate: DateTime.parse(maps[i]['dismantle_start_date']),
          dismantleEndDate: DateTime.parse(maps[i]['dismantle_end_date']),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: ListView.builder(
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_projects[index].name),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProjectPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}