import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bsahtak/cubits/app_cubit.dart';

class AccountSettingScreen extends StatelessWidget {
  const AccountSettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final client = context.watch<AppCubit>().state.client!;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        title: Text(AppLocalizations.of(context)!.me_account_settings),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Label(AppLocalizations.of(context)!.me_personalInfo),
            ListTile(
              title: Text(AppLocalizations.of(context)!.me_name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(client.name),
                  SizedBox(width: 16),
                  Icon(Icons.arrow_forward_ios),
                ],
              ),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => NameSetting())),
            ),
          ],
        ),
      ),
    );
  }
}

class Label extends StatelessWidget {
  final String label;
  const Label(
    this.label, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        label,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class NameSetting extends StatefulWidget {
  const NameSetting({super.key});

  @override
  State<NameSetting> createState() => _NameSettingState();
}

class _NameSettingState extends State<NameSetting> {
  late TextEditingController _controller;

  bool needSaving = false;

  @override
  void initState() {
    super.initState();

    final client = context.read<AppCubit>().state.client!;
    _controller = TextEditingController(text: client.name);

    _controller.addListener(() {
      final name = _controller.text;
      if (name != client.name) {
        setState(() {
          needSaving = true;
        });
      } else {
        setState(() {
          needSaving = false;
        });
      }
    });
  }

  bool isSaving = false;

  save() async {
    if (isSaving) return;
    isSaving = true;

    setState(() {});

    final client = context.read<AppCubit>().state.client!;

    final name = _controller.text;
    await context.read<AppCubit>().updateClient(client.copyWith(name: name));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final client = context.read<AppCubit>().state.client!;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        title: Text(AppLocalizations.of(context)!.me_name),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (needSaving)
            IconButton(
              onPressed: save,
              icon: Icon(Icons.check),
            )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20),
            child: Text(
              AppLocalizations.of(context)!.me_name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // Text field with inner 20 padding left, borders in top and bottom borders only from edge to edge
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 20),
            ),
          ),
        ],
      ),
    );
  }
}
