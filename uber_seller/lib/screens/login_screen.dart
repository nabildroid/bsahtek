import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_seller/model/seller.dart';
import 'package:uber_seller/model/sellerSubmit.dart';

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

    if (isNeedToSubmit) {
      return FormSubmit();
    }

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

class FormSubmit extends StatefulWidget {
  FormSubmit({Key? key}) : super(key: key);

  @override
  State<FormSubmit> createState() => _FormSubmitState();
}

class _FormSubmitState extends State<FormSubmit> {
  /***
   *  name: z.string(),
  phone: z.string(),
  address: z.string(),
  wilaya: z.string(),
  country: z.string(),
  storeType: z.string(),
  storeName: z.string(),
  storeAddress: z.string(),
  photo: z.string(),
  active: z.boolean().default(false),
   */

  final name = TextEditingController(text: "Mohamed");
  final country = TextEditingController(text: "Algeria");
  final wilaya = TextEditingController(text: "Algiers");
  final address = TextEditingController(text: "Algiers");
  final storeType = TextEditingController(text: "Grocery");
  final storeName = TextEditingController(text: "Grocery");
  final storeAddress = TextEditingController(text: "Grocery");

  void submit() async {
    final user = Server.auth.currentUser!;

    final submit = SellerSubmit(
      name: name.text,
      country: country.text,
      wilaya: wilaya.text,
      storeAddress: storeAddress.text,
      storeName: storeName.text,
      storeType: storeType.text,
      address: address.text,
      photo: "https://firebase.flutter.dev/img/flutterfire_300x.png",
    );

    await Server().submitSeller(user.uid, user.phoneNumber!, submit);
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
