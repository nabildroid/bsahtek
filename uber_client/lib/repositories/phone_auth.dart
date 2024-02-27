import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'server.dart';

class PhoneAuth {
  PhoneAuth() {}

  static String? _verificationId;

  static final _confirmFuture = Completer<PhoneAuthCredential?>();

  static Future<PhoneAuthCredential?> confirm(String otp) async {
    if (_verificationId == null) return null;

    PhoneAuthCredential credential = await PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    return credential;
  }

  static auth(String phone) async {
    final waiter = Completer<void>();

    await Server.auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) {
        _confirmFuture.complete(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print("error");
        waiter.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        waiter.complete();
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    return await waiter.future;
  }
}
