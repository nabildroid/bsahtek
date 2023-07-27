import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uber_deliver/models/delivery_man.dart';
import 'package:uber_deliver/repository/server.dart';

import '../models/deliverySubmit.dart';

/**HAS Zero 000 Communication with Context */
class LoginScreen extends StatefulWidget {
  final DeliveryMan? user;
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
        final isAlreadyActivated = user?.isActive == true;

        if (isAlreadyActivated) {
          stopListening();
          Navigator.of(context).pop(user);
          return;
        }

        if (isAlreadyLogin) {
          setState(() => isNeedToSubmit = true);
        }

        setState(() => isLoading = false);
      },
      forceFirst: true,
    );

    super.initState();
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

    // if (isFromGoogle) {
    //   Server.auth.currentUser?.linkWithCredential(auth);
    // }
  }

  signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final auth = await FirebaseAuth.instance.signInWithCredential(credential);

    if (auth.user?.phoneNumber != null) {
      setState(() {
        needGoogle = false;
        isFromGoogle = true;
      });
    }
  }

  void login() async {
    setState(() {
      loadingPhone = true;
      needGoogle = false;
      isOtp = true;
    });
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

    if (isNeedToSubmit) {
      return FormSubmit();
    }

    return Scaffold(
        body: Column(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.green,
            child: Center(
              child: AspectRatio(
                aspectRatio: .9,
                child: ColorFiltered(
                  colorFilter:
                      ColorFilter.mode(Colors.white, BlendMode.srcATop),

                  child: Image.network(
                    'https://wastnothin.vercel.app/static/logo.png',
                  ), // Replace 'colored_image.png' with your image file path
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 8,
          child: Builder(
            builder: (ctx) {
              if (isOtp) {
                return Column(
                  children: [
                    const SizedBox(height: 40),
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
                    if (!loadingPhone)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints.tightFor(width: double.infinity),
                          child: ElevatedButton(
                            onPressed: validateOTP,
                            child: const Text("Confirm"),
                          ),
                        ),
                      ),
                  ],
                );
              }

              return Column(
                children: [
                  const SizedBox(height: 40),
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
                  if (!loadingPhone)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints.tightFor(width: double.infinity),
                        child: ElevatedButton(
                          onPressed: login,
                          child: const Text("Login"),
                        ),
                      ),
                    ),
                  if (!isOtp && needGoogle && !isFromGoogle)
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints.tightFor(
                                      width: double.infinity),
                                  child: TextButton(
                                    onPressed: () {
                                      signInWithGoogle();
                                    },
                                    // background with white color and shadow
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      shadowColor: MaterialStateProperty.all(
                                          Colors.black.withOpacity(.2)),
                                      elevation: MaterialStateProperty.all(4),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Image.network(
                                              "https://developers.google.com/static/identity/images/g-logo.png"),
                                        ),
                                        SizedBox(width: 8),
                                        const Text(
                                          "login with Google",
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    )),
                ],
              );
            },
          ),
        ),
      ],
    ));
  }
}

class FormSubmit extends StatefulWidget {
  FormSubmit({Key? key}) : super(key: key);

  @override
  State<FormSubmit> createState() => _FormSubmitState();
}

class _FormSubmitState extends State<FormSubmit> {
  final name = TextEditingController();
  final country = TextEditingController();
  final wilaya = TextEditingController();
  final address = TextEditingController();

  void submit() async {
    final submit = DeliverySubmit(
      name: name.text,
      country: country.text,
      wilaya: wilaya.text,
      address: address.text,
      photo: "https://firebase.flutter.dev/img/flutterfire_300x.png",
    );

    final user = Server.auth.currentUser!;

    await Server().submitDelivery(user.uid, user.phoneNumber!, submit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Request"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Text Inputs
              TextFormField(
                controller: name,
                decoration: InputDecoration(labelText: "Name"),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: country,
                decoration: InputDecoration(labelText: "Country"),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: wilaya,
                decoration: InputDecoration(labelText: "Wilaya"),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: address,
                decoration: InputDecoration(labelText: "Address"),
              ),

              SizedBox(height: 32),
              // Button to Upload Photo
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement the logic for uploading a photo
                },
                child: Text("Upload Photo"),
              ),
              SizedBox(height: 8),
              // Button to Submit
              ElevatedButton(
                onPressed: () {
                  submit();
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
