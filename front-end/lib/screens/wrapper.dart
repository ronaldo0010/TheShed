import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rw334/service/httpService.dart';
import 'authenticate/login.dart';
import 'home/home.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final passBox = Hive.box('psw');
  final userBox = Hive.box('usr');
  final stBox = Hive.box('status');

  _RootPageState();

  @override
  Widget build(BuildContext context) {
    bool _state;
    if (stBox.get(0) as bool == null) {
      _state = false;
    }
    else {
      _state = stBox.get(0) as bool;
    }

    print(_state);

    //if (_state == null) {
     // Hive.box('status').put(0, false);
    //}


    String _usr = userBox.get(0) as String;
    String _psw = passBox.get(0) as String;

    if (_state) {
      WidgetsFlutterBinding.ensureInitialized();
      loggedIn(_usr, _psw);
      return Home(psw:_psw);
    } else {
      //Hive.box('status').put(0, null);
      return LoginScreen();
    }


  }
}
