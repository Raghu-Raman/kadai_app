import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kadai_app/models/shop.dart';
import 'package:kadai_app/models/user.dart';
import 'package:kadai_app/screens/shop/product_list.dart';
import 'package:kadai_app/services/shop_db.dart';
import 'package:kadai_app/shared/loading.dart';
import 'package:provider/provider.dart';

class CategoryList extends StatefulWidget {

  final Shop shop;
  CategoryList({this.shop});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<CategoryList> {

  String category;

  @override
  Widget build(BuildContext context) {

    List<Categories> categories = Provider.of<List<Categories>>(context);
    UserData userData = Provider.of<UserData>(context);

    Future<dynamic> getCategory() async{
      var s;
      if(category == null){
        s = categories[0].name;
        category = s;
      }
      else{
        s = category;
      }
      return s;
    }

    return SafeArea(
      child: FutureBuilder(
        future: getCategory(),
        builder: (context, categorySnap) {
          return Column(
            children: [
              // category list
              Container(
                  //padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.09,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories != null ? categories.length : 0,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                          color: Color(0xFFEAEAEA),
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.35,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                category = categories[index].name;
                              });
                            },
                            child: Card(
                              elevation: 10,
                              color: categories[index].name == categorySnap.data ? Color(
                                  0xFFD2B009) : Color(0xFFE8CE46),
                              child: Container(
                                child: Center(
                                  child: Text(
                                    categories[index].name,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: categories[index].name.length < 11 ? 20.0 : 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                  )
              ),
              // product list
              Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 0.0),
                  height: MediaQuery.of(context).size.height * 0.79,
                  child: category != null
                      ? StreamProvider<List<Product>>.value(
                    //initialData: [],
                    value: ShopDatabaseService(
                        pincode: userData != null ? userData.pincode : null)
                        .getProducts(
                        shopName: widget.shop.name, category: categorySnap.data),
                    child: ProductList(shopName: widget.shop.name, category: category),
                  )
                      : Loading()
              )
            ],
          );
        }
      ),
    );
  }

}
