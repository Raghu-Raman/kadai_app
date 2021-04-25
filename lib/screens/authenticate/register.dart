import 'package:email_validator/email_validator.dart';
import 'package:kadai_app/services/auth.dart';
import 'package:kadai_app/services/user_db.dart';
import 'package:kadai_app/shared/constants.dart';
import 'package:kadai_app/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class Register extends StatefulWidget {

  final Function toggleView;
  Register({ this.toggleView });

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Color(0xFFB9B5B5),
      appBar: AppBar(
        backgroundColor: Color(0xFF211F16),
        elevation: 0.0,
        title: Text('Sign up to Kadai', style: TextStyle(color: Color(0xFFE8CE46)),),
        actions: [
          FlatButton.icon(
            onPressed: () {
              widget.toggleView();
            },
            icon: Icon(Icons.person, color: Color(0xFFE8CE46),),
            label: Text('Sign In', style: TextStyle(color: Color(0xFFE8CE46)),),
          )
        ],
      ),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: 'Email'),
                    validator: (val) => !(EmailValidator.validate(val, true)) ? 'Enter valid email' : null,
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: 'Password'),
                    obscureText: true,
                    validator: (val) => val.length < 8 ? 'Enter a password 8+ characters long' : null,
                    onChanged: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                  ),
                  SizedBox(height: 20.0),
                  RaisedButton(
                    color: Color(0xFF211F16),
                    child: Text(
                      'Register',
                      style: TextStyle(color: Color(0xFFE8CE46)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          loading = true;
                        });

                        dynamic result = await _auth.registerWithEmailAndPassword(email, password);

                        if(result != null) {
                          print(result.uid);
                          await DatabaseService(uid: result.uid).createUserData(email: result.email);
                          setState(() {
                            error = '';
                            Toast.show(
                                "An email has just been sent to you, Click the link provided to complete registration",
                                context,
                                duration: 4,
                                gravity:  Toast.BOTTOM
                            );

                            loading = false;
                            widget.toggleView();
                          });
                        }
                        if (result == null) {
                          setState(() {
                            error = 'please supply valid email';
                            loading = false;
                          });
                        }
                      }
                    },
                  ),
                  SizedBox(height: 20.0,),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14.0),
                  )
                ],
              ),
            ),
          )
      ),
    );
  }
}
