import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:rw334/models/user.dart';
import 'package:rw334/screens/authenticate/login.dart';
import 'package:rw334/service/httpService.dart';
import 'edit.dart';

class SettingsDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, child) {
        return Drawer(
          child: Column(
            children: <Widget>[
              Container(
                height: 90,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(20),
                color: Colors.black,
                child: Center(
                  child: Text(
                    "Options",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height - 150,
                color: Color.fromRGBO(41, 41, 41, 1),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person, color: Theme.of(context).accentColor, ),
                      title: Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        // Navigator.pushNamed(context, EDIT, arguments: context); // this stopped working when implementing the Provider architecture :(
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => Edit()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.arrow_back, color: Theme.of(context).accentColor, ),
                      title: Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        user.logout();
                        Hive.box('status').put(0, null);

                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                            (Route<dynamic> route) => false);
                      },
                    ),
                    ListTile(
                      leading: Icon( Icons.delete, color: Theme.of(context).accentColor, ),
                      title: Text(
                        "Delete Account",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        user.logout();
                        Hive.box('status').put(0, null);
                        deleteAccount();
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                                (Route<dynamic> route) => false);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
