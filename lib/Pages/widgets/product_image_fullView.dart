import 'package:ecommerce/widgets/no_internet.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ProductImageFullView extends StatefulWidget {
  final String imgUrl;
  const ProductImageFullView({Key? key, required this.imgUrl})
      : super(key: key);

  @override
  State<ProductImageFullView> createState() => _ProductImageFullViewState();
}

class _ProductImageFullViewState extends State<ProductImageFullView> {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return hasInternet
        ? Scaffold(
            body: InteractiveViewer(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image.network(
                widget.imgUrl,
                fit: BoxFit.contain,
              ),
            ),
          ))
        : noInternet();
  }
}
