import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Account Settings"),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Log out"),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          Expanded(child: Center())
        ],
      ),
    );
  }
}
