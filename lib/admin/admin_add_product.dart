import 'dart:async';
import 'package:ecommerce/admin/admin_home_page.dart';
import 'package:ecommerce/widgets/no_internet.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/backend/crud.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';
import 'package:random_string/random_string.dart';

class AdminAddProducts extends StatefulWidget {
  const AdminAddProducts({Key? key}) : super(key: key);

  @override
  _AdminAddProductsState createState() => _AdminAddProductsState();
}

class _AdminAddProductsState extends State<AdminAddProducts>
    with SingleTickerProviderStateMixin {
  late String title, desc, price, category;
  var ProductImage1, ProductImage2, ProductImage3, ProductImage4;
  int selectedImage = 0;
  List<String> ImageUrlsFullList = [];
  List<File> _image = [];
  List sizeList = [];
  UploadTask? task;
  var ImgUrl;

  // TextEditingController titleCont = new TextEditingController();
  // TextEditingController descCont = new TextEditingController();

  Products products = new Products();

  // Accessing the image from our gallery
  //Initialization
  final ImagePicker picker = ImagePicker();
  // Calling a function
  Future pickImage() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(pickedFile!.path));
    });
    if (pickedFile!.path == null) {
      retrieveLostData();
    }
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
  }

  int isSelected = 0;
  //Size isSlected variable
  bool CCSel1 = false,
      CCSel2 = false,
      CCSel3 = false,
      CCSel4 = false,
      CCSel5 = false,
      CCSel6 = false;

  // Validating our form
  void validate() {
    if (formKey.currentState!.validate()) {
      print("Validated");
      setState(() {
        uploading = true;
      });
      updateValues();
    } else {
      print("Not Validated");
    }
  }

  double val = 0;
  Reference? ref;
  bool uploading = false;
  //Uploading our new product to the firebase
  Future uploadImages() async {
    int i = 1;
    if (_image != null &&
        title != null &&
        desc != null &&
        price != null &&
        category != null) {
      for (var img in _image) {
        setState(() {
          val = i / _image.length;
        });
        ref = FirebaseStorage.instance
            .ref()
            .child("images/${randomAlphaNumeric(5)}");
        await ref?.putFile(img).whenComplete(() async {
          await ref?.getDownloadURL().then((value) async {
            //Adding to the Image url list
            i++;
            addingImgUrls(value);
          });
        });
      }
    }
    print(ImageUrlsFullList);
  }

  Future addingImgUrls(url) async {
    setState(() {
      ImageUrlsFullList.add(url);
    });
  }

  Future _addToCart() async {
    print("Before uploading all the products");
    return await FirebaseFirestore.instance.collection("Products").add({
      "title": title,
      "description": desc,
      "price": price,
      "size": sizeList,
      "category": category,
      "imgUrl": ImageUrlsFullList,
      "likes" : 0,
    }).then((value) {
      setState(() {
        ImageUrlsFullList.clear();
        uploading = false;
      });
      addedLottie();
    });
  }

  // Controllers
  late AnimationController lottieController;
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  void updateValues() {
    setState(() {
      title = titleController.text;
      desc = descController.text;
      price = priceController.text;
    });
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
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

  @override
  void initState() {
    // For Checking te internet
    checkConnection();
    // using this listiner, you can get the medium of connection as well.
    lottieController = AnimationController(vsync: this, duration: Duration());
    lottieController.addStatusListener(
      (status) async {
        if (status == AnimationStatus.completed) {
          Navigator.of(context).pop();
          lottieController.reset();
          // Navigator.of(context).pop();
        }
      },
    );
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    lottieController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (hasInternet == false) {
      return noInternet();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Add Products",
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            uploading
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Lottie.asset('assets/uploading.json'),
                    ),
                  )
                : Container(),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: formKey,
                  child: Column(
                    children: [
                      GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: _image.length + 1,
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
                                          pickImage();
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
                                      _image.removeAt(index - 1);
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
                                        child: Image.file(
                                          File(_image[index - 1].path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
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
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: descController,
                          maxLines: 4,
                          keyboardType: TextInputType.name,
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
                                Wrap(
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        category = "Saree";
                                        isSelected = 1;
                                        print("$isSelected");
                                      }),
                                      child: Container(
                                        margin: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: isSelected == 1
                                              ? Colors.pinkAccent
                                              : Colors.grey[300],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text("Saree"),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        category = "Chudi";
                                        isSelected = 2;
                                        print("$isSelected");
                                      }),
                                      child: Container(
                                        margin: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: isSelected == 2
                                              ? Colors.pinkAccent
                                              : Colors.grey[300],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text("Chudithaar"),
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
                            fontWeight: FontWeight.w600,
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
                          // onChanged: (value) {
                          //   price = value;
                          // },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Price cannot be empty !';
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
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              validate();

              uploadImages().whenComplete(() => _addToCart());
            },
            child: Icon(Icons.upload)),
      );
    }
  }

  addedLottie() {
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
                    'assets/success.json',
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
        }).then((value) => Navigator.of(context).pop());
  }
}
