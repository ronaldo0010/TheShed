import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rw334/screens/home/groups.dart';
import 'feed.dart';
import 'profile.dart';
import 'chats.dart';
import 'package:provider/provider.dart';
import 'package:rw334/models/user.dart';

class Home extends StatelessWidget {
  Home({this.psw, this.onSignedOut});
  final VoidCallback onSignedOut;
  final psw;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => User(
        picture: 'assets/user1.jpeg',
        username: Hive.box('usr').get(0) ?? "none",
        password: this.psw
      ),
      child: MaterialApp(
        theme: ThemeData(
            accentColor: Color.fromRGBO(255, 153, 0, 1.0),
            // the color of the logo
            unselectedWidgetColor:
                Color.fromRGBO(255, 153, 0, 1.0) // the color of the logo
            ),
        home: UserHomePage(),
      ),
    );
  }
}

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _page = 1;
  PageController _pageController = PageController();
  Color backColor = Color.fromRGBO(41, 41, 41, 1);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 1,
      keepPage: true,
      viewportFraction: 1,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        buttonBackgroundColor: Theme.of(context).accentColor,
        backgroundColor: backColor,
        color: Colors.white,
        //Color.fromRGBO(128, 128, 128, 1),
        height: 60,
        animationDuration: Duration(milliseconds: 300),
        index: _page,
        animationCurve: Curves.fastLinearToSlowEaseIn,
        items: <Widget>[
          Icon( Icons.home, size: 30, color: Colors.black, ),
          Icon( Icons.people, size: 30, color: Colors.black, ),
          Icon( Icons.message, size: 30, color: Colors.black, ),
          Icon( Icons.person, size: 30, color: Colors.black, ),
        ],
        onTap: navigationTapped,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: [
          Container( color: backColor, child: FeedPage(), ),
          Container( color: backColor, child: GroupsPage(), ),
          Container( color: backColor, child: ChatsPage(), ),
          Container( color: backColor, child: ProfilePage(), )
        ],
      ),
    );
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    _pageController.jumpToPage(page);
  }
}
