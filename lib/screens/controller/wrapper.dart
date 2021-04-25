import 'package:kadai_app/models/user.dart';
import 'package:kadai_app/screens/authenticate/authenticate.dart';
import 'package:kadai_app/screens/controller/prehome.dart';
import 'package:kadai_app/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:kadai_app/screens/user_inputs/input_form.dart';
import 'package:kadai_app/shared/loading.dart';
import 'package:provider/provider.dart';

class WrapperLayerOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<FUser>(context);

    // return either home or authenticate widget
    if(user == null)
    {
      return Authenticate();
    }
    else {
      if(user.isVerified){
        return PreHome();
      }
      else {
        return Authenticate();
      }
    }
  }
}

class WrapperLayerTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<UserData>(context);
    if(userData != null){
      if(userData.pincode == '') {
        return InputDetails();
      }
      else {
        return Home();
      }
    }
    else {
      return Loading();
    }

    //return Container();
  }
}

