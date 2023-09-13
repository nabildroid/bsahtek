import 'package:android_intent_plus/android_intent.dart';
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

  bool isFromGoogle = false;

  AuthCredential? googleCredential;
  GoogleSignInAccount? googleUser;

  bool codeError = false;

  VoidCallback stopListening = () {};

  @override
  void initState() {
    // why forcing the hard token refrech and we just login in fresh,
    // when it comes to a no activated user, we need to force the refrech
    stopListening = Server().onUserChange(
      checkUser,
      forceFirst: true,
    );

    super.initState();
  }

  void checkUser(Client? user) {
    final isAlreadyLogin = user != null;

    if (isAlreadyLogin) {
      stopListening.call();
      Navigator.of(context).pop(user);
      return;
    }

    setState(() => isLoading = false);
  }

  signInWithGoogle() async {
    googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final user = await Server.auth.signInWithCredential(credential);
    await Server.auth.currentUser!.getIdToken(true);
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
                    colorFilter:
                        ColorFilter.mode(Colors.green, BlendMode.srcATop),

                    child: Image.network(
                      'https://www.bsahtek.net/static/logo.png',
                    ), // Replace 'colored_image.png' with your image file path
                  ),
                ),
              ),
            ),
          ),
          Text(
            "Bsahtek",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Good Food, Good Price",
            style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400),
          ),

          Expanded(
              child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Get your best deals\nFight food Wast",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 42),
                  ElevatedButton(
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/google.png",
                          height: 32,
                          width: 32,
                        ),
                        Text(
                          "Login with Google",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 32,
                          width: 32,
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                    onPressed: signInWithGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/social.png",
                          height: 32,
                          width: 32,
                        ),
                        Text(
                          "Login with Facebook",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 32,
                          width: 32,
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("by login you agree on our "),
                      TextButton(
                        onPressed: () {
                          AndroidIntent(
                            action: 'action_view',
                            data: 'https://bsahtek.net/privacy/',
                          ).launch();
                        },
                        child: Text("term and services"),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.all(0),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ))

          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       ElevatedButton(
          //         child: Text("send"),
          //         onPressed: () {},
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: Colors.green.shade700,
          //           elevation: 0,
          //           minimumSize: Size(double.infinity, 50),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }
}
