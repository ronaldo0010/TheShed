import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rw334/models/user.dart';

class Edit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.black,
        title: Text("Edit Profile"),
      ),
      body: EditBody(),
    );
  }
}

class EditBody extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  showAlertDialog(BuildContext context) {
    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Align(
        alignment: Alignment.center,
        child: Text(
          "OOPS!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      content: Text(
        "Something went wrong. Please try again.",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, child) {
        return Container(
          color: Color.fromRGBO(41, 41, 41, 1),
          child: Column(
            children: <Widget>[
              Card(
                margin: EdgeInsets.only( top: 8.0, bottom: 8.0, left: 10.0, right: 10.0 ),
                color: Color.fromRGBO(41, 41, 41, 1),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: TextField(
                        cursorColor: Theme.of(context).accentColor,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          focusedBorder: new OutlineInputBorder(
                            borderSide: new BorderSide(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                          hintText: "New username",
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7)
                          )
                        ),
                        controller: usernameController,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      child: TextField(
                        cursorColor: Theme.of(context).accentColor,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          focusedBorder: new OutlineInputBorder(
                            borderSide: new BorderSide(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                          hintText: "Current password",
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7)
                          )
                        ),
                        controller: passwordController,
                      ),
                    ),
                  ],
                ),
              ),
              RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  "SAVE",
                  style: TextStyle( fontSize: 16, fontWeight: FontWeight.bold ),
                ),
                onPressed: () async {
                  String username = usernameController.text;
                  String password = passwordController.text;
                  // final user = usr.dummy; // not necessary since we now get user from the Consumer above
                  bool res = await user.update(username, password);
                  if (res == true) {
                    Navigator.of(context).pop(true);
                  } else {
                    showAlertDialog(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
