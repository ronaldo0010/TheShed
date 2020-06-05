import 'package:flutter/material.dart';
import 'package:rw334/screens/wrapper.dart';
import 'package:rw334/service/constants.dart';
import 'service/router.dart' as router;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main () async {

  WidgetsFlutterBinding.ensureInitialized();

  final path = await getApplicationDocumentsDirectory();
  Hive.init(path.path);

  final passBox = await Hive.openBox('psw');
  final userBox = await Hive.openBox('usr');
  final stBox = await Hive.openBox('status');

  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        accentColor: Color.fromRGBO(255, 153, 0, 1.0),
      ),
      home: RootPage(),
      onGenerateRoute: router.generateRoute,
      initialRoute: HOME,
    );
  }
}