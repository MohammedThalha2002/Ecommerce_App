import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Pages/widgets/product_image_fullView.dart';
import 'package:ecommerce/widgets/no_internet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:like_button/like_button.dart';
import 'package:random_string/random_string.dart';
import 'package:shimmer/shimmer.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ProductOverview extends StatefulWidget {
  final docId;
  final int index;
  const ProductOverview({Key? key, required this.docId, required this.index})
      : super(key: key);

  @override
  _ProductOverviewState createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
  // Products Collection Reference
  final CollectionReference _productRef =
      FirebaseFirestore.instance.collection("Products");
  // Users Collection Reference
  //Storing Process
  // user (Collection) -> User Id (Document) -> Cart (new Collection), Favourites(new Collection) -> ProductId(document) -->
  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection("Users");
  final Stream<QuerySnapshot> _userSnapshots =
      FirebaseFirestore.instance.collection("Users").snapshots();
  // Current User Id
  User? _user = FirebaseAuth.instance.currentUser;
  //Add to Cart
  Future _addToCart() {
    return _userRef
        .doc(_user!.uid)
        .collection("Cart")
        .doc(widget.docId + randomString(3))
        .set(
      {
        "imgUrl": ImgUrl[selectedImageIndex],
        "title": title,
        "description": desc,
        "price": price,
        "size": selectedSize,
        "category": category,
        "quantity": "1",
      },
    );
  }

  //Add to WhishList
  Future _addToWhishList() {
    print(widget.docId);
    return _userRef
        .doc(_user!.uid)
        .collection("Whishlist")
        .doc(widget.docId + randomString(3))
        .set({
      "imgUrl": ImgUrl[selectedImageIndex],
      "title": title,
      "description": desc,
      "price": price,
      "size": selectedSize,
      "category": category,
    });
  }

  //Required Variables
  String title = "",
      desc = "",
      price = "",
      selectedSize = "",
      category = '',
      likes = '';
  List sizeList = [];
  List ImgUrl = [];
  int isSelected = 0;
  bool isLiked = false;
  var docId;
  var data;
  late bool isloading;
  int selectedImageIndex = 0;
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

  @override
  void initState() {
    checkConnection();
    isloading = true;
    // TODO: implement initState
    super.initState();
    gettingData();
  }

  void gettingData() async {
    docId = widget.docId;
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
      likes = data['likes'].toString();
      print(likes);
    });
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        isloading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return hasInternet
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text("Product Overview"),
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // shrinkWrap : true,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "₹" + price,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Row(
                              children: [
                                LikeButton(
                                  isLiked: isLiked,
                                  onTap: (isLiked) async {
                                    setState(() {
                                      this.isLiked = !isLiked;
                                    });
                                    print(this.isLiked);
                                    Future.delayed(Duration(milliseconds: 100))
                                        .then((_) {
                                      setState(() {
                                        if (this.isLiked) {
                                          likes =
                                              (int.parse(likes) + 1).toString();
                                        } else {
                                          likes =
                                              (int.parse(likes) - 1).toString();
                                        }
                                      });
                                      FirebaseFirestore.instance
                                          .collection("Products")
                                          .doc(widget.docId)
                                          .update({
                                        "likes": likes,
                                      });
                                      print("Liked");
                                    });
                                    return !isLiked;
                                  },
                                  likeBuilder: (bool isLiked) {
                                    return Icon(
                                      Icons.favorite,
                                      color:
                                          isLiked ? Colors.pink : Colors.grey,
                                      size: 22,
                                    );
                                  },
                                  bubblesColor: BubblesColor(
                                      dotPrimaryColor: Colors.white,
                                      dotSecondaryColor: Colors.white,
                                      dotThirdColor: Color(0xFFFF5722),
                                      dotLastColor: Color(0xFFF44336)),
                                  size: 22,
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Text(likes),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        isloading == false
                            ? Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                height: MediaQuery.of(context).size.width * 0.7,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.pinkAccent, width: 2),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: ((context) =>
                                            ProductImageFullView(
                                              imgUrl:
                                                  ImgUrl[selectedImageIndex],
                                            )),
                                      ),
                                    );
                                  },
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: _userSnapshots,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Text('Something went wrong');
                                      }

                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      return Hero(
                                        tag: "producthome" +
                                            widget.index.toString(),
                                        child: Image.network(
                                          ImgUrl[selectedImageIndex],
                                          fit: BoxFit.contain,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            : Shimmer.fromColors(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.7,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                baseColor: (Colors.grey[200])!,
                                highlightColor: (Colors.grey[50])!,
                                loop: 3,
                              ),
                        SizedBox(
                          height: 110,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: ImgUrl.length,
                            itemBuilder: ((context, index) {
                              return selectedImageIndex == index
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedImageIndex = index;
                                          });
                                        },
                                        child: Container(
                                          height: 100,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                                color: Colors.pinkAccent,
                                                width: 3),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            child: Image.network(
                                              ImgUrl[index],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedImageIndex = index;
                                          });
                                        },
                                        child: Container(
                                          height: 100,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                                color: (Colors.grey[200])!),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            child: Image.network(
                                              ImgUrl[index],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                            }),
                          ),
                        ),
                        Text(
                          "Available Sizes",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "Select yor size",
                          style: TextStyle(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              children: [
                                for (var i = 0; i < sizeList.length; i++)
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      print(i);
                                      isSelected = i;
                                      selectedSize = sizeList[isSelected];
                                      print(selectedSize);
                                    }),
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: isSelected == i
                                            ? Colors.pinkAccent
                                            : Colors.grey[350],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Text(sizeList[i]),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "About this Product",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          desc,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          print("add to Whishlist touched");
                          _addToWhishList();
                          showTopSnackBar(
                            context,
                            CustomSnackBar.success(
                              message: "Added to your Whishlist",
                              backgroundColor: Colors.pinkAccent,
                            ),
                            displayDuration: Duration(seconds: 1),
                          );
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width / 2,
                          decoration: BoxDecoration(
                            color: Colors.black87,
                          ),
                          child: Row(
                            children: [
                              Spacer(),
                              FaIcon(
                                FontAwesomeIcons.heart,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Add to Whishlist",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          print("add to cart touched");
                          _addToCart();
                          showTopSnackBar(
                            context,
                            CustomSnackBar.success(
                              message: "Added to your Cart",
                              backgroundColor: Colors.pinkAccent,
                            ),
                            displayDuration: Duration(seconds: 1),
                          );
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width / 2,
                          decoration: BoxDecoration(
                            color: Colors.pink,
                          ),
                          child: Row(
                            children: [
                              Spacer(),
                              FaIcon(
                                FontAwesomeIcons.shoppingCart,
                                color: Colors.black,
                                size: 16,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Add to Cart",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        : noInternet();
  }
}
