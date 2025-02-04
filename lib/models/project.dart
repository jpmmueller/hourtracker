// lib/models/project.dart
class Project {
  final int id;
  final String name;
  final int mainCustomerId; // The main customer who hired you
  final DateTime setupStartDate;
  final DateTime setupEndDate;
  final DateTime dismantleStartDate;
  final DateTime dismantleEndDate;

  Project({
    required this.id,
    required this.name,
    required this.mainCustomerId,
    required this.setupStartDate,
    required this.setupEndDate,
    required this.dismantleStartDate,
    required this.dismantleEndDate,
  });
}