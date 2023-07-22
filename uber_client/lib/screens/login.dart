import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/client.dart';
import '../repositories/server.dart';

/**HAS Zero 000 Communication with Context */
class LoginScreen extends StatefulWidget {
  final Client? user;
  LoginScreen({
    Key? key,
    this.user,
  }) : super(key: key);

  static Route go() => MaterialPageRoute(builder: (ctx) => LoginScreen());

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = true;
  bool isOtp = false;

  String? verificationId;
  int? resendToken;

  bool codeError = false;

  final phoneController = TextEditingController(text: "798398545");
  final otpController = TextEditingController(text: "111111");

  VoidCallback stopListening = () {};

  @override
  void initState() {
    // why forcing the hard token refrech and we just login in fresh,
    // when it comes to a no activated user, we need to force the refrech
    stopListening = Server().onUserChange(
      (user) {
        final isAlreadyLogin = user != null;

        if (isAlreadyLogin) {
          stopListening();
          Navigator.of(context).pop(user);
          return;
        }

        setState(() => isLoading = false);
      },
    );

    super.initState();
  }

  void validateOTP() async {
    if (verificationId == null) return;

    final auth = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: otpController.text,
    );

    final user = await Server.auth.signInWithCredential(auth);
  }

  void login() async {
    await Server.auth.verifyPhoneNumber(
      timeout: const Duration(minutes: 2),
      phoneNumber: "+213${phoneController.text}",
      verificationCompleted: (PhoneAuthCredential credential) async {
        final user = await Server.auth.signInWithCredential(credential);
        if (user.user == null) return;
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          codeError = true;
        });
      },
      codeSent: (String verificationId, int? resendToken) async {
        setState(() {
          this.verificationId = verificationId;
          this.resendToken = resendToken;
          this.isOtp = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  void dispose() {
    stopListening();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return Container(
        color: Colors.green,
      );

    return Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
          centerTitle: true,
        ),
        body: Builder(
          builder: (ctx) {
            if (isOtp) {
              return Column(
                children: [
                  const SizedBox(height: 50),
                  Text(
                    "Enter OTP",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: otpController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'OTP',
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: validateOTP,
                    child: const Text("Submit"),
                  ),
                ],
              );
            }

            return Column(
              children: [
                const SizedBox(height: 50),
                Text(
                  "Enter Phone Number",
                  style: Theme.of(context).textTheme.headline5,
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Phone Number',
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: login,
                  child: const Text("Login"),
                ),
              ],
            );
          },
        ));
  }
}
