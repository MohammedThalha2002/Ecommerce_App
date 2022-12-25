import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Pages/Product_home_page.dart';
import 'package:ecommerce/Pages/delivery_details.dart';
import 'package:ecommerce/Pages/product_overview.dart';
import 'package:ecommerce/Pages/widgets/cart_Listview.dart';
import 'package:ecommerce/widgets/no_internet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:animated_button/animated_button.dart';

class MyCart extends StatefulWidget {
  const MyCart({Key? key}) : super(key: key);

  @override
  _MyCartState createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> with SingleTickerProviderStateMixin {
  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection("Users");
  // Current User Id
  User? _user = FirebaseAuth.instance.currentUser;
  var _CartStream;
  var _totalPrice;
  int FirstprintingPrice = 0;
  int LastprintingPrice = 0;
  int total = 0;
  int? CartLenght;
  bool hasInternet = false;
  checkConnection() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (result == true) {
      setState(() {
        hasInternet = true;
      });
    } else {
      setState(() {
        hasInternet = false;
      });
      print('No internet :( Reason:');
    }
    InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;

      setState(() {
        this.hasInternet = hasInternet;
      });
    });
  }

  late AnimationController animationController;
  @override
  void initState() {
    checkConnection();
    // TODO: implement initState
    super.initState();
    _CartStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(_user!.uid)
        .collection("Cart")
        .snapshots();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    Timer(Duration(milliseconds: 1000), () => animationController.forward());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationController.dispose();
  }

  Future<void> deleteProduct(
      {required String delProductId, required User? user}) async {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(user!.uid)
        .collection("Cart")
        .doc(delProductId)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return hasInternet
        ? Scaffold(
            backgroundColor: Colors.pink[100],
            appBar: AppBar(
              title: Text("My Cart"),
            ),
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CartListView(
                            stream: _CartStream,
                            user: _user,
                            animationController: animationController,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Amount",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            StreamBuilder(
                                stream: _CartStream,
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else {
                                    total = 0;
                                    CartLenght = snapshot.data!.docs.length;
                                    snapshot.data!.docs.forEach((result) {
                                      total += int.parse(result['price']) *
                                          int.parse(result['quantity']);
                                    });
                                    print("$total");
                                    print("$CartLenght");
                                    return Text(
                                      "₹" + "$total",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    );
                                  }
                                }),
                          ],
                        ),
                        AnimatedButton(
                          child: Text(
                            'Continuous',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          color: Colors.pinkAccent,
                          height: 40,
                          width: 150,
                          onPressed: () {
                            if (CartLenght == 0) {
                              showTopSnackBar(
                                  context,
                                  CustomSnackBar.error(
                                    message: "Your Cart is Empty",
                                    backgroundColor: Colors.redAccent,
                                  ),
                                  showOutAnimationDuration:
                                      Duration(milliseconds: 500),
                                  displayDuration: Duration(seconds: 1),
                                  hideOutAnimationDuration:
                                      Duration(milliseconds: 500));
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => DeliveryDetails()));
                            }
                          },
                        ),
                        //
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : noInternet();
  }
}
