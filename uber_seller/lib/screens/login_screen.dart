import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../model/seller.dart';
import '../model/sellerSubmit.dart';
import '../repository/server.dart';

/**HAS Zero 000 Communication with Context */
class LoginScreen extends StatefulWidget {
  final Seller? user;
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

  final phoneController = TextEditingController(text: "798398545");
  final otpController = TextEditingController(text: "111111");

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

  void checkUser(Seller? user) {
    final isAlreadyLogin = user != null;
    final isAlreadyActivated = user?.isActive == true;

    if (isAlreadyActivated) {
      stopListening.call();
      Navigator.of(context).pop(user);
      return;
    }

    if (isAlreadyLogin) {
      setState(() => isNeedToSubmit = true);
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
      return FormSubmit(
        defaultImage: googleUser?.photoUrl,
      );
    }

    return Scaffold(
        body: Column(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.green,
            child: Column(
              children: [
                if (!needGoogle && googleUser != null)
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top),
                    child: ListTile(
                      leading: googleUser!.photoUrl != null
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage(googleUser!.photoUrl!),
                            )
                          : null,
                      title: Text(googleUser!.displayName ??
                          Server.auth.currentUser!.email!),
                    ),
                  ),
                Expanded(
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
              ],
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
                    Text(
                      "You will receive a code in your phone ${phoneController.text}",
                      style: TextStyle(
                        color: Colors.grey,
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
  final String? defaultImage;
  FormSubmit({
    Key? key,
    this.defaultImage,
  }) : super(key: key);

  @override
  State<FormSubmit> createState() => _FormSubmitState();
}

class _FormSubmitState extends State<FormSubmit> {
  late String photoURL;

  final name = TextEditingController(text: "Mohamed");
  final country = TextEditingController(text: "Algeria");
  final wilaya = TextEditingController(text: "Algiers");
  final address = TextEditingController(text: "Algiers");
  final storeType = TextEditingController(text: "Grocery");
  final storeName = TextEditingController(text: "Grocery");
  final storeAddress = TextEditingController(text: "Grocery");

  bool isThankYou = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    photoURL = widget.defaultImage ??
        "https://firebase.flutter.dev/img/flutterfire_300x.png";
  }

  void submit() async {
    setState(() => isLoading = true);
    final user = Server.auth.currentUser!;

    final submit = SellerSubmit(
      name: name.text,
      country: country.text,
      wilaya: wilaya.text,
      storeAddress: storeAddress.text,
      storeName: storeName.text,
      storeType: storeType.text,
      address: address.text,
      photo: photoURL,
    );

    await Server().submitSeller(user.uid, user.phoneNumber!, submit);

    setState(() {
      isLoading = false;
      isThankYou = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Request"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: isThankYou
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text("Thank you for your submission"),
                  SizedBox(height: 8),
                  Text("We will contact you soon"),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(10),
                        elevation: 3,
                        child: InkWell(
                          onTap: () async {
                            setState(() => isLoading = true);
                            final newPhotoURL = await Server().pickImage(
                                Server.auth.currentUser!.uid, "/seller/photo");
                            if (newPhotoURL != null) {
                              setState(() {
                                photoURL = newPhotoURL;
                              });
                            }

                            setState(() => isLoading = false);
                          },
                          child: Center(
                            child: Container(
                              height: 200,
                              child: photoURL != null
                                  ? Image.network(
                                      photoURL!,
                                      fit: BoxFit.cover,
                                    )
                                  : SizedBox(),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Text Inputs
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
                    SizedBox(height: 8),
                    TextFormField(
                      controller: storeType,
                      decoration: InputDecoration(labelText: "Store Type"),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: storeName,
                      decoration: InputDecoration(labelText: "Store Name"),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: storeAddress,
                      decoration: InputDecoration(labelText: "Store Address"),
                    ),

                    SizedBox(height: 32),

                    if (!isLoading)
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
