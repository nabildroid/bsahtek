import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ActivateAccount extends StatefulWidget {
  final bool isOtpScreen;
  final bool isLoading;
  final Future<void> Function(String otp) confirmOTP;
  final Function(String name, String phone, String address) sendOTP;

  const ActivateAccount({
    super.key,
    required this.isOtpScreen,
    required this.confirmOTP,
    required this.sendOTP,
    required this.isLoading,
  });

  @override
  State<ActivateAccount> createState() => _ActivateAccountState();
}

class _ActivateAccountState extends State<ActivateAccount> {
  final phone = TextEditingController(text: "798390046");

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

  final _infoFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final otp = TextEditingController();
  final name = TextEditingController();
  final address = TextEditingController();

  bool otpInvalide = false;

  @override
  void initState() {
    super.initState();

    phone.addListener(_formatPhoneNumber);
  }

  void submitInfo() {
    if (_infoFormKey.currentState!.validate()) {
      widget.sendOTP(name.text, phone.text, address.text);
    }
  }

  void submitOTP() async {
    if (_otpFormKey.currentState!.validate()) {
      try {
        await widget.confirmOTP(otp.text);
      } catch (e) {
        otp.text = "";
        setState(() {
          otpInvalide = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOtpScreen) {
      return Form(
        key: _otpFormKey,
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
              errorText:
                  otpInvalide && otp.text.isEmpty ? "Code invalide" : null,
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintText: "000000",
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.length != 6) {
                return 'Please correct OTP';
              }
              return null;
            },
          ),

          SizedBox(height: 16),
          ElevatedButton(
            child: widget.isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : Text(AppLocalizations.of(context)!.bag_order_activate_action),
            onPressed: widget.isLoading ? null : submitOTP,
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
        key: _infoFormKey,
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
              prefixIcon: Icon(Icons.person),
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
              fillColor: Colors.grey.shade200,
              prefixIcon: Icon(Icons.phone),
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
              prefixIcon: Icon(Icons.location_on_outlined),
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
            child: widget.isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : Text(AppLocalizations.of(context)!.bag_order_activate_action),
            onPressed: widget.isLoading ? null : submitInfo,
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
