import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.network(
          'https://assets10.lottiefiles.com/packages/lf20_wmor68ng.json',
        ),
      ),
    );
  }
}
