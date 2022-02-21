import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final trace;
  final error;
  const ErrorScreen({Key? key, required this.trace, required this.error})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Text(
        "$error",
        style: TextStyle(fontSize: 20),
      ),
    ));
  }
}
