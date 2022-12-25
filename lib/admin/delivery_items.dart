import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/admin/user_ordered_products.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class deliveryItems extends StatefulWidget {
  const deliveryItems({Key? key}) : super(key: key);

  @override
  _deliveryItemsState createState() => _deliveryItemsState();
}

class _deliveryItemsState extends State<deliveryItems> {
  User? _user = FirebaseAuth.instance.currentUser;
  var stream;
  var OrderedUsersStream = FirebaseFirestore.instance
      .collection("OrderedUsers")
      .orderBy("CreatedDate")
      .snapshots();
  var NewOrderedUsersStream = FirebaseFirestore.instance
      .collection("OrderedUsers")
      .where('status', isEqualTo: 'OrderAccepted')
      .orderBy("CreatedDate")
      .snapshots();
  var OrderProcessedUsersStream = FirebaseFirestore.instance
      .collection("OrderedUsers")
      .orderBy("CreatedDate")
      .where('status', isEqualTo: 'OrderProcessed')
      .snapshots();
  var ShippedItemsUsersStream = FirebaseFirestore.instance
      .collection("OrderedUsers")
      .orderBy("CreatedDate")
      .where('status', isEqualTo: 'Shipped')
      .snapshots();

  var userId;
  void StatusUpdate({var docId, var status}) {
    FirebaseFirestore.instance
        .collection("OrderedUsers")
        .doc(docId)
        .update({"status": status});
  }

  void deleteTheDeliverdItems(docId) {
    FirebaseFirestore.instance.collection("OrderedUsers").doc(docId).delete();
    FirebaseFirestore.instance
        .collection('Delivery')
        .doc(docId)
        .collection("Products")
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    }).whenComplete(() => print("deleted all the delivered products"));
  }

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
    // TODO: implement initState
    super.initState();
    stream = OrderedUsersStream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      appBar: AppBar(
        title: Text("Delivery Items"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
                        stream = OrderedUsersStream;
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
                      child: Text(
                        "All",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  //Showing All category
                  InkWell(
                    onTap: () {
                      setState(() {
                        stream = NewOrderedUsersStream;
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
                      child: Text(
                        "New Orders",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  //Showing T-Shirts category
                  InkWell(
                    onTap: () {
                      setState(() {
                        stream = OrderProcessedUsersStream;
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
                      child: Text(
                        "Processed Orders",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  //Showing Shirts category
                  InkWell(
                    onTap: () {
                      setState(() {
                        stream = ShippedItemsUsersStream;
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
                      child: Text(
                        "On the Way",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "No Orders Found",
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.docs.length == 0) {
                  return Center(
                    child: Text(
                      "No Orders Found",
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      String id = snapshot.data!.docs[index].id;
                      DocumentSnapshot data = snapshot.data!.docs[index];
                      return InkWell(
                        splashColor: Colors.pinkAccent,
                        onTap: () {
                          userId = data['userId'];
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: ((context) => UserOrderedProducts(
                                    docId: userId,
                                  )),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.all(4),
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // border: Border.all(),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                data['profilePic'],
                              ),
                            ),
                            title: Text(data['name']),
                            subtitle: Text(
                              data['PhoneNumber'] +
                                  "\n" +
                                  data['CreatedDate']
                                      .toString()
                                      .substring(0, 10),
                            ),
                            trailing: InkWell(
                              onTap: () {
                                Alert(
                                  context: context,
                                  title: "CHANGE THE STATUS",
                                  image: Lottie.asset('assets/ecommerce.json'),
                                  buttons: [
                                    DialogButton(
                                      child: Text(
                                        "Order Processed",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      onPressed: () {
                                        var docId = snapshot
                                            .data!.docs[index].reference.id
                                            .toString();
                                        StatusUpdate(
                                            docId: docId,
                                            status: "OrderProcessed");
                                        //
                                        Navigator.pop(context);
                                      },
                                      color: Colors.pink,
                                    ),
                                    DialogButton(
                                      child: Text(
                                        "On the Way",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      onPressed: () {
                                        var docId = snapshot
                                            .data!.docs[index].reference.id
                                            .toString();
                                        StatusUpdate(
                                          docId: docId,
                                          status: "Shipped",
                                        );
                                        Navigator.pop(context);
                                      },
                                      color: Color.fromRGBO(0, 179, 134, 1.0),
                                    ),
                                    DialogButton(
                                      child: Text(
                                        "Product Delivered",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      onPressed: () {
                                        var docId = snapshot
                                            .data!.docs[index].reference.id
                                            .toString();
                                        deleteTheDeliverdItems(docId);
                                        Navigator.pop(context);
                                      },
                                      color: Colors.redAccent,
                                    ),
                                  ],
                                ).show();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Icon(Icons.check_circle_outline_rounded,
                                    color: Colors.green),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
