import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/admin/admin_add_product.dart';
import 'package:ecommerce/admin/admin_home_listView.dart';
import 'package:ecommerce/admin/admin_update_page.dart';
import 'package:ecommerce/admin/delivery_items.dart';
import 'package:ecommerce/backend/crud.dart';
import 'package:ecommerce/widgets/no_internet.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shimmer/shimmer.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel>
    with SingleTickerProviderStateMixin {
  //Getting the Stream of data from the firestore database especially from products collection
  final Stream<QuerySnapshot> _AllStream =
      FirebaseFirestore.instance.collection('Products').snapshots();
  //For T-shirts
  final Stream<QuerySnapshot> _SareeStream = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Cotton_saree')
      .snapshots();
  //For Chudis
  final Stream<QuerySnapshot> _ChudithaarStream = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Chudihtaar')
      .snapshots();

  var stream;
  late bool isloading;
  late StreamSubscription internetconnection;
  bool hasInternet = false;
  //set variable for Connectivity subscription listiner
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
    // using this listiner, you can get the medium of connection as well.
    isloading = true;
    // TODO: implement initState
    checkConnection();
    super.initState();
    stream = _AllStream;
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    Timer(
      Duration(seconds: 1),
      () => animationController.forward(),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (hasInternet == false) {
      return noInternet();
    } else {
      return Scaffold(
        backgroundColor: Colors.pink[100],
        appBar: AppBar(
          title: Text("Admin Panel"),
          centerTitle: true,
          actions: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.3),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => deliveryItems()));
                },
                icon: Icon(
                  Icons.delivery_dining,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(8),
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      //Showing All category
                      InkWell(
                        onTap: () {
                          setState(() {
                            stream = _AllStream;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(4),
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.pinkAccent,
                          ),
                          child: Text("All"),
                        ),
                      ),
                      //Showing T-Shirts category
                      InkWell(
                        onTap: () {
                          setState(() {
                            stream = _SareeStream;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(4),
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.pinkAccent,
                          ),
                          child: Text("Sarees"),
                        ),
                      ),
                      //Showing Shirts category
                      InkWell(
                        onTap: () {
                          setState(() {
                            stream = _ChudithaarStream;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(4),
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.pinkAccent,
                          ),
                          child: Text("Chudithaars"),
                        ),
                      ),
                      //Showing Chudithaar category
                    ],
                  ),
                ),
                AdminHomeListView(
                  stream: stream,
                  animationController: animationController,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(
              AdminAddProducts(),
              transition: Transition.native,
              duration: Duration(seconds: 1),
            );
          },
          child: Icon(Icons.add),
          tooltip: "Add a Product",
          elevation: 10,
        ),
      );
    }
  }
}

Widget ShimmerContainerLarge() {
  return Shimmer.fromColors(
    baseColor: (Colors.grey[300])!,
    highlightColor: (Colors.grey[200])!,
    loop: 3,
    child: Container(
      width: double.infinity,
      height: 100,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
    ),
  );
}
