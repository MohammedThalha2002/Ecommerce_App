import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class noInternet extends StatelessWidget {
  const noInternet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/no_internet.json'),
        Text(
          "Please Check Your Connection",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ],
    ));
  }
}
