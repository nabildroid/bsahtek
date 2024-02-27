import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ActivateAccount extends StatefulWidget {
  final bool isOtpScreen;
  final void Function(String otp) confirmOTP;
  final Function(String name, String phone, String address) sendOTP;

  const ActivateAccount({
    super.key,
    required this.isOtpScreen,
    required this.confirmOTP,
    required this.sendOTP,
  });

  @override
  State<ActivateAccount> createState() => _ActivateAccountState();
}

class _ActivateAccountState extends State<ActivateAccount> {
  final phone = TextEditingController();

  void _formatPhoneNumber() {
    final unformattedText = phone.text.replaceAll(RegExp(r'\s'), '');

    var formated = "";

    for (var i = 0; i < unformattedText.length; i++) {
      if (i == 3 || i == 5 || i == 7) formated += " ";
      formated += unformattedText[i];
    }

    phone.value = phone.value.copyWith(
      text: formated,
      selection: TextSelection.collapsed(offset: formated.length),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final otp = TextEditingController();
  final name = TextEditingController();
  final address = TextEditingController();

  @override
  void initState() {
    super.initState();

    phone.addListener(_formatPhoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOtpScreen) {
      return Form(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            "Confirm OTP",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          // input field with dark background and rounded corners
          SizedBox(height: 16),
          TextFormField(
            controller: otp,
            style: TextStyle(
              fontSize: 32,
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintText: "000000",
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 4) {
                return 'Please correct OTP';
              }
              return null;
            },
          ),

          SizedBox(height: 16),
          ElevatedButton(
            child:
                Text(AppLocalizations.of(context)!.bag_order_activate_action),
            onPressed: () => widget.confirmOTP(otp.text),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ]),
      );
    }

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            AppLocalizations.of(context)!.bag_order_activate_title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          // input field with dark background and rounded corners
          SizedBox(height: 16),
          TextFormField(
            controller: name,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintText: AppLocalizations.of(context)!.bag_order_activate_name,
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 3) {
                return 'Please correct Name';
              }
              return null;
            },
          ),

          SizedBox(height: 16),
          TextFormField(
            controller: phone,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              prefix: Text("+213 "),
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintText: AppLocalizations.of(context)!.bag_order_activate_phone,
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.length != 9 + 3) {
                return 'Please correct Phone number';
              }
              return null;
            },
          ),

          SizedBox(height: 16),
          TextFormField(
            controller: address,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintText:
                  AppLocalizations.of(context)!.bag_order_activate_address,
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 5) {
                return 'Please correct Address, otherwise you may not receive your order';
              }

              return null;
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            child:
                Text(AppLocalizations.of(context)!.bag_order_activate_action),
            onPressed: () =>
                widget.sendOTP(name.text, phone.text, address.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
