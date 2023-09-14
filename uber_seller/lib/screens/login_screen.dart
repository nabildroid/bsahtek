import 'package:android_intent_plus/android_intent.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
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

  AuthCredential? googleCredential;
  GoogleSignInAccount? googleUser;

  VoidCallback stopListening = () {};

  @override
  void initState() {
    // why forcing the hard token refrech and we just login in fresh,
    // when it comes to a no activated user, we need to force the refrech
    stopListening = Server().onUserChange(
      checkUser,
      forceFirst: true,
    );
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

    if (isNeedToSubmit) {
      return FormSubmit(
        defaultImage: googleUser?.photoUrl,
      );
    }

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

  final name = TextEditingController(text: "");
  final phone = TextEditingController(text: "");
  final wilaya = TextEditingController(text: "");
  final address = TextEditingController(text: "");
  final storeType = TextEditingController(text: "");
  final storeName = TextEditingController(text: "");
  final storeAddress = TextEditingController(text: "");

  bool isThankYou = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    photoURL = widget.defaultImage ?? "https://www.bsahtek.net/static/logo.png";
  }

  void submit() async {
    setState(() => isLoading = true);
    final user = Server.auth.currentUser!;

    final submit = SellerSubmit(
      name: name.text,
      country: "Algeirs",
      wilaya: wilaya.text,
      phone: phone.text,
      storeAddress: storeAddress.text,
      storeName: storeName.text,
      storeType: storeType.text,
      address: address.text,
      photo: photoURL,
    );

    await Server().submitSeller(user.uid, submit);

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
        actions: [
          IconButton(
              onPressed: () {
                Server.auth.signOut();
              },
              icon: Icon(Icons.exit_to_app))
        ],
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
                      controller: phone,
                      decoration: InputDecoration(
                        labelText: "phone",
                        prefixText: "+213",
                      ),
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
