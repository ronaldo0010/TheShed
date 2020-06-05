import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rw334/models/post.dart';
import 'package:rw334/models/user.dart';
import 'package:provider/provider.dart';
import 'package:rw334/screens/home/postpage.dart';
import 'package:rw334/service/httpService.dart';
import 'drawer.dart';
import 'feed.dart';

class ProfilePage extends StatelessWidget {
//http request-get
//TODO: https://ui-avatars.com/api/?name=j&rounded=true&bold=true&color=fffff&background=a0a0a0
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Welcome",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      endDrawer: SettingsDrawer(),
      body: Container(
        color: Color.fromRGBO(41, 41, 41, 1),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ProfileWidget(),
      ),
    );
  }
}

class ProfileWidget extends StatefulWidget {
  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  String _theme = themeGen();
  Future<dynamic> _feedFuture = getAllUserPosts();

  @override
  Widget build(BuildContext context) {
    // String _url = "https://www.tinygraphs.com/labs/isogrids/hexa16/$globalUsername?theme=$_theme&numcolors=4&size=220&fmt=jpeg";
    // String _html = '<img src=\"$_url\">';
    // print(_html);
    String _url = "https://ui-avatars.com/api/?name=${globalUsername[0]}&background=0D8ABC&background=ff9900&bold=true&color=141414&font-size=0.6";

    return Consumer<User>(builder: (context, user, child) {
      return Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.only(left:6, top: 10, right: 6, bottom: 2),
            color: Color.fromRGBO(20, 20, 20, 1.0),
            //shadowColor: Colors.green,
            child: Container(
              margin: EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          // width: 300,
                          child: CircleAvatar(
                            radius: 30.0,
                            backgroundImage:
                            NetworkImage(_url),
                            backgroundColor: Colors.transparent,
                          )
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text(
                            (user.getUsername()).toUpperCase(),
                            // (globalUsername).toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).accentColor,
                              letterSpacing: 0.7,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          left: 40,
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 20.0),
                              child: Text(
                                user.getPost(),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 20.0),
                              //padding: EdgeInsets.only(left: 60),
                              child: Text(
                                "POSTS",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).accentColor,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              //padding: EdgeInsets.only(left: 25, top: 28),
                              child: Text(
                                user.getFollowing(),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                "FRIENDS",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).accentColor,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<List<Post>>(
            future: _feedFuture,
            builder: (context, snapshot) {
              // if data isn't here yet...
              if (snapshot.connectionState != ConnectionState.done)
                return Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                    // child: Text(
                    //   'Waiting for posts...',
                    //   style: TextStyle(fontSize: 20, color: Colors.white),
                    // ),
                  ),
                );

              // if the data is here
              if (snapshot.hasData) {
                List<Post> posts = snapshot.data;
                return Flexible(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        // padding: const EdgeInsets.all(6),
                        itemCount: posts.length,
                        itemBuilder: (context, i) {
                          return Container(
                            padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PostPage(
                                      post: posts[i],
                                    ),
                                  ),
                                );
                              },
                              child: PostCard(
                                post: posts[i],
                                lineLimit: 3,
                              ),
                            ),
                          );
                        }),
                  ),
                );
              }
              // dummy return
              return Expanded(
                child: Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 50,
                  )
                  // child: Text(
                  //   'Waiting for posts...',
                  //   style: TextStyle(fontSize: 20, color: Colors.white),
                  // ),
                ),
              );
            },
          ),
        ],
      );
    });
  }
}

String themeGen() {

  int sum = 0;
  for (int i = 0; i < globalUsername.length; i++) {
    sum +=  globalUsername.codeUnitAt(i);
  }
  var themes = ["frogideas", "sugarsweets", "heatwave","daisygarden",
    "seascape", "summerwarmth", "bythepool", "duskfalling", "berrypie", "base"];

  int len = themes.length;
  int choice = sum % len;

  return themes[choice];
}

