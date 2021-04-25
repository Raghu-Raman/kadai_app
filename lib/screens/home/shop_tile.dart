import 'package:flutter/material.dart';
import 'package:kadai_app/models/shop.dart';
import 'package:kadai_app/models/user.dart';
import 'package:kadai_app/screens/shop/shop_page.dart';
import 'package:kadai_app/services/fire_storage.dart';
import 'package:kadai_app/services/user_db.dart';
import 'package:kadai_app/shared/loading.dart';
import 'package:provider/provider.dart';


class ShopTile extends StatelessWidget {

  final Shop shop;
  ShopTile( {this.shop });

  @override
  Widget build(BuildContext context) {

    final FUser user = Provider.of<FUser>(context);
    final FocusScopeNode currentFocus = FocusScope.of(context);

    return FutureBuilder(
      future: FireStorageService().loadImage(image: shop.image),
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
              margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage(imageSnap.data.toString()),
                ),
                title: Text(shop.name.toUpperCase()),
                subtitle: Text('address: ${shop.address}'),
                onTap: () {
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  Navigator.push(context,
                    new MaterialPageRoute(
                        builder: (context) {
                          return StreamProvider<UserData>.value(
                              value: DatabaseService(uid: user.uid).userData,
                              //initialData: null,
                              child: ShopPage(shop: shop),
                          );
                        }
                    )
                  );
                },
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
}
