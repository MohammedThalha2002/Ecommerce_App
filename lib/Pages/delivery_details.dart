import 'package:animated_button/animated_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          phoneNumber = data['phone_number'].toString();
          print(phoneNumber);
          phoneNoController.text = phoneNumber;
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
          districtController.text = district;
          // print(sizeList);
          pincode = data['pincode'];
          pincodeController.text = pincode;
          // print(sizeList);
          state = data['state'];
          stateController.text = state;
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
        pincode != null &&
        state != null) {
      return _userRef.doc(_user!.uid).collection("Details").doc("Address").set({
        "Name": name,
        "phone_number": phoneNumber,
        "house_no": houseNo,
        "Street": street,
        "Town": town,
        "District": district,
        "pincode": pincode,
        "state": state,
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
                state: state,
                phoneNumber: phoneNumber),
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
  String houseNo = '';
  String street = '';
  String town = '';
  String district = '';
  String pincode = '';
  String state = '';

  //Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController houseNoController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController townController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController stateController = TextEditingController();

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
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: districtController,
                    maxLength: 30,
                    keyboardType: TextInputType.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'District cannot be empty !';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: Colors.pink,
                      ),
                      counterText: "",
                      hintText: "District",
                      disabledBorder: OutlineInputBorder(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      district = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: pincodeController,
                    maxLength: 30,
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
                    controller: stateController,
                    maxLength: 30,
                    keyboardType: TextInputType.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'State cannot be empty !';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.adjust_rounded,
                        color: Colors.pink,
                      ),
                      counterText: "",
                      hintText: "State",
                      disabledBorder: OutlineInputBorder(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      state = value;
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
