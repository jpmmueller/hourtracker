// lib/main.dart
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
      home: const ProjectListPage(), // New homepage for projects
    );
  }
}