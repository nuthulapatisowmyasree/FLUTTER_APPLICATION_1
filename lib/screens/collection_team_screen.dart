import 'package:flutter/material.dart';

class CollectionTeamScreen extends StatelessWidget {
  const CollectionTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Collection Team"),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.local_shipping),
            title: Text("Plastic Waste"),
            subtitle: Text("Assigned"),
          ),
          ListTile(
            leading: Icon(Icons.local_shipping),
            title: Text("Food Waste"),
            subtitle: Text("Completed"),
          ),
        ],
      ),
    );
  }
}