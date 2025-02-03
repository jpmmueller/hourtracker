class ExpoCustomer {
  final int id;
  final String name;
  final int mainCustomerId; // Reference to the main customer

  ExpoCustomer({required this.id, required this.name, required this.mainCustomerId});
}