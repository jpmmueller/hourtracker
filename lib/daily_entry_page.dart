class DailyEntryPage extends StatelessWidget {
  final Project project;
  final List<ExpoCustomer> expoCustomers;

  const DailyEntryPage({
    Key? key,
    required this.project,
    required this.expoCustomers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log Hours for ${project.name}')),
      body: ListView.builder(
        itemCount: expoCustomers.length,
        itemBuilder: (context, index) {
          final customer = expoCustomers[index];
          return ListTile(
            title: Text(customer.name),
            trailing: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // Save hours to WorkDay model
              },
            ),
          );
        },
      ),
    );
  }
}