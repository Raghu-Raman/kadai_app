import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kadai_app/models/shop.dart';
import 'package:kadai_app/models/user.dart';
import 'package:kadai_app/screens/shop/category_list.dart';
import 'package:kadai_app/screens/shop/product_list.dart';
import 'package:kadai_app/services/shop_db.dart';
import 'package:kadai_app/shared/loading.dart';
import 'package:provider/provider.dart';

class ShopPage extends StatefulWidget {

  final Shop shop;
  ShopPage({this.shop});

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {

  // String category;
  // void setCategory(String newCategory) {
  //   print(category);
  //   setState(() {
  //     category = newCategory;
  //   });
  // }

  @override
  Widget build(BuildContext context) {

    final UserData userdata = Provider.of<UserData>(context);

    //final List<String> categoriesList = [];

    return StreamProvider<List<Categories>>.value(
      value: ShopDatabaseService(pincode: userdata != null ? userdata.pincode : null).getCategories(shopName: widget.shop.name),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF211F16),
            title: Text(
                widget.shop.name.toUpperCase(),
              style: TextStyle(color: Color(0xFFE8CE46)),
            ),
          ),
          body: CategoryList(shop: widget.shop,),
        ),
      ),
    );
  }
}
