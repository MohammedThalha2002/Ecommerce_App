import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future signInWithGoogle() async {
  // Trigger the authentication flow
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } on Exception catch (e) {
    Get.defaultDialog(title: e.toString());
    // TODO
  }
}

Future<void> signOutFromGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signOut();
  await FirebaseAuth.instance.signOut();
}
