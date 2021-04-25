import 'package:flutter/material.dart';
import 'package:kadai_app/models/shop.dart';
import 'package:kadai_app/models/user.dart';
import 'package:kadai_app/screens/authenticate/sign_in.dart';
import 'package:kadai_app/services/fire_storage.dart';
import 'package:kadai_app/services/user_db.dart';
import 'package:kadai_app/shared/functions.dart';
import 'package:kadai_app/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class AddProductWindow extends StatefulWidget {

  final Product product;
  final String shopName;
  final String category;
  AddProductWindow({this.product, this.shopName, this.category});

  @override
  _AddProductWindowState createState() => _AddProductWindowState();
}

class _AddProductWindowState extends State<AddProductWindow> {

  int quantity = 1;
  double totalCost;
  void initState() {
    super.initState();
    totalCost = widget.product.price;
  }

  @override
  Widget build(BuildContext context) {

    final FUser user = Provider.of<FUser>(context);

    return StreamBuilder<Cart>(
      stream: DatabaseService(uid: user.uid).cart,
      builder: (context, cartSnapshot) {
        if(cartSnapshot.hasData){
          return FutureBuilder(
            future: FireStorageService().loadImage(image: widget.product.image),
            builder: (context, imageSnap) {
              if(imageSnap.hasData){
                return Container(
                  //height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    children: [
                      Center(
                        child: Image.network(imageSnap.data.toString() != ''
                            ? imageSnap.data.toString()
                            : 'https://firebasestorage.googleapis.com/v0/b/kadai-app-cf56d.appspot.com/o/shops%2Fshop.jpg?alt=media&token=80fe567f-45f8-4a3d-bcc9-1fd74d56a74b',
                          height: 140,
                          width: 140,
                        ),
                      ),
                      SizedBox(height: 5.0,),
                      Text(
                        '${widget.product.name.toUpperCase()}',
                        style: TextStyle(fontSize: 17.0),
                      ),
                      SizedBox(height: 5.0,),
                      Text(
                        'Price : Rs.${widget.product.price}  Stock : ${widget.product.quantity}',
                        style: TextStyle(fontSize: 17.0),
                      ),
                      SizedBox(height: 5.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Quantity ',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.remove,
                              color: Theme.of(context).accentColor,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
                            iconSize: 25.0,
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              setState(() {
                                if (quantity > 1) {
                                  quantity--;
                                  totalCost = widget.product.price * quantity;
                                }
                              });
                            },
                          ),
                          Text(
                            '$quantity',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              color: Theme.of(context).accentColor,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
                            iconSize: 25.0,
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              setState(() {
                                if (quantity < widget.product.quantity) {
                                  quantity++;
                                  totalCost = widget.product.price * quantity;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0,),
                      Text(
                        'Total Cost : Rs.$totalCost',
                        style: TextStyle(fontSize: 17.0),
                      ),
                      SizedBox(height: 5.0,),
                      Flexible(
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF211F16)),
                            ),
                            onPressed: () async {
                              // out of stock
                              if(widget.product.quantity <= 0) {
                                Toast.show(
                                    "Currently out of Stock.",
                                    context,
                                    duration: 3,
                                    gravity:  Toast.BOTTOM
                                );
                              }
                              // cart already exists
                              else if(cartSnapshot.data.shopName != '') {
                                // different shops
                                if(cartSnapshot.data.shopName != widget.shopName) {
                                  Toast.show(
                                      "Your cart has items from ${cartSnapshot.data.shopName.toUpperCase()}. Please complete that order or remove those items before adding this item to the cart.",
                                      context,
                                      duration: 5,
                                      gravity:  Toast.BOTTOM
                                  );
                                }
                                // same shop
                                else {
                                  bool isItemAlreadyInCart = false;
                                  for(Product product in cartSnapshot.data.products) {
                                    if(product.name == widget.product.name) {
                                      isItemAlreadyInCart = true;
                                      if(quantity + product.quantity > widget.product.quantity) {
                                        Toast.show(
                                            "The total quantity of this item in your cart exceeds the stock. Cannot add this item to cart.",
                                            context,
                                            duration: 5,
                                            gravity:  Toast.BOTTOM
                                        );
                                        return;
                                      }
                                      else {
                                        product.quantity += quantity;
                                      }
                                    }
                                  }
                                  if(!isItemAlreadyInCart) {
                                    cartSnapshot.data.products.add(
                                        new Product(
                                            name: widget.product.name,
                                            price: widget.product.price.toDouble(),
                                            quantity: quantity,
                                            image: widget.product.image,
                                            desc: widget.product.desc,
                                            category: widget.category
                                        )
                                    );
                                  }
                                  Map newCart = createMap(cartSnapshot.data.products, widget.shopName);
                                  await DatabaseService(uid: user.uid).updateCart(newCart);
                                  Navigator.pop(context);
                                }
                              }
                              // cart is empty. New cart.
                              else {
                                cartSnapshot.data.products.add(
                                    new Product(
                                        name: widget.product.name,
                                        price: widget.product.price.toDouble(),
                                        quantity: quantity,
                                        image: widget.product.image,
                                        desc: widget.product.desc,
                                        category: widget.category
                                    )
                                );
                                Map newCart = createMap(cartSnapshot.data.products, widget.shopName);
                                await DatabaseService(uid: user.uid).updateCart(newCart);
                                Navigator.pop(context);
                              }
                            },
                            child: Text(
                              'Add To Cart',
                              style: TextStyle(color: Color(0xFFE8CE46)),
                            )
                        ),
                      ),
                    ],
                  ),
                );
              }
              else {
                return Loading();
              }
            },
          );
        }
        else {
          return Loading();
        }
      }
    );
  }
}
