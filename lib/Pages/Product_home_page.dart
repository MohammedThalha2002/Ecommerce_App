import 'dart:async';
import 'dart:convert';
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
import 'package:ecommerce/backend/search_results.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/widgets/delivery_address.dart';
import 'package:ecommerce/widgets/privacy_policy.dart';
import 'package:ecommerce/widgets/size_container.dart';
import 'package:ecommerce/widgets/support.dart';
import 'package:ecommerce/widgets/terms_and_conditions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterflow_paginate_firestore/paginate_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'auth/auth_checker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  //Getting the Stream of data from the firestore database especially from products collection
  late Stream<QuerySnapshot> stream;
  //For All Products
  final Stream<QuerySnapshot> Normalstream =
      FirebaseFirestore.instance.collection('Products').snapshots();
  final Stream<QuerySnapshot> Cotton_Vesti_Stream = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Cotton_vesti')
      .snapshots();
  final Stream<QuerySnapshot> Cotton_Lungi_Stream = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Cotton_lungi')
      .snapshots();
  final Stream<QuerySnapshot> Cotton_Shirt_Bit_Stream = FirebaseFirestore
      .instance
      .collection('Products')
      .where('category', isEqualTo: 'Cotton_shirt_bit')
      .snapshots();
  final Stream<QuerySnapshot> Baby_Boy_Stream = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Boy_baby_dress')
      .snapshots();
  final Stream<QuerySnapshot> Chudithaar_Stream = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Chudithaar')
      .snapshots();
  final Stream<QuerySnapshot> Leggins_Stream = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Leggins')
      .snapshots();
  final Stream<QuerySnapshot> Tops_Stream = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Tops')
      .snapshots();
  final Stream<QuerySnapshot> shawls_Stream = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'shawls')
      .snapshots();
  final Stream<QuerySnapshot> Girl_Frock_Stream = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Girl_baby_frock')
      .snapshots();
  final Stream<QuerySnapshot> Girl_Midi_Stream = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Girl_baby_midi')
      .snapshots();
  final Stream<QuerySnapshot> Silk_saree_Stream = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Silk_saree')
      .snapshots();
  final Stream<QuerySnapshot> Poonam_saree_Stream = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Poonam_saree')
      .snapshots();
  final Stream<QuerySnapshot> Cotton_saree_Stream = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Cotton_saree')
      .snapshots();
  final Stream<QuerySnapshot> Gang_dress_Stream = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Gang_dress')
      .snapshots();

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
    stream = Normalstream;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    Timer(
      Duration(seconds: 1),
      () => _animationController.forward(),
    );
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 3) {
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

    //For ADMIN
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

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  String? selectedCloth;
  StreamUpdatingBySearch({required String val}) {
    setState(() {
      if (val == "Cotton Vesti") {
        stream = Cotton_Vesti_Stream;
      } else if (val == "Cotton Lungi") {
        stream = Cotton_Lungi_Stream;
      } else if (val == "Cotton Shirt Bit") {
        stream = Cotton_Shirt_Bit_Stream;
      } else if (val == "Boy Baby Dress") {
        stream = Baby_Boy_Stream;
      } else if (val == "Cotton Chudihtaar") {
        stream = Chudithaar_Stream;
      } else if (val == "Leggins") {
        stream = Leggins_Stream;
      } else if (val == "Tops") {
        stream = Tops_Stream;
      } else if (val == "Shalls") {
        stream = shawls_Stream;
      } else if (val == "Girl Baby Frock") {
        stream = Girl_Frock_Stream;
      } else if (val == "Girl Baby Midi") {
        stream = Girl_Midi_Stream;
      } else if (val == "Silk Saree") {
        stream = Silk_saree_Stream;
      } else if (val == "Cotton Saree") {
        stream = Cotton_saree_Stream;
      } else if (val == "Poonam Saree") {
        stream = Poonam_saree_Stream;
      } else if (val == "Gang Dress") {
        stream = Gang_dress_Stream;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print("Back button pressed");
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        key: _key,
        backgroundColor: Colors.pink[200],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 130,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 5),
                  Row(children: [
                    SizedBox(
                      width: 5,
                    ),
                    IconButton(
                      onPressed: () {
                        _key.currentState!.openDrawer();
                      },
                      icon: Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    Text(
                      "JM Cotton",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    // ADMIN
                    // InkWell(
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
                    //     child: Icon(
                    //       Icons.admin_panel_settings,
                    //       color: Colors.white,
                    //     ),
                    //   ),
                    // ),
                    // CUSTOMER
                    InkWell(
                      onTap: () {
                        Get.to(
                          MyCart(),
                          transition: Transition.native,
                          duration: Duration(milliseconds: 500),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(height: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 50,
                    child: Form(
                      key: this._formKey,
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: TypeAheadFormField(
                          onSaved: (String? val) {
                            print(val);
                            if (val == null) {
                              setState(() {
                                stream = Normalstream;
                              });
                            }
                          },
                          suggestionsBoxDecoration: SuggestionsBoxDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            color: Colors.white,
                          ),
                          textFieldConfiguration: TextFieldConfiguration(
                            textAlignVertical: TextAlignVertical.bottom,
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.search),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(24)),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(24)),
                            ),
                            controller: this._typeAheadController,
                          ),
                          suggestionsCallback: (pattern) {
                            print("pattern : " + pattern);
                            if (pattern == "") {
                              stream = Normalstream;
                            }
                            return ClothesService.getSuggestions(pattern);
                          },
                          itemBuilder: (context, String suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (String suggestion) {
                            this._typeAheadController.text = suggestion;
                            setState(() {
                              selectedCloth = _typeAheadController.text;
                              print(selectedCloth);
                            });

                            StreamUpdatingBySearch(val: selectedCloth!);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //
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
                      child: PaginateFirestore(
                          query: FirebaseFirestore.instance
                              .collection("BannerImages")
                              .orderBy('image'),
                          itemBuilderType: PaginateBuilderType.pageView,
                          itemBuilder: (context, documentSnapshots, index) {
                            if (documentSnapshots.isEmpty) {
                              return Text('Something went wrong');
                            }
                            return PageView.builder(
                                controller: _pageController,
                                scrollDirection: Axis.horizontal,
                                itemCount: documentSnapshots.length,
                                itemBuilder: (context, int index) {
                                  final data =
                                      documentSnapshots[index].data() as Map?;
                                  final docId = documentSnapshots[index].id;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0, bottom: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              data!['image'].toString(),
                                            ),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          }),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
                        Support(),
                        transition: Transition.native,
                        duration: Duration(milliseconds: 1000),
                        curve: Curves.fastOutSlowIn,
                      );
                    },
                    leading: Icon(FontAwesomeIcons.phoneAlt),
                    title: Text('Support'),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(
              MyWhishList(),
              transition: Transition.native,
              duration: Duration(seconds: 1),
            );
          },
          child: Icon(FontAwesomeIcons.heart),
          elevation: 10,
        ),
      ),
    );
  }
}
