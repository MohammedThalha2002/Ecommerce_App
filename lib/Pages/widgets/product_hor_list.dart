import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Pages/product_overview.dart';
import 'package:ecommerce/widgets/no_internet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:like_button/like_button.dart';
import 'package:lottie/lottie.dart';
import 'package:random_string/random_string.dart';
import 'package:shimmer/shimmer.dart';

class ProductHorizontalList extends StatefulWidget {
  final stream;
  final AnimationController animationController;
  const ProductHorizontalList({
    Key? key,
    required this.stream,
    required this.animationController,
  }) : super(key: key);

  @override
  _ProductHorizontalListState createState() => _ProductHorizontalListState();
}

class _ProductHorizontalListState extends State<ProductHorizontalList> {
  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection("Users");
  // Current User Id
  User? _user = FirebaseAuth.instance.currentUser;

  //Required Variables
  String title = "", desc = "", price = "", selectedSize = "", category = '';
  List sizeList = [];
  List ImgUrl = [];
  int isSelected = 0;
  var data;
  late bool isloading;
  bool hasInternet = false;
  @override
  void initState() {
    checkConnection();
    isloading = true;
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        isloading = false;
      });
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print("Some problem is occured in the connetion state");
          return Center(
            child: Container(),
          );
        }
        if (snapshot.data!.docs.length == 0) {
          print("No Items Found");
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
              ),
              Text(
                "No Items Found",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              
            ],
          );
        }
        if (hasInternet) {
          return GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 285,
            ),
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot data = snapshot.data!.docs[index];
              String likes = data['likes'].toString();
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, 0.5 * index + 1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: widget.animationController,
                    curve: Curves.fastOutSlowIn,
                  ),
                ),
                child: FadeTransition(
                  opacity: widget.animationController,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      width: (MediaQuery.of(context).size.width / 2) - 15,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: Column(
                          children: [
                            Hero(
                              tag: "producthome" + index.toString(),
                              child: GestureDetector(
                                onTap: () {
                                  var docId = snapshot
                                      .data!.docs[index].reference.id
                                      .toString();
                                  print(docId);
                                  Get.to(
                                    ProductOverview(
                                      docId: docId,
                                      index: index,
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 180,
                                      width:
                                          (MediaQuery.of(context).size.width /
                                                  2) -
                                              24,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15.0)),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15.0)),
                                        child: data['imgUrl'] != null
                                            ? Image.network(
                                                data['imgUrl'][0],
                                                fit: BoxFit.fill,
                                              )
                                            : Image.asset(
                                                "assets/no-image.png"),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      left: 5,
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.pinkAccent,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(14)),
                                        ),
                                        child: Row(
                                          children: [
                                            LikeButton(
                                              // isLiked: isLiked,
                                              onTap: (isLiked) async {
                                                print(likes);
                                                Future.delayed(Duration(
                                                        milliseconds: 100))
                                                    .then((_) {
                                                  setState(() {
                                                    likes =
                                                        (int.parse(likes) + 1)
                                                            .toString();
                                                    print(likes);
                                                  });
                                                  var docId = snapshot.data!
                                                      .docs[index].reference.id
                                                      .toString();
                                                  FirebaseFirestore.instance
                                                      .collection("Products")
                                                      .doc(docId)
                                                      .update({
                                                    "likes": likes,
                                                  });
                                                  print(likes);
                                                  final snackBar = SnackBar(
                                                    duration:
                                                        Duration(seconds: 1),
                                                    content:
                                                        const Text('Liked 👍'),
                                                    backgroundColor:
                                                        (Colors.pinkAccent),
                                                  );
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                });
                                                return !isLiked;
                                              },
                                              likeBuilder: (bool isLiked) {
                                                return Icon(
                                                  FontAwesomeIcons.heart,
                                                  color: isLiked
                                                      ? Colors.white
                                                      : Colors.white,
                                                  size: 14,
                                                );
                                              },
                                              bubblesColor: BubblesColor(
                                                  dotPrimaryColor: Colors.white,
                                                  dotSecondaryColor:
                                                      Colors.white,
                                                  dotThirdColor:
                                                      Color(0xFFFF5722),
                                                  dotLastColor:
                                                      Color(0xFFF44336)),
                                              size: 12,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              data['likes'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 4, top: 3),
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                data['title'].toString().length < 20
                                    ? data['title'].toString()
                                    : data['title'].toString().substring(0, 20),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              SizedBox(
                                                height: 1.5,
                                              ),
                                              Text(
                                                "₹",
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 46, 170, 52),
                                                  fontSize: 13,
                                                  fontFamily: "Roboto",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            data['price'],
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              height: 1,
                                              color: Color.fromARGB(
                                                  255, 46, 170, 52),
                                              fontSize: 20,
                                              fontFamily: "Roboto",
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "SAVE : ",
                                            style: TextStyle(
                                              height : 0.8,
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontFamily: "Roboto",
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "₹",
                                            style: TextStyle(
                                              // height : 0.8,
                                              color: Colors.red,
                                              fontSize: 10,
                                              fontFamily: "Roboto",
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            data['offer'],
                                            style: TextStyle(
                                              // height : 0.8,
                                              color: Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "MRP : ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "₹" + data['MRP'],
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontFamily: "Roboto ",
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

Widget ShimmerContainerLarge() {
  return SizedBox(
    height: 220,
    child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: (Colors.grey[300])!,
            highlightColor: (Colors.grey[200])!,
            child: Container(
              padding: EdgeInsets.only(top: 4),
              margin: EdgeInsets.all(8),
              width: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
            ),
          );
        }),
  );
}
