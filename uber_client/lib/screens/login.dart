import 'dart:math';

import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/client.dart';
import '../repositories/server.dart';

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
  bool isNeedToSubmit = false;
  bool isLoading = true;
  bool isOtp = false;

  bool needGoogle = true;

  bool loadingPhone = false;

  bool isFromGoogle = false;

  String? verificationId;
  int? resendToken;

  AuthCredential? googleCredential;
  GoogleSignInAccount? googleUser;

  bool codeError = false;

  final phoneController = TextEditingController(text: "");
  final otpController = TextEditingController(text: "111111");

  VoidCallback stopListening = () {};

  bool phoneIsValid = false;
  void _formatPhoneNumber() {
    final unformattedText = phoneController.text.replaceAll(RegExp(r'\s'), '');

    var formated = "";

    for (var i = 0; i < unformattedText.length; i++) {
      if (i == 3 || i == 5 || i == 7) formated += " ";
      formated += unformattedText[i];
    }

    phoneController.value = phoneController.value.copyWith(
      text: formated,
      selection: TextSelection.collapsed(offset: formated.length),
    );
  }

  @override
  void initState() {
    // why forcing the hard token refrech and we just login in fresh,
    // when it comes to a no activated user, we need to force the refrech
    stopListening = Server().onUserChange(
      checkUser,
      forceFirst: true,
    );

    phoneController.addListener(_formatPhoneNumber);

    super.initState();
  }

  void checkUser(Client? user) {
    final isAlreadyLogin = user != null && user.phone.isNotEmpty;

    if (isAlreadyLogin) {
      stopListening.call();
      Navigator.of(context).pop(user);
      return;
    }

    setState(() => isLoading = false);
  }

  void validateOTP() async {
    if (verificationId == null) return;
    setState(() {
      loadingPhone = true;
    });

    final auth = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: otpController.text,
    );

    final user = await Server.auth.signInWithCredential(auth);
    if (googleCredential != null) {
      await Server.auth.currentUser?.linkWithCredential(googleCredential!);
    }
  }

  signInWithGoogle() async {
    //todo get phone nummber

    googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final allowedMethd =
        await Server.auth.fetchSignInMethodsForEmail(googleUser!.email);

    final isNotAssociated = allowedMethd.isEmpty;
    if (isNotAssociated) {
      googleCredential = AuthCredential(
        providerId: credential.providerId,
        signInMethod: credential.signInMethod,
        token: credential.token,
        accessToken: credential.accessToken,
      );

      setState(() {
        googleUser = googleUser;
        needGoogle = false;
        isFromGoogle = true;
      });
    } else {
      final user = await Server.auth.signInWithCredential(credential);
      await Server.auth.currentUser!.getIdToken(true);
      // we hope that the authStateChanges will fire!
    }
  }

  void login() async {
    setState(() {
      loadingPhone = true;
      needGoogle = false;
    });

    final unformattedText = phoneController.text.replaceAll(RegExp(r'\s'), '');

    await Server.auth.verifyPhoneNumber(
      timeout: const Duration(minutes: 2),
      phoneNumber: "+213${unformattedText}",
      verificationCompleted: (PhoneAuthCredential credential) async {
        final user = await Server.auth.signInWithCredential(credential);
        if (user.user == null) return;
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          codeError = true;
          loadingPhone = false;
          isOtp = false;
          needGoogle = true;
        });
      },
      codeSent: (String verificationId, int? resendToken) async {
        setState(() {
          this.verificationId = verificationId;
          this.resendToken = resendToken;
          this.isOtp = true;

          loadingPhone = false;
          needGoogle = false;
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top,
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: SizedBox(
                        width: 120,
                        child: Hero(
                          tag: "Logo",
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                Colors.green, BlendMode.srcATop),

                            child: Image.network(
                              'https://wastnothin.vercel.app/static/logo.png',
                            ), // Replace 'colored_image.png' with your image file path
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Divider(
                      height: 0,
                      thickness: 3,
                    ),
                  ),
                  SizedBox(height: 42),
                  if (!isOtp)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 26),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Enter your phone number.",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              wordSpacing: .85,
                              height: .96,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Your phone number allows us to verify your identity",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black.withOpacity(.8),
                            ),
                          ),
                          SizedBox(height: 42),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.black.withOpacity(.1),
                                width: 2,
                              ),
                            ),
                            padding: EdgeInsets.all(8),
                            child: Row(
                              children: [
                                PhoneNumberPrefix(),
                                Expanded(
                                  child: TextField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      // allow only digit but they must not start with 0
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r"[1-9].*")),
                                    ],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLength: 9 + 3,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "550 00 00 00",
                                      counterText: "",
                                      hintStyle: TextStyle(
                                        color: Colors.black.withOpacity(.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          if (!isOtp && needGoogle && !isFromGoogle)
                            ElevatedButton(
                              onPressed: signInWithGoogle,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Image.network(
                                        "https://developers.google.com/static/identity/images/g-logo.png"),
                                  ),
                                  SizedBox(width: 16),
                                  const Text(
                                    "login with Google",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (isOtp)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 26),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Enter your 6 digit code.",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              wordSpacing: .85,
                              height: .96,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "We have sent you an SMS with a code to the number",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black.withOpacity(.8),
                            ),
                          ),
                          SizedBox(height: 42),
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OtpTextField(
                                    numberOfFields: 6,
                                    //set to true to show as box or false to show as dash
                                    showFieldAsBox: true,
                                    borderRadius: BorderRadius.circular(10),
                                    //runs when a code is typed in
                                    onCodeChanged: (String code) {
                                      otpController.text = code;
                                    },
                                    //runs when every textfield is filled
                                    onSubmit: (String verificationCode) {
                                      otpController.text = verificationCode;
                                      validateOTP();
                                    }, // end onSubmit
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  child: Center(
                    child: loadingPhone
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text("Send"),
                  ),
                  onPressed: isOtp ? validateOTP : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    elevation: 0,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class PhoneNumberPrefix extends StatelessWidget {
  const PhoneNumberPrefix({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          "assets/dz.png",
          width: 30,
          height: 30,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          "+213",
          style: TextStyle(
            fontSize: 18,
            letterSpacing: .9,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Container(
          width: 1,
          height: 28,
          color: Colors.black.withOpacity(.5),
        ),
        SizedBox(
          width: 10,
        ),
      ],
    );
  }
}
