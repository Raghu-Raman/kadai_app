import 'package:kadai_app/models/shop.dart';

double calculateTotalCost(List<Product> products) {
  double totalCost = 0;
  for(Product product in products) {
    totalCost += product.quantity * product.price;
  }
  return totalCost;
}

Map createMap(List<Product> products, String shopName) {
  Map cart = new Map();
  cart['products'] = new Map();
  if(products.length == 0) {
    cart['shopName'] = '';
    cart['totalCost'] = 0.0;
    return cart;
  }
  int count = 0;
  cart['shopName'] = shopName;
  cart['totalCost'] = calculateTotalCost(products);

  // adding the existing product to the cart
  for(Product product in products) {
    cart['products'][count.toString()] = new Map();
    Map temp = cart['products'][count.toString()];
    temp['desc'] = product.desc;
    temp['image'] = product.image;
    temp['name'] = product.name;
    temp['price'] = product.price;
    temp['quantity'] = product.quantity;
    temp['category'] = product.category;
    count += 1;
  }
  return cart;
}