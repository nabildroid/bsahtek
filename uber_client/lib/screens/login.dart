import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:bsahtak/cubits/static_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:dropdown_button2/dropdown_button2.dart';

import '../models/client.dart';
import '../repositories/cache.dart';
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
    try {
      googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = await Server.auth.signInWithCredential(credential);
    } catch (e) {}
  }

  signInWithFacebook() async {
    final result = await FacebookAuth.instance
        .login(permissions: ['public_profile', 'email']);
    if (result.status == LoginStatus.success) {
      final userData = await FacebookAuth.instance.getUserData();
      // use userData
    }
  }

  Future<void> loginOrRegister(String email, String password) async {
    try {
      // Attempt to sign in
      await Server.auth
          .signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      // If sign-in fails, create a new account
      if (e is FirebaseAuthException && e.code == 'user-not-found') {
        await Server.auth
            .createUserWithEmailAndPassword(email: email, password: password);
      } else {
        // Handle other errors
        throw e;
      }
    }
  }

  @override
  void dispose() {
    stopListening();

    super.dispose();
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _submit() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    loginOrRegister(email, password);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return Container(
        color: Colors.green,
      );

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            FractionallySizedBox(
              heightFactor: .31,
              alignment: Alignment.topCenter,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/splash.png"),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                child: Align(
                  alignment: Alignment(-.8, 0.3),
                  child: Text(
                    AppLocalizations.of(context)!.appName,
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.white,
                            offset: Offset(1, 1),
                          )
                        ]),
                  ),
                ),
              ),
            ),
            FractionallySizedBox(
              heightFactor: .73,
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      offset: Offset(0, -2),
                      color: Colors.black26,
                      spreadRadius: 1,
                    )
                  ],
                ),
                padding:
                    EdgeInsets.only(top: 20, bottom: 20, right: 18, left: 18),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 15),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: "Email",
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(500),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        // Perform additional password validation here
                        return null;
                      },
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(500),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ConstrainedBox(
                      constraints:
                          BoxConstraints.tightFor(width: double.infinity),
                      child: FilledButton(
                        onPressed: _submit,
                        child: Text("Sign In"),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/google.png",
                                    height: 28,
                                    width: 28,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.login_google,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 28,
                                    width: 28,
                                  ),
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                              ),
                              onPressed: () async {},
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
                            TermCondition()
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment(.8, -.7),
              child: SizedBox(
                width: 125,
                height: 125,
                child: Hero(
                  tag: "Logo",
                  child: Image.asset("assets/logo.png"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TermCondition extends StatelessWidget {
  const TermCondition({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppLocalizations.of(context)!.login_term_inform + " "),
        TextButton(
          onPressed: () {
            AndroidIntent(
              action: 'action_view',
              data: 'https://bsahtek.net/privacy/',
            ).launch();
          },
          child: Text(AppLocalizations.of(context)!.login_term_action),
          style: TextButton.styleFrom(
            padding: EdgeInsets.all(0),
          ),
        )
      ],
    );
  }
}

class InfoCollection {
  final Locale locale;
  final String language;

  InfoCollection(this.locale, this.language);
}

class OnboardingInfoCollection extends StatefulWidget {
  const OnboardingInfoCollection({
    super.key,
  });

  @override
  State<OnboardingInfoCollection> createState() =>
      _OnboardingInfoCollectionState();
}

class _OnboardingInfoCollectionState extends State<OnboardingInfoCollection> {
  String? country = null;
  late String language = "English";

  bool get isFilled {
    return (country?.isNotEmpty ?? false) && language.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
  }

  void submit(BuildContext context) {
    if (!isFilled) return;
    final locale = language.startsWith("Fr")
        ? Locale("fr")
        : language.startsWith("En")
            ? Locale("en")
            : Locale("ar");

    Navigator.of(context).pop(InfoCollection(locale, language));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocale = Localizations.localeOf(context);
    if (currentLocale == Locale("fr")) language = "Français";
    if (currentLocale == Locale("ar")) language = "العربية";
    if (currentLocale == Locale("en")) language = "English";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              AppLocalizations.of(context)!.login_region_title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 21,
              ),
            ),
          ),
          SizedBox(height: 32),
          Text(AppLocalizations.of(context)!.login_region_country),
          SizedBox(height: 8),
          DropdownButton2(
              isExpanded: true,
              underline: SizedBox.shrink(),
              value: country,
              onChanged: (e) => setState(() => country = e),
              buttonStyleData: ButtonStyleData(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade600.withOpacity(.2),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              hint: Text(AppLocalizations.of(context)!.login_region_country),
              items: [
                "Algerie",
                "France",
                "Italy",
                "Mouritania",
                "Marocco",
                "Tunisie",
                "Spain"
              ]
                  .map(
                    (e) => DropdownMenuItem(
                      child: Text(e),
                      value: e,
                      enabled: e == "Algerie",
                    ),
                  )
                  .toList()),
          SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.login_region_language),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["العربية", "Français", "English"]
                .map(
                  (lng) => OutlinedButton(
                    onPressed: () => {setState(() => language = lng)},
                    child: Text(lng),
                    style: lng == language
                        ? OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  ),
                )
                .toList(),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: isFilled ? () => submit(context) : null,
            child: Text(AppLocalizations.of(context)!.login_region_continue),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 45),
            ),
          )
        ],
      ),
    );
  }
}
