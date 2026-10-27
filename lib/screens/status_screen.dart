import 'package:flutter/material.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final status = [
      "Pending",
      "Assigned",
      "In Progress",
      "Completed",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complaint Status"),
      ),
      body: ListView.builder(
        itemCount: status.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.check_circle),
            title: Text(status[index]),
          );
        },
      ),
    );
  }
}