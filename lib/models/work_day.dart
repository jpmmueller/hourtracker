// lib/models/work_day.dart
class WorkDay {
  final int id;
  final DateTime date;
  final double hoursWorked;
  final int expoCustomerId; // Which expo customer these hours are for
  final int projectId; // Which project this work belongs to

  WorkDay({
    required this.id,
    required this.date,
    required this.hoursWorked,
    required this.expoCustomerId,
    required this.projectId,
  });
}