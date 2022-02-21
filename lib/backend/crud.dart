import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

// Uploads Images to the Firebase Storage
class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      return ref.putFile(file);
    } on FirebaseException catch (e) {
      // TODO
      print("Error......................");
      return null;
    }
  }
}
