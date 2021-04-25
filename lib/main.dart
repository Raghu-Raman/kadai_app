import 'package:flutter/services.dart';
import 'package:kadai_app/models/user.dart';
import 'file:///D:/Android_Studio_LD/Projects/kadai_app/lib/screens/controller/wrapper.dart';
import 'package:kadai_app/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black, // navigation bar color
    statusBarColor: Colors.grey,
    statusBarBrightness: Brightness.dark,
    //     statusBarIconBrightness: Brightness.dark, // status bar icon color
    //     systemNavigationBarIconBrightness: Brightness.light
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<FUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        home: WrapperLayerOne(),
      ),
    );
  }
}