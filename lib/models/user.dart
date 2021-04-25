
import 'package:kadai_app/models/shop.dart';

class FUser {
  final String uid;
  final String email;
  final bool isVerified;

  FUser({ this.uid, this.email, this.isVerified});
}

class UserData {
  final String uid;
  final String name;
  final String dob;
  final String phoneNumber;
  final String email;
  final String pincode;

  UserData({ this.uid, this.name, this.dob, this.phoneNumber, this.email, this.pincode });
}

class Cart {
  final String shopName;
  final double totalCost;
  final List<Product> products;

  Cart({this.shopName, this.totalCost, this.products});

}