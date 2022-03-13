import 'dart:async';
import 'package:ecommerce/admin/admin_home_page.dart';
import 'package:ecommerce/widgets/no_internet.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/backend/crud.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';
import 'package:random_string/random_string.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminUpdateProducts extends StatefulWidget {
  final docId;
  const AdminUpdateProducts({
    Key? key,
    required this.docId,
  }) : super(key: key);

  @override
  _AdminUpdateProductsState createState() => _AdminUpdateProductsState();
}

class _AdminUpdateProductsState extends State<AdminUpdateProducts>
    with SingleTickerProviderStateMixin {
  String title = "",
      desc = "",
      price = "",
      category = "",
      color = "",
      MRP = "",
      offer = "";
  var ProductImage;
  List sizeList = [];
  List ImgUrl = [];

  // TextEditingController titleCont = new TextEditingController();
  // TextEditingController descCont = new TextEditingController();
  final Stream<QuerySnapshot> _AllStream =
      FirebaseFirestore.instance.collection('Products').snapshots();
  Products products = new Products();

  int isSelected = 0;
  //Size isSlected variable
  bool CCSel1 = false,
      CCSel2 = false,
      CCSel3 = false,
      CCSel4 = false,
      CCSel5 = false,
      CCSel6 = false,
      CCSel7 = false;
  //Controllers
  late AnimationController lottieController;
  TextEditingController titleController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController MrpController = TextEditingController();
  TextEditingController offerController = TextEditingController();
  TextEditingController UrlController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // Validating our form
  void validate() {
    if (formKey.currentState!.validate()) {
      print("Validated");
      uploadProduct();
    } else {
      print("Not Validated");
      showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: "Please Enter all the fields",
            backgroundColor: Colors.redAccent,
          ),
          showOutAnimationDuration: Duration(milliseconds: 1000),
          displayDuration: Duration(seconds: 1),
          hideOutAnimationDuration: Duration(milliseconds: 1000));
    }
  }

  //Uploading our new product to the firebase
  Future uploadProduct() async {
    print(title);
    print(desc);
    print(price);
    print(category);
    print(ImgUrl);
    if (title != null && desc != null && price != null && category != null) {
      // Define all our upload data
      Map<String, dynamic> productMap = {
        "imgUrl": ImgUrl,
        "title": title,
        "description": desc,
        "price": price,
        "MRP": MRP,
        "offer": offer,
        "size": sizeList,
        "category": category,
        "color": color,
      };

      // Uploading to our server
      products.UpdateData(docId, productMap).then((value) => updatedLottie());
    } else {
      // show a pop up to fill all the textfields
      print("Please enter all the fields");
      return;
    }
  }

  void _launchURL(String _url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  var docId;
  var data;
  late bool isloading;
  // For internwt connwction
  late StreamSubscription internetconnection;
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

  // initstate
  @override
  void initState() {
    // using this listiner, you can get the medium of connection as well.
    // TODO: implement initState
    super.initState();
    checkConnection();
    gettingData();
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        isloading = false;
      });
    });
    lottieController = AnimationController(vsync: this, duration: Duration());
    lottieController.addStatusListener(
      (status) async {
        if (status == AnimationStatus.completed) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          lottieController.reset();
        }
      },
    );
  }

  //dispose
  @override
  void dispose() {
    lottieController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void gettingData() async {
    docId = widget.docId;
    print(docId.toString());
    data = await FirebaseFirestore.instance
        .collection('Products')
        .doc(docId)
        .get();
    title = data['title'].toString();
    titleController.text = title;
    // print(title);
    color = data['color'].toString();
    colorController.text = color;
    //
    desc = data['description'].toString();
    descController.text = desc;
    // print(desc);
    price = data['price'].toString();
    priceController.text = price;
    // print(desc);
    MRP = data['MRP'].toString();
    MrpController.text = MRP;
    // print(desc);
    offer = data['offer'].toString();
    offerController.text = offer;
    // print(price);
    category = data['category'].toString();
    categorySelection();
    // print(category);
    sizeList = data['size'];
    print(sizeList);
    sizeListSelection();
    setState(() {
      ImgUrl = data['imgUrl'];
      print(ImgUrl);
    });
  }

  void categorySelection() {
    if (category == "Cotton_vesti") {
      setState(() {
        isSelected = 1;
      });
    } else if (category == "Cotton_lungi") {
      setState(() {
        isSelected = 2;
      });
    } else if (category == "Cotton_shirt_bit") {
      setState(() {
        isSelected = 3;
      });
    } else if (category == "Boy_baby_dress") {
      setState(() {
        isSelected = 4;
      });
    } else if (category == "Chudithaar") {
      setState(() {
        isSelected = 5;
      });
    } else if (category == "Leggins") {
      setState(() {
        isSelected = 6;
      });
    } else if (category == "Tops") {
      setState(() {
        isSelected = 7;
      });
    } else if (category == "Shawls") {
      setState(() {
        isSelected = 8;
      });
    } else if (category == "Girl_baby_frock") {
      setState(() {
        isSelected = 9;
      });
    } else if (category == "Girl_baby_midi") {
      setState(() {
        isSelected = 10;
      });
    } else if (category == "Silk_saree") {
      setState(() {
        isSelected = 11;
      });
    } else if (category == "Cotton_saree") {
      setState(() {
        isSelected = 12;
      });
    } else if (category == "Poonam_saree") {
      setState(() {
        isSelected = 13;
      });
    }
  }

  void sizeListSelection() {
    for (String i in sizeList) {
      print(i);
      if (i == "S") {
        setState(() {
          CCSel1 = true;
        });
      } else if (i == "M") {
        setState(() {
          CCSel2 = true;
        });
      } else if (i == "L") {
        setState(() {
          CCSel3 = true;
        });
      } else if (i == "XL") {
        setState(() {
          CCSel4 = true;
        });
      } else if (i == "XXL") {
        setState(() {
          CCSel5 = true;
        });
      } else if (i == "XXXL") {
        setState(() {
          CCSel6 = true;
        });
      } else if (i == "Free") {
        setState(() {
          CCSel7 = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hasInternet == false) {
      return noInternet();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Update Products",
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: formKey,
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _AllStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading");
                      }

                      return GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: ImgUrl.length + 1,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisExtent: 100,
                        ),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return index == 0
                              ? Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color.fromARGB(255, 34, 34, 34),
                                    ),
                                    child: Center(
                                      child: IconButton(
                                        onPressed: () {
                                          _launchURL("https://postimages.org/");
                                          Alert(
                                            context: context,
                                            title: "Add the Copied URL",
                                            content: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 40),
                                              child: TextField(
                                                controller: UrlController,
                                                keyboardType: TextInputType.url,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: "Paste the URL",
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide: BorderSide(
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            buttons: [
                                              DialogButton(
                                                child: Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                color: Color.fromARGB(
                                                    255, 218, 25, 50),
                                              ),
                                              DialogButton(
                                                child: Text(
                                                  "Ok",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                ),
                                                onPressed: () {
                                                  ImgUrl.add(
                                                      UrlController.text);
                                                  print(ImgUrl);
                                                  Navigator.pop(context);
                                                  UrlController.clear();
                                                },
                                                color: Color.fromRGBO(
                                                    0, 179, 134, 1.0),
                                              ),
                                            ],
                                          ).show();
                                        },
                                        icon: Icon(
                                          Icons.add_a_photo_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : InkWell(
                                  splashColor: Colors.pinkAccent,
                                  onLongPress: () {
                                    setState(() {
                                      ImgUrl.removeAt(index - 1);
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.network(
                                          ImgUrl[index - 1],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                        },
                      );
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: titleController,
                      maxLength: 30,
                      keyboardType: TextInputType.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Title cannot be empty !';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "Product Title",
                        disabledBorder: OutlineInputBorder(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        title = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: descController,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Description cannot be empty !';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Product Description",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        desc = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: colorController,
                      keyboardType: TextInputType.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Colour cannot be empty !';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "Product Colour",
                        disabledBorder: OutlineInputBorder(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        color = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(color: (Colors.grey[500])!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "Category",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "GENS CATEGORY",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Wrap(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() {
                                    category = "Cotton_vesti";
                                    isSelected = 1;
                                    print("$isSelected");
                                  }),
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected == 1
                                          ? Colors.pinkAccent
                                          : Colors.grey[300],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text("Cotton Vesti"),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    category = "Cotton_lungi";
                                    isSelected = 2;
                                    print("$isSelected");
                                  }),
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected == 2
                                          ? Colors.pinkAccent
                                          : Colors.grey[300],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text("Cotton Lungi"),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    category = "Cotton_shirt_bit";
                                    isSelected = 3;
                                    print("$isSelected");
                                  }),
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected == 3
                                          ? Colors.pinkAccent
                                          : Colors.grey[300],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text("Cotton Shirt Bit"),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    category = "Boy_baby_dress";
                                    isSelected = 4;
                                    print("$isSelected");
                                  }),
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected == 4
                                          ? Colors.pinkAccent
                                          : Colors.grey[300],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text("Boy Baby Dress"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "LADIES CATEGORY",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Wrap(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() {
                                    category = "Chudithaar";
                                    isSelected = 5;
                                    print("$isSelected");
                                  }),
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected == 5
                                          ? Colors.pinkAccent
                                          : Colors.grey[300],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text("Chudithaar"),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    category = "Leggins";
                                    isSelected = 6;
                                    print("$isSelected");
                                  }),
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected == 6
                                          ? Colors.pinkAccent
                                          : Colors.grey[300],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text("Leggins"),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    category = "Tops";
                                    isSelected = 7;
                                    print("$isSelected");
                                  }),
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected == 7
                                          ? Colors.pinkAccent
                                          : Colors.grey[300],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text("Tops"),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    category = "Shawls";
                                    isSelected = 8;
                                    print("$isSelected");
                                  }),
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected == 8
                                          ? Colors.pinkAccent
                                          : Colors.grey[300],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text("Shawls"),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    category = "Girl_baby_frock";
                                    isSelected = 9;
                                    print("$isSelected");
                                  }),
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected == 9
                                          ? Colors.pinkAccent
                                          : Colors.grey[300],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text("Girl Baby Frock"),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    category = "Girl_baby_midi";
                                    isSelected = 10;
                                    print("$isSelected");
                                  }),
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected == 10
                                          ? Colors.pinkAccent
                                          : Colors.grey[300],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text("Girl Baby Midi"),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    category = "Silk_saree";
                                    isSelected = 11;
                                    print("$isSelected");
                                  }),
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected == 11
                                          ? Colors.pinkAccent
                                          : Colors.grey[300],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text("Silk Saree"),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    category = "Cotton_saree";
                                    isSelected = 12;
                                    print("$isSelected");
                                  }),
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected == 12
                                          ? Colors.pinkAccent
                                          : Colors.grey[300],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text("Cotton Saree"),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    category = "Poonam_saree";
                                    isSelected = 13;
                                    print("$isSelected");
                                  }),
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected == 13
                                          ? Colors.pinkAccent
                                          : Colors.grey[300],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text("Poonam Saree"),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(color: (Colors.grey[500])!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "Size",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Wrap(children: [
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: ChoiceChip(
                                    label: Text("Small"),
                                    selectedColor: Colors.pinkAccent,
                                    selected: CCSel1,
                                    onSelected: (newvalue) {
                                      setState(() {
                                        CCSel1 = newvalue;
                                        if (CCSel1 == true) {
                                          sizeList.add("S");
                                        } else if (CCSel1 == false) {
                                          sizeList.remove("S");
                                        }
                                        print(sizeList.toString());
                                      });
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: ChoiceChip(
                                    label: Text("Medium"),
                                    selectedColor: Colors.pinkAccent,
                                    selected: CCSel2,
                                    onSelected: (newvalue) {
                                      setState(() {
                                        CCSel2 = newvalue;
                                        if (CCSel2 == true) {
                                          sizeList.add("M");
                                        } else if (CCSel2 == false) {
                                          sizeList.remove("M");
                                        }
                                        print(sizeList.toString());
                                      });
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: ChoiceChip(
                                    label: Text("Large"),
                                    selectedColor: Colors.pinkAccent,
                                    selected: CCSel3,
                                    onSelected: (newvalue) {
                                      setState(() {
                                        CCSel3 = newvalue;
                                        if (CCSel3 == true) {
                                          sizeList.add("L");
                                        } else if (CCSel3 == false) {
                                          sizeList.remove("L");
                                        }
                                        print(sizeList.toString());
                                      });
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: ChoiceChip(
                                    label: Text("XL"),
                                    selectedColor: Colors.pinkAccent,
                                    selected: CCSel4,
                                    onSelected: (newvalue) {
                                      setState(() {
                                        CCSel4 = newvalue;
                                        if (CCSel4 == true) {
                                          sizeList.add("XL");
                                        } else if (CCSel4 == false) {
                                          sizeList.remove("XL");
                                        }
                                        print(sizeList.toString());
                                      });
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: ChoiceChip(
                                    label: Text("XXL"),
                                    selectedColor: Colors.pinkAccent,
                                    selected: CCSel5,
                                    onSelected: (newvalue) {
                                      setState(() {
                                        CCSel5 = newvalue;
                                        if (CCSel5 == true) {
                                          sizeList.add("XXL");
                                        } else if (CCSel5 == false) {
                                          sizeList.remove("XXL");
                                        }
                                        print(sizeList.toString());
                                      });
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: ChoiceChip(
                                    label: Text("XXXL"),
                                    selectedColor: Colors.pinkAccent,
                                    selected: CCSel6,
                                    onSelected: (newvalue) {
                                      setState(() {
                                        CCSel6 = newvalue;
                                        if (CCSel6 == true) {
                                          sizeList.add("XXXL");
                                        } else if (CCSel6 == false) {
                                          sizeList.remove("XXXL");
                                        }
                                        print(sizeList.toString());
                                      });
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: ChoiceChip(
                                    label: Text("Free"),
                                    selectedColor: Colors.pinkAccent,
                                    selected: CCSel7,
                                    onSelected: (newvalue) {
                                      setState(() {
                                        CCSel7 = newvalue;
                                        if (CCSel7 == true) {
                                          sizeList.add("Free");
                                        } else if (CCSel7 == false) {
                                          sizeList.remove("Free");
                                        }
                                        print(sizeList.toString());
                                      });
                                    }),
                              ),
                            ])
                          ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "Price",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        price = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Price cannot be empty !';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      controller: MrpController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "MRP",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        MRP = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'MRP cannot be empty !';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      controller: offerController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: "Offer",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        offer = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Offer cannot be empty !';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (sizeList.length != 0 && category != null) {
              if (ImgUrl.length != 0) {
                validate();
              } else {
                showTopSnackBar(
                    context,
                    CustomSnackBar.error(
                      message: "Please upload atleast one image",
                      backgroundColor: Colors.redAccent,
                    ),
                    showOutAnimationDuration: Duration(milliseconds: 1000),
                    displayDuration: Duration(seconds: 1),
                    hideOutAnimationDuration: Duration(milliseconds: 1000));
              }
            } else {
              showTopSnackBar(
                  context,
                  CustomSnackBar.error(
                    message: "Please select the size and category",
                    backgroundColor: Colors.redAccent,
                  ),
                  showOutAnimationDuration: Duration(milliseconds: 1000),
                  displayDuration: Duration(seconds: 1),
                  hideOutAnimationDuration: Duration(milliseconds: 1000));
            }
          },
          child: FaIcon(FontAwesomeIcons.cloudUploadAlt),
        ),
      );
    }
  }

  updatedLottie() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            insetAnimationCurve: Curves.easeIn,
            elevation: 0,
            backgroundColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/uploaded.json',
                    repeat: false,
                    height: MediaQuery.of(context).size.width * 0.75,
                    controller: lottieController,
                    onLoaded: (composition) {
                      lottieController.duration = composition.duration;
                      lottieController.forward();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
