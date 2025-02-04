// lib/models/expo_customer.dart
class ExpoCustomer {
  final int id;
  final String name;
  final int projectId; // The project/expo this customer belongs to

  ExpoCustomer({
    required this.id,
    required this.name,
    required this.projectId,
  });
}