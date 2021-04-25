class Shop {
  String name;
  String desc;
  String email;
  String phone;
  // change to reference
  String image;
  String address;
  Shop({this.name, this.desc, this.email, this.phone, this.image, this.address});
}

class Categories {
  String name;
  String desc;
  Categories({this.name, this.desc});
}

class Product {
  double price;
  int quantity;
  String name;
  String image;
  String desc;
  String category;
  Product({this.price, this.quantity, this.name, this.image, this.desc, this.category});
}