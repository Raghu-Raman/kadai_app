import 'package:flutter/material.dart';
import 'package:kadai_app/models/user.dart';
import 'package:kadai_app/screens/shop/shop_page.dart';
import 'package:kadai_app/services/user_db.dart';
import 'package:kadai_app/services/shop_db.dart';
import 'package:kadai_app/models/shop.dart';
import 'package:kadai_app/screens/home/shop_tile.dart';
import 'package:kadai_app/shared/constants.dart';
import 'package:kadai_app/shared/loading.dart';
import 'package:provider/provider.dart';

class ShopList extends StatefulWidget {
  // final Function setShopNames;
  // ShopList({this.setShopNames});

  @override
  _ShopListState createState() => _ShopListState();
}

class _ShopListState extends State<ShopList> {

  final myController = TextEditingController();
  bool init = true;

  List<Shop> shopList = <Shop>[];
  initShopList(List<Shop> shops) {
    for(Shop shop in shops) {
      shopList.add(shop);
    }
  }

  @override
  Widget build(BuildContext context) {

    final UserData userdata = Provider.of<UserData>(context);



    Shop searchShop(List<Shop> shops, String shopName) {
      for(Shop shop in shops) {
        if(shop.name == shopName) {
          return shop;
        }
      }
      return null;
    }

    // TODO remove this streamprovider if it is unnecessary
    return StreamProvider<List<Shop>>.value(
      value: ShopDatabaseService(pincode: userdata != null ? userdata.pincode : null).shops,
      child: StreamBuilder<List<Shop>>(
        stream: ShopDatabaseService(pincode: userdata != null ? userdata.pincode : null).shops,
          builder: (context, shops) {
            if (shops.data == null) {
              return Loading();
            } else {
              if(init) {
                initShopList(shops.data);
                init = false;
              }
              return Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        'Search by Shop'
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    decoration: textInputDecoration.copyWith(hintText: 'Shop'),
                    controller: myController,
                    onChanged: (value) {
                      setState(() {
                        if(value.length == 0) {
                          initShopList(shops.data);
                        }
                        else {
                          shopList = <Shop>[];
                          for(Shop shop in shops.data) {
                            if(shop.name.toLowerCase().contains(value.toLowerCase())) {
                              shopList.add(shop);
                            }
                          }
                        }
                      });
                    },
                  ),

                  SizedBox(height: 10.0),
                  Text(
                      'List of Shops in your area'
                  ),
                  SizedBox(height: 5.0),
                  Container(
                      height: MediaQuery.of(context).size.height * 0.55,
                    child: ListView.builder(
                      itemCount: shopList.length,
                      itemBuilder: (context, index) {
                        return ShopTile(shop: shopList[index]);
                      }
                    ),
                  ),
                ],
              );
            }
          }
      ),
    );
  }
}

