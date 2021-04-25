import 'package:email_validator/email_validator.dart';
import 'package:kadai_app/services/auth.dart';
import 'package:kadai_app/shared/constants.dart';
import 'package:kadai_app/shared/loading.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  SignIn({ this.toggleView });

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

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
        title: Text('Sign in to Kadai', style: TextStyle(color: Color(0xFFE8CE46))),
        actions: [
          FlatButton.icon(
            onPressed: () {
              widget.toggleView();
            },
            icon: Icon(Icons.person, color: Color(0xFFE8CE46)),
            label: Text('Register', style: TextStyle(color: Color(0xFFE8CE46))),
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
                      'Sign in',
                      style: TextStyle(color:Color(0xFFE8CE46)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          loading = true;
                        });
                        dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                        // setState(() {
                        //
                        // });
                        if(result == null) {
                          setState(() {
                            error = 'Could not sign with those credentials';
                            loading = false;
                          });
                        }
                        else if(result.isVerified == false) {
                          setState(() {
                            error = 'Please verify your mail before login.\nCheck your inbox for verification.';
                            loading = false;
                          });
                          await _auth.signOut();
                        }
                        else if(result.isVerified == true) {
                          // loading = true;
                          // await _auth.signOut();
                          //
                          // await _auth.signInWithEmailAndPassword(email, password);
                          if(mounted) {
                            setState(() {
                              loading = false;
                            });
                          }
                        }
                      }
                      else {
                        setState(() {
                          error = '';
                        });
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
