import 'package:flutter/material.dart';

class ComplaintTrackingScreen extends StatelessWidget {
  const ComplaintTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final complaints = [
      {
        "id": "WC101",
        "status": "Pending",
      },
      {
        "id": "WC102",
        "status": "In Progress",
      },
      {
        "id": "WC103",
        "status": "Completed",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Complaints"),
      ),
      body: ListView.builder(
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.report),
            title: Text(
              complaints[index]["id"]!,
            ),
            subtitle: Text(
              complaints[index]["status"]!,
            ),
          );
        },
      ),
    );
  }
}