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

  signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    if (loginResult.accessToken == null) return;

    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    final user = await Server.auth.signInWithCredential(facebookAuthCredential);
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
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcATop),

                    child: Image.network(
                      'https://www.bsahtek.net/static/logo.png',
                    ), // Replace 'colored_image.png' with your image file path
                  ),
                ),
              ),
            ),
          ),
          Text(
            AppLocalizations.of(context)!.appName,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.slogan,
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
                    AppLocalizations.of(context)!.login_title,
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
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          AppLocalizations.of(context)!.login_google,
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
                    onPressed: () async {
                      final info = await showModalBottomSheet<InfoCollection>(
                        context: context,
                        builder: (_) => OnboardingInfoCollection(),
                      );
                      if (info == null) return;

                      context.read<StaticProvider>().setLocale(info.locale);
                      signInWithGoogle();
                    },
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
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          AppLocalizations.of(context)!.login_facebook,
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
                    onPressed: () async {
                      final info = await showModalBottomSheet<InfoCollection>(
                        context: context,
                        builder: (_) => OnboardingInfoCollection(),
                      );
                      if (info == null) return;

                      context.read<StaticProvider>().setLocale(info.locale);
                      signInWithFacebook();
                    },
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
                  TermCondition()
                ],
              ),
            ),
          ))
        ],
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

  void submit() {
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
              items: ["Algerie", "Tunisie", "Maroc"]
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
            onPressed: isFilled ? submit : null,
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
