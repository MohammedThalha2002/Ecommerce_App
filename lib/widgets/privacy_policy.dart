import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.network(
          'https://assets6.lottiefiles.com/packages/lf20_dyq0qz89/data.json',
        ),
      ),
    );
  }
}
