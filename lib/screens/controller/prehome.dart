import 'package:flutter/material.dart';
import 'package:kadai_app/models/user.dart';
import 'package:kadai_app/screens/controller/wrapper.dart';
import 'package:kadai_app/services/user_db.dart';
import 'package:provider/provider.dart';


class PreHome extends StatefulWidget {
  @override
  _PreHomeState createState() => _PreHomeState();
}

class _PreHomeState extends State<PreHome> {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<FUser>(context);

    return StreamProvider<UserData>.value(
      value: DatabaseService(uid: user.uid).userData,
      child: WrapperLayerTwo(),
    );
  }
}
