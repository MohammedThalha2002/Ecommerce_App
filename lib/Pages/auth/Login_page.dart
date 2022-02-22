import 'package:ecommerce/Pages/Product_home_page.dart';
import 'package:ecommerce/Pages/auth/auth_checker.dart';
import 'package:ecommerce/Pages/my_cart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/sign_in_bg.png'),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 400,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Sign in to continue',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Image.asset(
                      "assets/logo.png",
                      width: 200,
                    ),
                    Column(
                      children: [
                        SignInButton(
                          Buttons.Google,
                          text: "Sign in with Google",
                          onPressed: () async {
                            print("Login pressed");
                            try {
                              await signInWithGoogle()
                                  .onError((error, stackTrace) => Get.snackbar(
                                        "ERROR",
                                        "Something went wrong please check your connection",
                                      ))
                                  .then((value) async {
                                if (value.user != null) {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomePage()),
                                      (route) => false);
                                }
                              });
                            } on Exception catch (e) {
                              // TODO
                              print(e);
                            }
                          },
                          elevation: 3,
                          padding: EdgeInsets.all(14),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'By signing in you are agreeing to our',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Terms and Pricacy Policy',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
