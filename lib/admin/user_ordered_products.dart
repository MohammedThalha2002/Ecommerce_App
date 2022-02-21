import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/widgets/no_internet.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class UserOrderedProducts extends StatefulWidget {
  final docId;
  const UserOrderedProducts({Key? key, required this.docId}) : super(key: key);

  @override
  _UserOrderedProductsState createState() => _UserOrderedProductsState();
}

class _UserOrderedProductsState extends State<UserOrderedProducts> {
  var UserOrderedProductsStream;
  var AddressStream;
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
    // TODO: implement initState
    super.initState();
    checkConnection();
    UserOrderedProductsStream = FirebaseFirestore.instance
        .collection("Delivery")
        .doc(widget.docId)
        .collection("Products")
        .snapshots();
    AddressStream = FirebaseFirestore.instance
        .collection("Delivery")
        .doc(widget.docId)
        .collection("Details")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return hasInternet
        ? Scaffold(
            backgroundColor: Colors.pink[100],
            appBar: AppBar(
              title: Text("Details"),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                        StreamBuilder<QuerySnapshot>(
                          stream: AddressStream,
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

                            return ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot data =
                                    snapshot.data!.docs[index];
                                return Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['Name'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(data['PhoneNumber']),
                                      Text(data['Email']),
                                      Text(data['Address']),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(data['title']),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
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
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 4),
                                                margin: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  color: Colors.pinkAccent[100],
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(1),
                                                  child: Text(
                                                    data['size'],
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 80,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Color.fromARGB(
                                              255, 245, 138, 174),
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
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    12,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
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
                        Container(
                          height: 55,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          )
        : noInternet();
  }
}
