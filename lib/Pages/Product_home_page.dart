import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Pages/auth/Login_page.dart';
import 'package:ecommerce/Pages/my_cart.dart';
import 'package:ecommerce/Pages/my_orders_delivery_details.dart';
import 'package:ecommerce/Pages/my_whishlist.dart';
import 'package:ecommerce/Pages/product_overview.dart';
import 'package:ecommerce/Pages/widgets/product_hor_list.dart';
import 'package:ecommerce/admin/admin_add_product.dart';
import 'package:ecommerce/admin/admin_home_page.dart';
import 'package:ecommerce/backend/dataController.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/widgets/delivery_address.dart';
import 'package:ecommerce/widgets/privacy_policy.dart';
import 'package:ecommerce/widgets/size_container.dart';
import 'package:ecommerce/widgets/terms_and_conditions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'auth/auth_checker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  //Getting the Stream of data from the firestore database especially from products collection
  //For All Products
  final Stream<QuerySnapshot> stream =
      FirebaseFirestore.instance.collection('Products').snapshots();
  final Stream<QuerySnapshot> _BannerImagesStream =
      FirebaseFirestore.instance.collection('BannerImages').snapshots();
  late bool isloading;
  TextEditingController searchController = TextEditingController();
  late QuerySnapshot snapshotData;
  PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  late Timer _timer;
  String tokenId = "";
  late AnimationController _animationController;
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    Timer(
      Duration(seconds: 1),
      () => _animationController.forward(),
    );
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 1000),
        curve: Curves.fastOutSlowIn,
      );
    });
    gettingTokenId().then(
      (value) {
        print(value.toString());
        savingTokenId();
      },
    );
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController.dispose();
  }

  Future gettingTokenId() async {
    var status = await OneSignal.shared.getDeviceState();
    setState(() {
      tokenId = status!.userId!;
    });
    print("Token Id of this Device in home page : " + tokenId);
  }

  Future savingTokenId() async {
    await FirebaseFirestore.instance.collection("Admin").doc("Admin").set({
      "tokenId": tokenId,
    });
    print("Token ID is saved to the firestore " + tokenId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[200],
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          //Going to admin panel
          // GestureDetector(
          //   onTap: () {
          //     Get.to(
          //       AdminPanel(),
          //       transition: Transition.native,
          //       duration: Duration(milliseconds: 500),
          //     );
          //   },
          //   child: Container(
          //     margin: EdgeInsets.all(8),
          //     padding: EdgeInsets.all(8),
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       color: Colors.white.withOpacity(0.3),
          //     ),
          //     child: Icon(Icons.admin_panel_settings),
          //   ),
          // ),
          GestureDetector(
            onTap: () {
              Get.to(
                MyCart(),
                transition: Transition.native,
                duration: Duration(seconds: 1),
              );
            },
            child: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
              ),
              child: FaIcon(
                FontAwesomeIcons.shoppingCart,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 0,
          bottom: 0,
        ),
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 15,
              ),
              SlideTransition(
                position: Tween(
                  begin: Offset(-1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.fastOutSlowIn,
                  ),
                ),
                child: FadeTransition(
                  opacity: _animationController,
                  child: SizedBox(
                    height: 165,
                    child: PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        int imageNo = index + 1;
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, bottom: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/banner' + "$imageNo" + ".jpg",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ProductHorizontalList(
                  stream: stream,
                  animationController: _animationController,
                ),
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.pink,
        child: Container(
          child: ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 25,
                ),
                Container(
                  width: 128.0,
                  height: 128.0,
                  margin: const EdgeInsets.only(
                    top: 24.0,
                    bottom: 64.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    user!.photoURL!,
                    fit: BoxFit.fill,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      user!.displayName.toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                    Text(
                      user!.email.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                ListTile(
                  onTap: () {
                    Get.to(
                      MyOrders(),
                      transition: Transition.native,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.fastOutSlowIn,
                    );
                  },
                  leading: Icon(
                    FontAwesomeIcons.shoppingCart,
                  ),
                  title: Text('My Orders'),
                ),
                ListTile(
                  onTap: () {
                    Get.to(
                      DeliveryAddress(),
                      transition: Transition.native,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.fastOutSlowIn,
                    );
                  },
                  leading: Icon(FontAwesomeIcons.mapMarkedAlt),
                  title: Text('My Delievery Address'),
                ),
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  onTap: () {
                    Get.to(
                      TermsAndConditions(),
                      transition: Transition.native,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.fastOutSlowIn,
                    );
                  },
                  leading: Icon(FontAwesomeIcons.solidStickyNote),
                  title: Text('Terms and Conditions'),
                ),
                ListTile(
                  onTap: () {
                    Get.to(
                      PrivacyPolicy(),
                      transition: Transition.native,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.fastOutSlowIn,
                    );
                  },
                  leading: Icon(FontAwesomeIcons.solidBuilding),
                  title: Text('Privacy Policy'),
                ),
                ListTile(
                  onTap: () {
                    signOutFromGoogle();
                    Get.to(
                      LoginPage(),
                      transition: Transition.native,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.fastOutSlowIn,
                    );
                  },
                  leading: FaIcon(Icons.logout),
                  title: Text('LogOut'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
