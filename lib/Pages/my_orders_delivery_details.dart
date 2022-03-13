import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/widgets/no_internet.dart';
import 'package:ecommerce/widgets/status/constance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({Key? key}) : super(key: key);

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  User? _user = FirebaseAuth.instance.currentUser;
  var UserOrderedProductsStream;
  var AddressStream;
  int status = 1;
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
    gettingData();
    super.initState();
    UserOrderedProductsStream = FirebaseFirestore.instance
        .collection("Users")
        .doc(_user!.uid)
        .collection("OrderedProducts")
        .orderBy("createdDate", descending: true)
        .limit(2)
        .snapshots();
    AddressStream = FirebaseFirestore.instance
        .collection("Delivery")
        .doc(_user!.uid)
        .collection("Details")
        .snapshots();
  }

  var data;
  String? statusString;

  void gettingData() async {
    FirebaseFirestore.instance
        .collection('OrderedUsers')
        .doc(_user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        data = await FirebaseFirestore.instance
            .collection('OrderedUsers')
            .doc(_user!.uid)
            .get();
        print(data.toString());
        setState(() {
          statusString = data['status'].toString();
          if (statusString == "OrderAccepted") {
            status = 1;
          } else if (statusString == "OrderProcessed") {
            status = 2;
          } else if (statusString == "Shipped") {
            status = 3;
          }
        });
      } else {
        print('Document does not exist on the database');
        setState(() {
          status = 4;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return hasInternet
        ? Scaffold(
            backgroundColor: Colors.pink[100],
            appBar: AppBar(
              title: Text("My Orders"),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: StreamBuilder<QuerySnapshot>(
                stream: UserOrderedProductsStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                      SizedBox(
                        height: 110,
                        child: ProcessTimelinePage(processIndex: status),
                      ),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot data = snapshot.data!.docs[index];
                          var docId = snapshot.data!.docs[index].reference.id
                              .toString();
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 14, right: 14, left: 14, bottom: 30),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Ordered At : " +
                                          data['createdDate']
                                              .toString()
                                              .substring(0, 10),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    OrderedHistory(docId: docId),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        : noInternet();
  }
}

class OrderedHistory extends StatefulWidget {
  final docId;
  const OrderedHistory({Key? key, required this.docId}) : super(key: key);

  @override
  _OrderedHistoryState createState() => _OrderedHistoryState();
}

class _OrderedHistoryState extends State<OrderedHistory> {
  var UserHistoryStream;
  User? _user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    UserHistoryStream = FirebaseFirestore.instance
        .collection("Users")
        .doc(_user!.uid)
        .collection("History")
        .doc(widget.docId)
        .collection("Products")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: UserHistoryStream,
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
                return Container(
                  margin: EdgeInsets.all(4),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                                "Colour : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                data['color'],
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '₹',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Roboto",
                                    ),
                                  ),
                                  Text(
                                    data['price'],
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  data['size'] != "Free"
                                      ? Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          margin: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
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
                                        )
                                      : Container(),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: 70,
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
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
