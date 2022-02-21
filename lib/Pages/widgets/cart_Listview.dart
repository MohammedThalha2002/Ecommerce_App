import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Pages/product_overview.dart';
import 'package:ecommerce/backend/crud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CartListView extends StatefulWidget {
  final Stream<QuerySnapshot<Object?>> stream;
  final User? user;
  final AnimationController animationController;
  const CartListView({
    Key? key,
    required this.stream,
    required this.user,
    required this.animationController,
  }) : super(key: key);

  @override
  _CartListViewState createState() => _CartListViewState();
}

class _CartListViewState extends State<CartListView> {
  var _totalPrice;
  int printingPrice = 0;
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
    _totalPrice = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection("Cart")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          printingPrice += int.parse(doc["price"]);
        });
        print("totalprice" + printingPrice.toString());
      });
    });
  }

  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection("Users");
  // Current User Id
  User? _user = FirebaseAuth.instance.currentUser;
  //Add to WhishList
  Future _AddQuantity({
    var docId,
    var quantity,
  }) {
    return _userRef.doc(_user!.uid).collection("Cart").doc(docId).update({
      "quantity": quantity,
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
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot data = snapshot.data!.docs[index];
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(-0.5 * index + 1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: widget.animationController,
                      curve: Curves.fastOutSlowIn,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: widget.animationController,
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () {
                          String docId = snapshot.data!.docs[index].reference.id
                              .toString();
                          int docIdsize = docId.length;
                          String docIdOutput =
                              docId.substring(0, docIdsize - 3);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: ((context) => ProductOverview(
                                    docId: docIdOutput,
                                    index: index,
                                  )),
                            ),
                          );
                        },
                        splashColor: Colors.pinkAccent,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                data['imgUrl'],
                                height: 100,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['title']),
                                Row(
                                  children: [
                                    Text(
                                      "₹",
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontFamily: "Roboto"),
                                    ),
                                    Text(
                                      data['price'],
                                      style: TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: Colors.pinkAccent[100],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(1),
                                        child: Text(
                                          data['size'],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Color.fromARGB(255, 245, 138, 174),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              // quantity--;
                                              var docId = snapshot.data!
                                                  .docs[index].reference.id
                                                  .toString();
                                              int quantity =
                                                  int.parse(data['quantity']) -
                                                      1;
                                              _AddQuantity(
                                                docId: docId,
                                                quantity: quantity.toString(),
                                              );
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Text(
                                              "-",
                                            ),
                                          ),
                                        ),
                                        Card(
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Text(
                                              data['quantity'].toString(),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              // quantity++;
                                              var docId = snapshot.data!
                                                  .docs[index].reference.id
                                                  .toString();
                                              int quantity =
                                                  int.parse(data['quantity']) +
                                                      1;
                                              _AddQuantity(
                                                docId: docId,
                                                quantity: quantity.toString(),
                                              );
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Text(
                                              "+",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            InkWell(
                              splashColor: Colors.pink,
                              onTap: () async {
                                var docId = snapshot
                                    .data!.docs[index].reference.id
                                    .toString();
                                deleteProduct(
                                  delProductId: docId,
                                  user: widget.user,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: FaIcon(
                                  FontAwesomeIcons.trashAlt,
                                  color: Colors.red.withOpacity(0.7),
                                  size: 25,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Container(
              height: 55,
            ),
          ],
        );
      },
    );
  }
}
