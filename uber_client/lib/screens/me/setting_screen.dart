import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.me_settings),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text(AppLocalizations.of(context)!.me_account_settings),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () => context.push("/me/settings/account"),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(AppLocalizations.of(context)!.me_logout),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () async {
              await context.read<AppCubit>().logOut(context);
              context.go("/loading");
            },
          ),
          Expanded(child: Center())
        ],
      ),
    );
  }
}
