import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Pages/delivery_details.dart';
import 'package:ecommerce/Pages/my_cart.dart';
import 'package:ecommerce/backend/adding_delivery.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentSummary extends StatefulWidget {
  final String name;
  final String houseNo;
  final String street;
  final String town;
  final String district;
  final String pincode;
  final String state;
  final String phoneNumber;

  const PaymentSummary({
    Key? key,
    required this.name,
    required this.houseNo,
    required this.street,
    required this.town,
    required this.district,
    required this.pincode,
    required this.state,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _PaymentSummaryState createState() => _PaymentSummaryState();
}

class _PaymentSummaryState extends State<PaymentSummary> {
  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection("Users");
  // Current User Id
  User? _user = FirebaseAuth.instance.currentUser;
  var _CartStream;
  var _totalPrice;
  var Address;
  int total = 0;
  int CartSize = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Address = widget.houseNo +
        ", " +
        widget.street +
        ", " +
        widget.town +
        ", " +
        widget.district +
        ", " +
        widget.state +
        " - " +
        widget.pincode;
    _CartStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(_user!.uid)
        .collection("Cart")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Summary"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name.toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text("$Address"),
                    ],
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StreamBuilder(
                            stream: _CartStream,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else {
                                total = 0;
                                snapshot.data!.docs.forEach((result) {
                                  total += int.parse(result['price']) *
                                      int.parse(result['quantity']);
                                  CartSize = snapshot.data!.docs.length;
                                });
                                print("$total");
                                return Text(
                                  "Order Items($CartSize)",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }
                            }),
                        InkWell(
                          splashColor: Colors.pinkAccent,
                          onTap: (() {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: ((context) => MyCart())));
                          }),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              top: 6,
                              bottom: 6,
                            ),
                            child: Icon(Icons.arrow_forward_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Amount",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        StreamBuilder(
                            stream: _CartStream,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else {
                                total = 0;
                                snapshot.data!.docs.forEach((result) {
                                  total += int.parse(result['price']) *
                                      int.parse(result['quantity']);
                                  CartSize = snapshot.data!.docs.length;
                                });
                                print("$total");
                                return Text("₹" + "$total");
                              }
                            }),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Payment Method",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Radio(
                              value: 1,
                              groupValue: 1,
                              onChanged: (value) {},
                              activeColor: Colors.pinkAccent,
                            ),
                            Text(
                              "Cash on Delivery",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.pink[100],
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Amount",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      StreamBuilder(
                          stream: _CartStream,
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else {
                              total = 0;
                              snapshot.data!.docs.forEach((result) {
                                total += int.parse(result['price']) *
                                    int.parse(result['quantity']);
                              });
                              print("$total");
                              return Text(
                                "₹" + "$total",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 4, 121, 8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                ),
                              );
                            }
                          }),
                    ],
                  ),
                  AddingDelivery(
                    Address: Address,
                    Name: widget.name,
                    PhoneNumber: widget.phoneNumber,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
