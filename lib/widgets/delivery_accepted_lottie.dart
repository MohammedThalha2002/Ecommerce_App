import 'package:ecommerce/Pages/Product_home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class DeliveryAcceptedLottie extends StatefulWidget {
  const DeliveryAcceptedLottie({Key? key}) : super(key: key);

  @override
  _DeliveryAcceptedLottieState createState() => _DeliveryAcceptedLottieState();
}

class _DeliveryAcceptedLottieState extends State<DeliveryAcceptedLottie>
    with SingleTickerProviderStateMixin {
  late AnimationController lottieController;
  @override
  void initState() {
    // TODO: implement initState
    lottieController = AnimationController(vsync: this, duration: Duration());
    lottieController.addStatusListener(
      (status) async {
        if (status == AnimationStatus.completed) {
          Get.to(
            HomePage(),
            transition: Transition.native,
          );
          lottieController.reset();
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          "assets/cart-box.json",
          repeat: false,
          controller: lottieController,
          onLoaded: (composition) {
            lottieController.duration = composition.duration;
            lottieController.forward();
          },
        ),
      ),
    );
  }
}
