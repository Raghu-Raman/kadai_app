import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kadai_app/models/shop.dart';
import 'package:kadai_app/models/user.dart';
import 'package:kadai_app/screens/user_inputs/add_product.dart';
import 'package:kadai_app/services/fire_storage.dart';
import 'package:provider/provider.dart';

// TODO: update the cart with respect to the quantity available in the shop
// TODO: on check out ask user to delete out of stock item to place the order

class ProductList extends StatefulWidget {

  final String shopName;
  final String category;
  ProductList({this.shopName, this.category});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  @override
  Widget build(BuildContext context) {

    void _addProductToCart({Product product}) {
      showModalBottomSheet(context: context, builder: (context) {
        return Container(
          color: Color(0xFFB9B5B5),
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: AddProductWindow(product: product,shopName: widget.shopName, category: widget.category,),
        );
      });
    }

    final List<Product> products = Provider.of<List<Product>>(context);

    return GridView.builder(
      scrollDirection: Axis.vertical,
      itemCount: products != null ? products.length : 0,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      itemBuilder: (itemContext, index) {
        return FutureBuilder(
          future: FireStorageService().loadImage(image: products[index].image),
          builder: (itemContext, imageSnap) {
            if(imageSnap.hasData) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: InkWell(
                  onTap: () => _addProductToCart(product: products[index]),
                  child: Card(
                    elevation: 10,
                    color: Color(0xFFF5F8D7),
                    child: Container(
                      child: Column(
                        children: [
                          SizedBox(height: 5.0,),
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                              height: 130,
                              width: 130,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F8D7),
                                image: DecorationImage(
                                  image: imageSnap.data.toString() != ''
                                      ? NetworkImage(imageSnap.data.toString())
                                      : NetworkImage('https://firebasestorage.googleapis.com/v0/b/kadai-app-cf56d.appspot.com/o/shops%2Fshop.jpg?alt=media&token=80fe567f-45f8-4a3d-bcc9-1fd74d56a74b'),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              products[index].name.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: products[index].name.length > 10 ? 15 : 18.0),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: products[index].quantity <= 0 ? Text(
                              'Out of Stock',
                              style: TextStyle(
                                  color: Colors.red, fontSize: 13.0),
                            ) : Text(
                              'Rs.${products[index].price}',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 13.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            else {
              return Text('Loading..');
            }
          },
        );
      },
    );
  }
}
// filter: products[index].quantity <= 0
// ?  ImageFilter.blur(
// sigmaX: 2.0,
// sigmaY: 2.0,
// )
// : ImageFilter.blur(
// sigmaX: 0.0,
// sigmaY: 0.0,
// ),