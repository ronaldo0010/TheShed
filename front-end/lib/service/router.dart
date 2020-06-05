import 'package:flutter/material.dart';
import 'package:rw334/screens/home/chats.dart';
import 'package:rw334/screens/home/chatscreen.dart';
import 'package:rw334/screens/home/edit.dart';
import 'package:rw334/screens/home/home.dart';

import 'constants.dart';

// ignore: missing_return
Route<dynamic> generateRoute(RouteSettings settings) {
  BuildContext context = settings.arguments;
  Navigator.popUntil(context, ModalRoute.withName(HOME));
  switch (settings.name) {
    case HOME:
      return MaterialPageRoute(builder: (context) => UserHomePage());
    case EDIT:
      return MaterialPageRoute(builder: (context) => Edit());
    case CHAT:
      return MaterialPageRoute(builder: (context) => ChatsPage());
  }
}
