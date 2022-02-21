import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Pages/Product_home_page.dart';
import 'package:ecommerce/Pages/widgets/my_whishlist_view.dart';
import 'package:ecommerce/widgets/no_internet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class MyWhishList extends StatefulWidget {
  const MyWhishList({Key? key}) : super(key: key);

  @override
  _MyWhishListState createState() => _MyWhishListState();
}

class _MyWhishListState extends State<MyWhishList>
    with SingleTickerProviderStateMixin {
  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection("Users");
  // Current User Id
  User? _user = FirebaseAuth.instance.currentUser;
  var _WhishlistStream;
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
    // TODO: implement initState
    super.initState();
    checkConnection();
    _WhishlistStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(_user!.uid)
        .collection("Whishlist")
        .snapshots();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    Timer(Duration(seconds: 1), () => animationController.forward());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return hasInternet
        ? Scaffold(
            backgroundColor: Colors.pink[100],
            appBar: AppBar(
              title: Text("My WhishList"),
            ),
            body: Padding(
                padding: EdgeInsets.all(8),
                child: SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: Column(
                      children: [
                        MyWhishListView(
                          stream: _WhishlistStream,
                          user: _user,
                          animationController: animationController,
                        ),
                      ],
                    ))),
          )
        : noInternet();
  }
}
