import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kadai_app/models/shop.dart';
import 'package:kadai_app/models/user.dart';
import 'package:kadai_app/services/fire_storage.dart';

class ShopDatabaseService {

  final String pincode;
  ShopDatabaseService({this.pincode});

  final CollectionReference shopCollection = FirebaseFirestore.instance.collection('pincode');

  //shop list from snapshots
  List<Shop> _shopListFromSnapshot(QuerySnapshot snapshots) {
    return snapshots.docs.map((doc) {
      print(doc.id);
      return Shop(
          name: doc.id ?? '',
          desc: doc.data()['desc'] ?? '',
          email: doc.data()['email'] ?? '',
          phone: doc.data()['phone'] ?? '',
          image: doc.data()['image'] ?? '',
          address: doc.data()['address'] ?? ''
      );
    }).toList();
  }

  //get shops stream
  Stream<List<Shop>> get shops {
    return shopCollection.doc(pincode).collection('shops').snapshots()
        .map(_shopListFromSnapshot);
  }

  // Category list from snapshot
  List<Categories> _categoriesFromSnapshot(QuerySnapshot snapshots) {
    return snapshots.docs.map((doc) {
      return Categories(
          name: doc.id ?? '',
          desc: doc.data()['desc'] ?? ''
      );
    }).toList();
  }

  // get categories stream
  Stream<List<Categories>> getCategories({String shopName}) {
    return shopCollection.doc(pincode).collection('shops').doc(shopName).collection('categories').snapshots()
        .map(_categoriesFromSnapshot);
  }

  // Product list from snapshot
  List<Product> _productsFromSnapshot(QuerySnapshot snapshots, String category) {
    return snapshots.docs.map((doc) {
      return Product(
        name: doc.id,
        price: doc.data()['price'] != null ? doc.data()['price'].toDouble() : 0.0,
        quantity: doc.data()['quantity'] ?? 0,
        image: doc.data()['image'] ?? '',
        desc: doc.data()['desc'] ?? '',
        category: category
      );
    }).toList();
  }
  // stream
  Stream<List<Product>> getProducts({String shopName, String category}) {
    return shopCollection.doc(pincode).collection('shops')
        .doc(shopName).collection('categories').doc(category).collection('products').snapshots()
        .map((snapshot) => _productsFromSnapshot(snapshot, category));
  }

  Future<bool> checkQuantity(Product product, String shopName) async {
    return await shopCollection.doc(pincode).collection('shops')
        .doc(shopName).collection('categories').doc(product.category).collection('products')
        .doc(product.name).get().then((value) => value.data()['quantity']) >= product.quantity;
  }

  Future<bool> checkOrder(Cart cart) async {
    for (Product product in cart.products) {
      try {
        if(await checkQuantity(product, cart.shopName) == false) {
          return false;
        }
      }
      catch (e) {
        print(e.toString());
      }
    }
    return true;
  }

  Future updateQuantity(Product product, String shopName, bool subtract) async {
    if(subtract) {
      var quantity = await shopCollection.doc(pincode).collection('shops')
          .doc(shopName).collection('categories').doc(product.category).collection('products')
          .doc(product.name).get().then((value) => value.data()['quantity']);
      return await shopCollection.doc(pincode).collection('shops')
          .doc(shopName).collection('categories').doc(product.category).collection('products').doc(product.name).update({
        'quantity' : quantity - product.quantity
      });
    }
    else {
      return await shopCollection.doc(pincode).collection('shops')
          .doc(shopName).collection('categories').doc(product.category).collection('products').doc(product.name).update({
        'quantity' : await shopCollection.doc(pincode).collection('shops')
            .doc(shopName).collection('categories').doc(product.category).collection('products')
            .doc(product.name).get().then((value) => value.data()['quantity']) + product.quantity
      });
    }

  }

  Future placeOrder(Cart cart) async {
    for (Product product in cart.products) {
      try {
        updateQuantity(product, cart.shopName, true);
      }
      catch (e) {
        print(e.toString());
      }
    }
  }

  Future revertOrder(Cart cart) async {
    for (Product product in cart.products) {
      try {
        updateQuantity(product, cart.shopName, false);
      }
      catch (e) {
        print(e.toString());
      }
    }
  }

}


// Future<List<Shop>> getShops() async {
//   List<Shop> shops = List<Shop>();
//   await shopCollection.doc(pincode).collection('shops').get().then((querySnapshot) {
//     querySnapshot.docs.forEach((shop) {
//       shops.add(_shopDataFromSnapshot(shop));
//     });
//   });
//   print(shops.length);
//   return shops;
// }
//
// Shop _shopDataFromSnapshot(DocumentSnapshot shop) {
//   return Shop(
//     name: shop.id,
//     desc: shop.data()['desc'],
//     email: shop.data()['email'],
//     phone: shop.data()['phone'],
//     image: shop.data()['image'],
//     address: shop.data()['address']
//   );
// }