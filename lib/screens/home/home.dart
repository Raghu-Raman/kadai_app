import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kadai_app/models/shop.dart';
import 'package:kadai_app/models/user.dart';
import 'package:kadai_app/screens/purchase/my_cart.dart';
import 'package:kadai_app/screens/user_inputs/input_form.dart';
import 'package:kadai_app/services/auth.dart';
import 'package:kadai_app/screens/home/shop_list.dart';
import 'package:kadai_app/services/shop_db.dart';
import 'package:kadai_app/services/user_db.dart';
import 'package:kadai_app/shared/constants.dart';
import 'package:kadai_app/shared/loading.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget{

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AuthService _auth = AuthService();
  final myController = TextEditingController();



  // List<String> shopNames = [];
  // void setShopNames(List<String> shopNames) {
  //   print(shopNames);
  //   if(this.shopNames.length == 0){
  //     this.shopNames = shopNames;
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    final UserData userData = Provider.of<UserData>(context);

    return Scaffold(
        backgroundColor: Colors.brown[50],
        appBar: AppBar(
          title: Text(
            'Kadai App', style: TextStyle(color: Color(0xFFE8CE46))
          ),
          backgroundColor: Color(0xFF211F16),
          elevation: 0.0,
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                print('my cart');
                Navigator.push(context,
                    new MaterialPageRoute(
                    builder: (context) {
                      return StreamProvider<UserData>.value(
                        value: DatabaseService(uid: userData.uid).userData,
                        //initialData: null,
                        child: MyCart(),
                    );
                  }
                ));
              },
              icon: Icon(Icons.shopping_cart, color: Color(0xFFE8CE46)),
              label: Text(
                  'My Cart', style: TextStyle(color: Color(0xFFE8CE46)),
              ),
              style : ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF211F16)),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          elevation: 10,
          child: Container(
            color: Color(0xFFB9B5B5),
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xFF211F16),
                  ),
                    accountName: Text(userData.name, style: TextStyle(fontSize: 20.0, color: Color(0xFFE8CE46)),),
                    accountEmail: Text(userData.email, style: TextStyle(color: Color(0xFFE8CE46))),
                ),
                ListTile(
                  title: Text('My Orders'),
                ),
                ListTile(
                  title: Text('My Cart'),
                  //selectedTileColor: Color(0xFF211F16),
                  onTap:() {
                    print('My cart');
                    Navigator.pop(context);
                    Navigator.push(context,
                        new MaterialPageRoute(
                            builder: (context) {
                              return StreamProvider<UserData>.value(
                                value: DatabaseService(uid: userData.uid).userData,
                                //initialData: null,
                                child: MyCart(),
                              );
                            }
                        ));
                  },
                ),
                ListTile(
                  title: Text('My Account'),
                ),
                ListTile(
                  title: Text('Payment Details'),
                ),
                ListTile(
                  title: Text('Log out'),
                  autofocus: true,
                  onTap: () async {
                    await _auth.signOut();
                    return Loading();
                  },
                ),
              ],
            ),
          ),
        ),
        body: Container(
          //padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  color: Color(0xFFB9B5B5),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'Search by Product'
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        decoration: textInputDecoration.copyWith(hintText: 'Product'),
                        controller: myController,
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  color: Color(0xFFB9B5B5),
                  child: ShopList(),
                  ),
              ],
            ),
          ),
        ),
    );

  }
}
