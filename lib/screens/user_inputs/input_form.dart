import 'package:flutter/material.dart';
import 'package:kadai_app/models/user.dart';
import 'package:kadai_app/services/user_db.dart';
import 'package:kadai_app/shared/constants.dart';
import 'package:provider/provider.dart';

class InputDetails extends StatefulWidget {
  @override
  _InputDetailsState createState() => _InputDetailsState();
}

class _InputDetailsState extends State<InputDetails> {

  final _formKey = GlobalKey<FormState>();
  var _textController = new TextEditingController();

  // input details
  String name = '';
  String dob = '';
  String phoneNumber = '';
  String pincode = '';


  bool isValidDate(String input) {
    try {
      final date = DateTime.parse(input);
      return input == date.toString().substring(0,10);
    } catch(e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<FUser>(context);

    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text('Before you shop..'),
      ),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20.0),
                  // name
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        "Full Name",
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: 'Name'),
                    validator: (val) => val.length == 0 ? 'Enter valid Name' : null,
                    onChanged: (val) {
                      setState(() {
                        name = val;
                      });
                    },
                  ),
                  SizedBox(height: 20.0),
                  // DOB
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        "Date of Birth",
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: 'dd-mm-yyyy'),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if(val.length != 10) {
                        return 'Enter valid Date of Birth';
                      }
                      String formatted = '';
                      final values = val.split("-");
                      formatted = values[2] + '-' + values[1] + '-' + values[0];
                      final date = DateTime.parse(formatted);
                      if(formatted == date.toString().substring(0,10)) {
                        return null;
                      } else {
                        return 'Enter valid Date of Birth';
                      }
                    },
                    onChanged: (val) {
                      setState(() {
                        val = val.replaceAll("-", "");
                        if(val.length <= 2) {
                          _textController.text = val;
                          _textController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _textController.text.length),
                          );
                        }
                        else if(val.length <= 4) {
                          _textController.text = val.substring(0,2) + '-' + val.substring(2);
                          _textController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _textController.text.length),
                          );
                        }
                        else if(val.length <= 8) {
                          _textController.text = val.substring(0,2) + '-' + val.substring(2,4) + '-' + val.substring(4);
                          _textController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _textController.text.length),
                          );
                          dob = _textController.text;
                        }
                        else {
                          _textController.text = val.substring(0,2) + '-' + val.substring(2,4) + '-' + val.substring(4,8);
                          _textController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _textController.text.length),

                          );
                          dob = _textController.text;
                        }
                      });
                    },
                    controller: _textController,
                  ),
                  SizedBox(height: 20.0),
                  // phone number(not verified, basic validation)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        "Phone Number",
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: 'Phone Number'),
                    keyboardType: TextInputType.number,
                    validator: (val) => val.length != 10 ? 'Enter valid Phone Number(10 digits)' : null,
                    onChanged: (val) {
                      setState(() {
                        phoneNumber = val;
                      });
                    },
                  ),
                  SizedBox(height: 20.0),
                  // pincode(basic validation, not verified)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        "Pincode",
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: 'Pincode'),
                    keyboardType: TextInputType.number,
                    validator: (val) => val.length != 6 ? 'Enter valid Pindcode' : null,
                    onChanged: (val) {
                      setState(() {
                        pincode = val;
                      });
                    },
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.brown[400]),
                      ),
                      onPressed: () async {
                        print(name + "\n" + dob + "\n" + phoneNumber + "\n" + pincode);
                        if(_formKey.currentState.validate()) {
                          await DatabaseService(uid: user.uid).updateUserData(name, dob, phoneNumber, pincode);
                        }

                      },
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      )
                  ),
                ],
              ),
            ),
          )
      ),
    );

  }
}
