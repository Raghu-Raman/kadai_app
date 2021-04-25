import 'package:flutter/material.dart';
import 'package:kadai_app/models/shop.dart';
import 'package:kadai_app/models/user.dart';
import 'package:kadai_app/services/fire_storage.dart';
import 'package:kadai_app/services/shop_db.dart';
import 'package:kadai_app/services/user_db.dart';
import 'package:kadai_app/shared/functions.dart';
import 'package:kadai_app/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:toast/toast.dart';

class MyCart extends StatefulWidget {
  @override
  _MyCartState createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  
  Razorpay razorpay;
  bool paymentSuccess = false;
  bool paymentError = false;
  bool externalWallet = false;
  String _uid;
  String _pincode;
  Cart _cart;
  
  void initState() {
    super.initState();
    
    razorpay = new Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    super.dispose();

    razorpay.clear();
  }

  Future openCheckout(totalCost, shopName, UserData userData) async{
    var options = {
      "key" : "rzp_test_nSVHznCZfOIISd",
      "amount" : totalCost * 100,
      "name" : userData.name,
      "description" : "Payment to $shopName",
      "prefill" : {
        "contact" : userData.phoneNumber,
        "email" : userData.email,
      },
      "external" : {
        "wallets" : ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    }
    catch(e) {
      print(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Toast.show(
        "Payment Successful.",
        context,
        duration: 3,
        gravity:  Toast.BOTTOM
    );
    setState(() {
      paymentSuccess = true;
    });

  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Toast.show(
        "Payment failed.",
        context,
        duration: 3,
        gravity:  Toast.BOTTOM
    );
    setState(() {
      paymentError = true;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Toast.show(
        "External Wallet.",
        context,
        duration: 3,
        gravity:  Toast.BOTTOM
    );
    setState(() {
      externalWallet = true;
    });
  }

  
  @override
  Widget build(BuildContext context) {

    if(_uid != null && paymentSuccess) {
      Map newCart = createMap([], '');
      DatabaseService(uid: _uid).updateCart(newCart);
      setState(() {
        paymentSuccess = false;
      });
    }

    if(_cart != null && _pincode != null && paymentError) {
      ShopDatabaseService(pincode: _pincode).revertOrder(_cart);
      setState(() {
        paymentError = false;
      });
    }

    final UserData userData = Provider.of<UserData>(context);

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
                'My Cart', style: TextStyle(color: Color(0xFFE8CE46))
            ),
            backgroundColor: Color(0xFF211F16),
          ),
          body: StreamBuilder<Cart>(
            stream: DatabaseService(uid: userData != null ? userData.uid : null).cart,
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                Cart cart = snapshot.data;
                List<Product> products = cart.products;
                if(cart.shopName == '') {
                  return Container(
                    child: Center(
                      child: Text(
                        'Your cart is empty.'
                      ),
                    ),
                  );
                }
                else{
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    child: Column(
                      children: [
                        Container(
                          color: Color(0xFF211F16),
                          height: MediaQuery.of(context).size.height * 0.08,
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              child: Text(
                                cart.shopName.toUpperCase(),
                                style: TextStyle(color: Color(0xFFE8CE46), fontSize: 20.0
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: ListView.builder(
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                double totalCost = products[index].price * products[index].quantity;
                                return FutureBuilder(
                                  future: FireStorageService().loadImage(image: products[index].image),
                                  builder:(context, imageSnap) {
                                    print(imageSnap.data);
                                    if(imageSnap.hasData) {
                                      return Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Card(
                                          elevation: 10,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          color: Color(0xFFF5F8D7),
                                          //margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              radius: 30.0,
                                              backgroundImage: imageSnap.data.toString() != ''
                                                  ? NetworkImage(imageSnap.data.toString())
                                                  : NetworkImage('https://firebasestorage.googleapis.com/v0/b/kadai-app-cf56d.appspot.com/o/shops%2Fshop.jpg?alt=media&token=80fe567f-45f8-4a3d-bcc9-1fd74d56a74b'),
                                            ),
                                            trailing: IconButton(
                                              icon: Icon(Icons.cancel),
                                              onPressed: () async {
                                                setState(() async {
                                                  products.removeAt(index);
                                                  Map newCart = createMap(products, cart.shopName);
                                                  await DatabaseService(uid: userData.uid).updateCart(newCart);
                                                });
                                              },
                                            ),
                                            title: Text(products[index].name.toUpperCase()),
                                            subtitle: Text('Quantity: ${products[index].quantity}, Price: ${products[index].price} \nTotal Cost: $totalCost '),
                                          ),
                                        ),
                                      );
                                    }
                                    else {
                                      return Text('Loading...');
                                    }
                                  },
                                );
                              }
                          ),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF211F16)),
                                    ),
                                    onPressed: () async {
                                      Map newCart = createMap([], '');
                                      await DatabaseService(uid: userData.uid).updateCart(newCart);
                                    },
                                    child: Text(
                                      '      Empty Cart      ',
                                      style: TextStyle(color: Color(0xFFE8CE46)),
                                    )
                                ),
                              ),
                              SizedBox(width: 5.0,),
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF211F16)),
                                    ),
                                    onPressed: () async {
                                      _uid = userData.uid;
                                      _pincode = userData.pincode;
                                      _cart = cart;
                                      if(await ShopDatabaseService(pincode: userData.pincode).checkOrder(cart)) {
                                        await ShopDatabaseService(pincode: userData.pincode).placeOrder(cart);
                                        await openCheckout(cart.totalCost, cart.shopName, userData);
                                        Navigator.pop(context);
                                        setState(() {
                                          print('reloading');
                                        });
                                      }
                                      else {
                                        Toast.show(
                                            "Some of the products in your car is currently out of Stock.\nModify your cart before you place order.",
                                            context,
                                            duration: 5,
                                            gravity:  Toast.BOTTOM
                                        );
                                      }
                                    },
                                    child: Text(
                                      '       Buy Now      ',
                                      style: TextStyle(color: Color(0xFFE8CE46)),
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
              else {
                return Loading();
              }
            },
          ),
        )
    );
  }
}
