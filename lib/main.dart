import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Pages/Product_home_page.dart';
import 'package:ecommerce/Pages/auth/Login_page.dart';
import 'package:ecommerce/Pages/auth/auth_checker.dart';
import 'package:ecommerce/widgets/no_internet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  // FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // bind our app with the  Getx Controller
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Poppins",
        primaryColor: Colors.pink,
        primarySwatch: Colors.pink,
      ),
      home: Routes(),
    );
  }
}

class Routes extends StatefulWidget {
  const Routes({Key? key}) : super(key: key);

  @override
  _RoutesState createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  User? user = FirebaseAuth.instance.currentUser;
  bool hasInternet = false;
  String tokenId = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkConnection();
    configOneSignel();
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

  Future<void> configOneSignel() async {
    //Remove this method to stop OneSignal Debugging
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setAppId("4451bb39-5a4b-4f88-97ee-b35e9eca3b35");

// // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
//     OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
//       print("Accepted permission: $accepted");
//     });
  }

  @override
  Widget build(BuildContext context) {
    return hasInternet
        ? (user != null ? HomePage() : LoginPage())
        : noInternet();
  }
}
