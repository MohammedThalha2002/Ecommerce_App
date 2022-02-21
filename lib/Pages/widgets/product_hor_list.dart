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

  Future _addToWhishList({
    docId,
    ImgUrl,
    title,
    desc,
    price,
    selectedSize,
    category,
  }) {
    return _userRef
        .doc(_user!.uid)
        .collection("Whishlist")
        .doc(docId + randomString(3))
        .set(
      {
        "imgUrl": ImgUrl,
        "title": title,
        "description": desc,
        "price": price,
        "size": selectedSize,
        "category": category,
      },
    );
  }

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

  void gettingData({required docId}) async {
    print(docId.toString());
    data = await FirebaseFirestore.instance
        .collection('Products')
        .doc(docId)
        .get();

    setState(() {
      title = data['title'].toString();
      print(title);
      desc = data['description'].toString();
      print(desc);
      price = data['price'].toString();
      print(price);
      category = data['category'].toString();
      print(category);
      sizeList = data['size'];
      print(sizeList);
      ImgUrl = data['imgUrl'];
      print(ImgUrl);
      selectedSize = sizeList[isSelected];
      print(selectedSize);
    });
    _addToWhishList(
      ImgUrl: ImgUrl[0],
      category: category,
      desc: desc,
      docId: docId,
      price: price,
      selectedSize: sizeList[0],
      title: title,
    );
  }

  bool isLiked = false;

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

        if (hasInternet) {
          return GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 245,
            ),
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot data = snapshot.data!.docs[index];
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
                        padding: EdgeInsets.all(10),
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
                                child: Image.network(
                                  data['imgUrl'][0],
                                  height: 130,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 6),
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                data['title'].toString().length < 20
                                    ? data['title'].toString()
                                    : data['title']
                                            .toString()
                                            .substring(0, 20) +
                                        "..",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 6),
                                    alignment: Alignment.bottomLeft,
                                    child: Row(
                                      children: [
                                        Text(
                                          "₹",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 46, 170, 52),
                                            fontSize: 16,
                                            fontFamily: "Roboto",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          data['price'],
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 46, 170, 52),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CircleAvatar(
                                    backgroundColor: Colors.pinkAccent,
                                    radius: 16,
                                    child: LikeButton(
                                      onTap: (isLiked) async {
                                        // this.isLiked = !isLiked;
                                        Future.delayed(
                                                Duration(milliseconds: 100))
                                            .then((_) {
                                          var docId = snapshot
                                              .data!.docs[index].reference.id
                                              .toString();
                                          gettingData(docId: docId);
                                          // Add to the favourite
                                          print("Added to the favourite");
                                          final snackBar = SnackBar(
                                            duration: Duration(seconds: 1),
                                            content: const Text(
                                                'Added to our Favourites'),
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
                                          size: 16,
                                        );
                                      },
                                      bubblesColor: BubblesColor(
                                          dotPrimaryColor: Colors.white,
                                          dotSecondaryColor: Colors.white,
                                          dotThirdColor: Color(0xFFFF5722),
                                          dotLastColor: Color(0xFFF44336)),
                                      size: 14,
                                    ),
                                  )
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
