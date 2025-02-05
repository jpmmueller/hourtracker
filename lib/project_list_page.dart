import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/main_customer.dart';
import 'models/project.dart';
import 'project_page.dart';

class ProjectListPage extends StatefulWidget {
  final MainCustomer mainCustomer;

  const ProjectListPage({
    Key? key,
    required this.mainCustomer,
  }) : super(key: key);

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
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      where: 'main_customer_id = ?',
      whereArgs: [widget.mainCustomer.id],
    );

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

  void _navigateToProjectPage() async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectPage(mainCustomer: widget.mainCustomer),
      ),
    );

    if (shouldRefresh == true) {
      await _loadProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects for ${widget.mainCustomer.name}'),
      ),
      body: ListView.builder(
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          final project = _projects[index];
          return ListTile(
            title: Text(project.name),
            subtitle: Text(
              'Setup: ${project.setupStartDate.toLocal().toString().split(' ')[0]} '
              'to ${project.setupEndDate.toLocal().toString().split(' ')[0]}\n'
              'Dismantle: ${project.dismantleStartDate.toLocal().toString().split(' ')[0]} '
              'to ${project.dismantleEndDate.toLocal().toString().split(' ')[0]}',
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToProjectPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}