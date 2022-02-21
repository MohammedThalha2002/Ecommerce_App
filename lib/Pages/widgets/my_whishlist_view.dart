import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Pages/product_overview.dart';
import 'package:ecommerce/backend/crud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<void> deleteProduct(
    {required String delProductId, required User? user}) async {
  FirebaseFirestore.instance
      .collection("Users")
      .doc(user!.uid)
      .collection("Whishlist")
      .doc(delProductId)
      .delete()
      .catchError((e) {
    print(e);
  });

  //Show an intimation that U have deleted a product
}

Widget MyWhishListView({
  Stream<QuerySnapshot<Object?>>? stream,
  User? user,
  required AnimationController animationController,
}) {
  return StreamBuilder<QuerySnapshot>(
    stream: stream,
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Text('Something went wrong');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }

      return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          DocumentSnapshot data = snapshot.data!.docs[index];
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(-0.5 * index + 1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animationController,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: FadeTransition(
              opacity: animationController,
              child: Container(
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () {
                    String docId =
                        snapshot.data!.docs[index].reference.id.toString();
                    int docIdsize = docId.length;
                    String docIdOutput = docId.substring(0, docIdsize - 3);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: ((context) => ProductOverview(
                              docId: docIdOutput,
                              index: index,
                            )),
                      ),
                    );
                  },
                  splashColor: Colors.pinkAccent,
                  child: ListTile(
                    leading: Image.network(
                      data['imgUrl'],
                      height: 100,
                    ),
                    title: Text(data['title']),
                    subtitle: Text(
                      data['description'].toString().length < 30
                          ? data['description'].toString()
                          : data['description'].toString().substring(0, 25) +
                              "....",
                    ),
                    trailing: InkWell(
                      splashColor: Colors.pink,
                      onTap: () async {
                        Alert(
                          context: context,
                          title: "ALERT",
                          desc: "Do You Like to Delete this Product",
                          image: Lottie.asset('assets/delete_show.json'),
                          buttons: [
                            DialogButton(
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              onPressed: () {
                                var docId = snapshot
                                    .data!.docs[index].reference.id
                                    .toString();
                                deleteProduct(
                                  delProductId: docId,
                                  user: user,
                                );
                                Navigator.pop(context);
                              },
                              color: Color.fromARGB(255, 218, 25, 50),
                            ),
                            DialogButton(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              onPressed: () => Navigator.pop(context),
                              color: Color.fromRGBO(0, 179, 134, 1.0),
                            ),
                          ],
                        ).show();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: FaIcon(
                          FontAwesomeIcons.trashAlt,
                          color: Colors.red.withOpacity(0.7),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
