import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kadai_app/models/shop.dart';
import 'package:kadai_app/models/user.dart';

class DatabaseService {

  final String uid;

  DatabaseService( { this.uid });

  // collection reference
  // once created - won't create another just give the reference
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('users');

  Future createUserData({email}) async {
    Map cart = new Map();
    cart['shopName'] = '';
    cart['totalCost'] = 0.0;
    cart['products'] = new Map();
    return await userCollection.doc(uid).set({
      'name': '',
      'dob': '',
      'phoneNumber': '',
      'pincode': '',
      'email': email,
      'cart' : cart
    });
  }

  Future updateUserData(String name, String dob, String phoneNumber,
      String pincode) async {
    return await userCollection.doc(uid).update({
      'name': name,
      'dob': dob,
      'phoneNumber': phoneNumber,
      'pincode': pincode
    });
  }

  Future updateCart(Map newCart) async {
    return await userCollection.doc(uid).update({
      'cart':  newCart,
    });
  }

  // userData from snapshots
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      name: snapshot.data()['name'] ?? '',
      dob: snapshot.data()['dob'] ?? '',
      phoneNumber: snapshot.data()['phoneNumber'] ?? '',
      email: snapshot.data()['email'] ?? '',
      pincode: snapshot.data()['pincode'] ?? '',
    );
  }

  // get user doc stream
  Stream<UserData> get userData {
    return userCollection.doc(uid).snapshots()
        .map(_userDataFromSnapshot);
  }

  Cart _cartFromSnapshot(DocumentSnapshot snapshot) {
    Map cartMap = snapshot.data()['cart'];
    Map productMap = cartMap['products'];
    List<Product> products = productMap.entries.map((product) {
      return Product(
        name: product.value['name'] ?? '',
        price: product.value['price'].toDouble() ?? 0.0,
        quantity: product.value['quantity'] ?? 0,
        image: product.value['image'] ?? '',
        desc: product.value['desc'] ?? '',
        category: product.value['category'] ?? ''
      );
    }).toList();
    return Cart(
      shopName: cartMap['shopName'] ?? '',
      totalCost: cartMap['totalCost'].toDouble() ?? 0.0,
      products: products ?? []
    );
  }

  Stream<Cart> get cart {
    return userCollection.doc(uid).snapshots()
        .map(_cartFromSnapshot);
  }

}

// brew list from snapshots
// List<Brew> _brewListFromSnapshot(QuerySnapshot snapshots) {
//   return snapshots.docs.map((doc) {
//     return Brew(
//         name: doc.data()["name"] ?? '',
//         strength: doc.data()['strength'] ?? 0,
//         sugars: doc.data()['sugars'] ?? '0'
//     );
//   }).toList();
// }

// get brews stream
// Stream<List<Brew>> get brews {
//   return brewCollection.snapshots()
//       .map(_brewListFromSnapshot);
// }

// UserData getUserData() {
//   UserData userdata;
//   userCollection.doc(uid).get()
//       .then((value) {
//         userdata =  _userDataFromSnapshot(value);
//   });
//   return userdata;
// }