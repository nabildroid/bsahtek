import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uber_client/cubits/app_cubit.dart';
import 'package:uber_client/repositories/cache.dart';

import '../models/client.dart';
import '../repositories/server.dart';
import 'home.dart';
import 'loading_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool confirmOtp = false;

  final _otpController = TextEditingController();
  final _phoneController = TextEditingController(text: "798398545");

  Future<Client> Function(String otp)? confirmOtpFunc;

  void submitPhone() async {
    final verifier =
        await Server().loginByPhone("+213" + _phoneController.text);
    setState(() {
      confirmOtp = true;
      confirmOtpFunc = verifier;
    });
  }

  void submitOtp() async {
    if (confirmOtpFunc == null) return;
    final client = await confirmOtpFunc!(_otpController.text);
    Cache.isLogin = true;
    context.read<AppCubit>().init(client: client);

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (ctx) => const LoadingScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.green.shade800,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 600),
                curve: Curves.decelerate,
                height: confirmOtp ? 350 : 250,
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                    ),
                    padding: EdgeInsets.all(20),
                    width: double.infinity,
                    child: Stack(
                      children: [
                        AnimatedToBack(
                          isVisible: confirmOtp,
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 2.0,
                                    wordSpacing: 2.0,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "a message has been sent to your phone number +213${_phoneController.text} \n"
                                "please enter the code",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 2.0,
                                  wordSpacing: 2.0,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                enableSuggestions: false,
                                maxLength: 9,
                                controller: _otpController,
                                decoration: InputDecoration(
                                  hintText: "OTP",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                onPressed: submitOtp,
                                child: Text("Confirm"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedToBack(
                          isVisible: !confirmOtp,
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 2.0,
                                    wordSpacing: 2.0,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextField(
                                keyboardType: TextInputType.phone,
                                enableSuggestions: false,
                                maxLength: 9,
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  hintText: "phone",
                                  prefix: Text(
                                    "+213 ",
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                onPressed: submitPhone,
                                child: Text("Login"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AnimatedToBack extends StatelessWidget {
  final Widget child;
  final bool isVisible;
  const AnimatedToBack({
    super.key,
    required this.child,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: !isVisible ? .6 : 1,
      curve: Curves.easeInOutExpo,
      duration: const Duration(milliseconds: 600),
      child: AnimatedScale(
        scale: !isVisible ? .6 : 1,
        curve: Curves.easeInOutExpo,
        duration: const Duration(milliseconds: 600),
        child: AnimatedSlide(
          offset: Offset(0, !isVisible ? 2 : 0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutExpo,
          child: child,
        ),
      ),
    );
  }
}
