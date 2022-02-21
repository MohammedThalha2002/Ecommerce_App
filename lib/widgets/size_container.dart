import 'package:flutter/material.dart';

class ProductSizes extends StatefulWidget {
  final String size;
  const ProductSizes({Key? key, required this.size}) : super(key: key);

  @override
  State<ProductSizes> createState() => _ProductSizesState();
}

class _ProductSizesState extends State<ProductSizes> {
  late Color sizeColor;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.size == "s" || widget.size == "S") {
      sizeColor = Colors.pink;
    } else if (widget.size == "m" || widget.size == "M") {
      sizeColor = Colors.blueGrey;
    } else if (widget.size == "l" || widget.size == "L") {
      sizeColor = Colors.indigo;
    } else {
      sizeColor = Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: sizeColor,
      ),
      child: Text(
        "${widget.size}",
        style: TextStyle(
          fontSize: 10,
        ),
      ),
    );
  }
}
