import 'package:animated_button/animated_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:ecommerce/Pages/payment_summary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class DeliveryDetails extends StatefulWidget {
  const DeliveryDetails({Key? key}) : super(key: key);

  @override
  _DeliveryDetailsState createState() => _DeliveryDetailsState();
}

class _DeliveryDetailsState extends State<DeliveryDetails> {
  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection("Users");
  // Current User Id
  User? _user = FirebaseAuth.instance.currentUser;
  int total = 0;
  var data;
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
    gettingData();
    // TODO: implement initState
    super.initState();
  }

  void gettingData() async {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(_user!.uid)
        .collection("Details")
        .doc("Address")
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        data = await FirebaseFirestore.instance
            .collection('Users')
            .doc(_user!.uid)
            .collection("Details")
            .doc("Address")
            .get();
        print(data.toString());
        setState(() {
          name = data['Name'].toString();
          nameController.text = name;
          print(name);
          //
          phoneNumber = data['phone_number'].toString();
          print(phoneNumber);
          phoneNoController.text = phoneNumber;
          //
          AltphoneNumber = data['Alt_phone_number'].toString();
          print(phoneNumber);
          AltphoneNoController.text = AltphoneNumber;
          //
          houseNo = data['house_no'].toString();
          houseNoController.text = houseNo;
          // print(price);
          street = data['Street'].toString();
          streetController.text = street;
          // print(category);
          town = data['Town'];
          townController.text = town;
          // print(sizeList);
          district = data['District'];
          print(district);
          // print(sizeList);
          pincode = data['pincode'];
          pincodeController.text = pincode;
        });
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  //Add Address
  _addAddress() {
    if (name != null &&
        phoneNumber != null &&
        houseNo != null &&
        street != null &&
        town != null &&
        district != null &&
        pincode != null) {
      return _userRef.doc(_user!.uid).collection("Details").doc("Address").set({
        "Name": name,
        "phone_number": phoneNumber,
        "Alt_phone_number": AltphoneNumber,
        "house_no": houseNo,
        "Street": street,
        "Town": town,
        "District": district,
        "pincode": pincode,
      }).whenComplete(
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentSummary(
              name: name,
              houseNo: houseNo,
              street: street,
              town: town,
              district: district,
              pincode: pincode,
              phoneNumber: phoneNumber,
              AltphoneNumber: AltphoneNumber,
            ),
          ),
        ),
      );
    } else {
      print("Fill all te fields");
    }
  }

  //variables
  String name = '';
  String phoneNumber = '';
  String AltphoneNumber = '';
  String houseNo = '';
  String street = '';
  String town = '';
  String district = '';
  String pincode = '';

  //Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController AltphoneNoController = TextEditingController();
  TextEditingController houseNoController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController townController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();

  //
  String? DistrictValue;
  String? _chosenValue;
  List<String> Districts = [
    'Chennai',
    'Tiruvallur',
    'Chengalpattu',
    'Kancheepuram',
  ];

  //Validating our forms
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // Validating our form
  void validate() {
    if (formKey.currentState!.validate()) {
      print("Validated");
      _addAddress();
    } else {
      print("Not Validated");
      showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: "Please Enter all the fields",
            backgroundColor: Colors.redAccent,
          ),
          showOutAnimationDuration: Duration(milliseconds: 500),
          displayDuration: Duration(seconds: 1),
          hideOutAnimationDuration: Duration(milliseconds: 500));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined),
            Text("Delivery Details"),
            Spacer(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: nameController,
                    maxLength: 30,
                    keyboardType: TextInputType.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Name cannot be empty !';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.account_circle,
                        color: Colors.pink,
                      ),
                      counterText: "",
                      hintText: "Full Name",
                      disabledBorder: OutlineInputBorder(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      name = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: houseNoController,
                    maxLength: 30,
                    keyboardType: TextInputType.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'House Number cannot be empty !';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.account_balance,
                        color: Colors.pink,
                      ),
                      counterText: "",
                      hintText: "House Number",
                      disabledBorder: OutlineInputBorder(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      houseNo = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: streetController,
                    maxLength: 30,
                    keyboardType: TextInputType.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Street cannot be empty !';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.add_road_rounded,
                        color: Colors.pink,
                      ),
                      counterText: "",
                      hintText: "Street",
                      disabledBorder: OutlineInputBorder(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      street = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: townController,
                    maxLength: 30,
                    keyboardType: TextInputType.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Town cannot be empty !';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.location_city_rounded,
                        color: Colors.pink,
                      ),
                      counterText: "",
                      hintText: "Town",
                      disabledBorder: OutlineInputBorder(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      town = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      isExpanded: true,
                      hint: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.pink,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                              child: district == ""
                                  ? Text(
                                      "District",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : Text(
                                      district,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )),
                        ],
                      ),
                      items: Districts.map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          )).toList(),
                      value: DistrictValue,
                      onChanged: (value) {
                        setState(() {
                          district = value as String;
                        });
                      },
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 20,
                      buttonWidth: double.infinity,
                      buttonPadding: const EdgeInsets.all(12),
                      buttonDecoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      buttonElevation: 0,
                      itemHeight: 40,
                      itemPadding: const EdgeInsets.only(left: 14, right: 14),
                      dropdownMaxHeight: 200,
                      dropdownWidth: 300,
                      dropdownPadding: null,
                      dropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      dropdownElevation: 8,
                      scrollbarRadius: const Radius.circular(40),
                      scrollbarThickness: 6,
                      scrollbarAlwaysShow: true,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: pincodeController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Pincode cannot be empty !';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.fiber_pin_rounded,
                        color: Colors.pink,
                      ),
                      counterText: "",
                      hintText: "Pincode",
                      disabledBorder: OutlineInputBorder(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      pincode = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: phoneNoController,
                    maxLength: 30,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Phone Number cannot be empty !';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Colors.pink,
                      ),
                      counterText: "",
                      hintText: "Phone Number",
                      disabledBorder: OutlineInputBorder(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      phoneNumber = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: AltphoneNoController,
                    maxLength: 30,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Phone Number cannot be empty !';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.phone_iphone,
                        color: Colors.pink,
                      ),
                      counterText: "",
                      hintText: "Alternative Phone Number",
                      disabledBorder: OutlineInputBorder(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      AltphoneNumber = value;
                    },
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedButton(
            child: Text(
              'Submit',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            color: Colors.pink,
            height: 45,
            width: 170,
            onPressed: () {
              validate();
            },
          ),
        ],
      ),
    );
  }
}
