import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

//Uploads Products to the Firestore Cloud
class Products {
  //Add a New Product
  Future<void> addData(addProduct) async {
    FirebaseFirestore.instance
        .collection("Products")
        .add(addProduct)
        .catchError((e) {
      print(e);
    });
  }

  //Delete a product
  Future<void> delData(delProductId) async {
    FirebaseFirestore.instance
        .collection("Products")
        .doc(delProductId)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  //Update a Product
  Future<void> UpdateData(delProductId, UpdateProduct) async {
    FirebaseFirestore.instance
        .collection("Products")
        .doc(delProductId)
        .update(UpdateProduct)
        .catchError((e) {
      print(e);
    });
  }
   

  //reads the products collection
  getData() async {
    return await FirebaseFirestore.instance.collection("Products").get();
  }
}


