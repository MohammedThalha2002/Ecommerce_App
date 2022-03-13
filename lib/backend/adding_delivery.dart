import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Pages/Product_home_page.dart';
import 'package:ecommerce/backend/sendNotification.dart';
import 'package:ecommerce/widgets/delivery_accepted_lottie.dart';
import 'package:ecommerce/widgets/no_internet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:random_string/random_string.dart';
import 'package:timelines/timelines.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AddingDelivery extends StatefulWidget {
  final String Address;
  final String Name;
  final String PhoneNumber;
  final String AltPhoneNumber;
  const AddingDelivery({
    Key? key,
    required this.Address,
    required this.Name,
    required this.PhoneNumber,
    required this.AltPhoneNumber,
  }) : super(key: key);

  @override
  _AddingDeliveryState createState() => _AddingDeliveryState();
}

class _AddingDeliveryState extends State<AddingDelivery> {
  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection("Delivery");
  // Current User Id
  User? _user = FirebaseAuth.instance.currentUser;
  var _CartStream;
  var tokenData;
  String tokenID = "";
  int total = 0;
  bool proceed = false;
  DateTime dateTime = DateTime.now();
  bool hasInternet = false;
  checkConnection() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (result == true) {
      setState(() {
        hasInternet = true;
      });
    } else {
      Get.to(noInternet());
      print('No internet :( Reason:');
    }
    InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;

      setState(() {
        this.hasInternet = hasInternet;
      });
    });
  }

  //Add Address
  Future _addAddress() async {
    // First Adding the address in DELIVERY -> DETAILS -> ADDRESS
    return await FirebaseFirestore.instance
        .collection("Delivery")
        .doc(_user!.uid)
        .collection("Details")
        .doc("Address")
        .set({
      "Address": widget.Address,
      "Name": widget.Name,
      "Email": _user!.email,
      "UserId": _user!.uid,
      "PhoneNumber": widget.PhoneNumber,
      "AltPhoneNumber": widget.AltPhoneNumber,
    }).whenComplete(() {
      // Then Adding the ordered users in ORDERED USERS -> USERID
      FirebaseFirestore.instance
          .collection("OrderedUsers")
          .doc(_user!.uid)
          .set({
        "name": widget.Name,
        "email": _user!.email,
        "userId": _user!.uid,
        "PhoneNumber": widget.PhoneNumber,
        "profilePic": _user!.photoURL,
        "CreatedDate": dateTime.toString(),
        "status": "OrderAccepted",
      });
      FirebaseFirestore.instance
          .collection("Users")
          .doc(_user!.uid)
          .collection("OrderedProducts")
          .doc(dateTime.toString())
          .set({
        "createdDate": dateTime.toString(),
      });
      FirebaseFirestore.instance
          .collection('Users')
          .doc(_user!.uid)
          .collection("Cart")
          .get()
          .then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((doc) {
              FirebaseFirestore.instance
                  .collection('Delivery')
                  .doc(_user!.uid)
                  .collection("Products")
                  .add({
                "title": doc['title'],
                "size": doc['size'],
                "color": doc['color'],
                "quantity": doc['quantity'],
                "imgUrl": doc['imgUrl'],
                "price": doc['price'],
                "createdDate": dateTime.toString(),
              });
              FirebaseFirestore.instance
                  .collection('Users')
                  .doc(_user!.uid)
                  .collection("History")
                  .doc(dateTime.toString())
                  .collection("Products")
                  .add({
                "title": doc['title'],
                "size": doc['size'],
                "color": doc['color'],
                "quantity": doc['quantity'],
                "imgUrl": doc['imgUrl'],
                "price": doc['price'],
                "createdDate": dateTime.toString(),
              });
            });
          })
          .whenComplete(
            () => FirebaseFirestore.instance
                .collection('Users')
                .doc(_user!.uid)
                .collection("Cart")
                .get()
                .then((snapshot) {
              for (DocumentSnapshot doc in snapshot.docs) {
                doc.reference.delete();
              }
            }),
          )
          .whenComplete(() {
            notificationDefaultSound();
            sendNotification(
              tokenIdList: [tokenID],
              heading: "A new order has been arrived",
              contents: "An order from " + _user!.displayName.toString(),
            );
          });
    });
  }

  late FlutterLocalNotificationsPlugin flutterNotificationPlugin;
  @override
  void initState() {
    // TODO: implement initState
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettingsIOS = new IOSInitializationSettings();

    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterNotificationPlugin = FlutterLocalNotificationsPlugin();

    flutterNotificationPlugin.initialize(initializationSettings);
    super.initState();
    _CartStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(_user!.uid)
        .collection("Cart")
        .snapshots();
    gettingTokenID();
  }

  gettingTokenID() async {
    tokenData =
        await FirebaseFirestore.instance.collection("Admin").doc("Admin").get();
    setState(() {
      tokenID = tokenData['tokenId'];
    });
    print("The token Id is " + tokenID);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          child: Text('Place Order'),
          onPressed: () {
            checkConnection();
            try {
              _addAddress().then(
                (value) => Get.to(
                  DeliveryAcceptedLottie(),
                  transition: Transition.native,
                ),
              );
            } on Exception catch (e) {
              // TODO
              Get.snackbar(
                  "ERROR", "Something went wrong please try again later");
            }
          },
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            primary: Colors.pinkAccent,
            padding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 4,
            ),
            textStyle: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Future notificationDefaultSound() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'Notification Channel ID',
      'Channel Name',
      importance: Importance.max,
      priority: Priority.high,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    flutterNotificationPlugin.show(
      0,
      'Hi, this is from JM Cottons',
      'Your Order has been Accepted and will arrive soon',
      platformChannelSpecifics,
      payload: 'Default Sound',
    );
  }
}
