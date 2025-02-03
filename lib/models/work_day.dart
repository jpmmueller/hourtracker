class WorkDay {
  final int id;
  final int expoCustomerId; // Reference to the expo customer
  final DateTime date;
  final double hoursWorked;

  WorkDay({required this.id, required this.expoCustomerId, required this.date, required this.hoursWorked});
}