import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bsahtak/cubits/app_cubit.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
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
            onTap: () => context.push("/me/settings/account"),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Log out"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () async {
              await context.read<AppCubit>().logOut();
              context.go("/loading");
            },
          ),
          Expanded(child: Center())
        ],
      ),
    );
  }
}
