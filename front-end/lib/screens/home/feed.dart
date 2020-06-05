import 'package:flutter/material.dart';
import 'package:rw334/models/post.dart';
import 'package:rw334/service/httpService.dart';
import 'postpage.dart';
import 'createpost.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  
  String sortingKey = 'Time';
  String sortingOrder = 'Asc';

  Future<List<Post>> _feedFuture = getUserFeed('Time', 'Asc');

  void sort() {
    print('Sorting in FeedWidget by $sortingKey, $sortingOrder');
    setState(() {
      this._feedFuture = getUserFeed(this.sortingKey, this.sortingOrder);
    });
  }

  void refresh() {
    setState(() {
      this._feedFuture = getUserFeed(this.sortingKey, this.sortingOrder);
    });
  }  
  
  @override
  Widget build(BuildContext context) {

    final TextStyle _style = TextStyle(fontSize: 16, color: Colors.black);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.asset(
          "assets/logo.png",
          width: 120,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // mini: true,
        child: Icon(
          Icons.add,
          size: 30,
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PostCreatorPage(
                refreshCallback: refresh,
              )
            )
          );
        },
      ),
      body: Container(
        color: Color.fromRGBO(41, 41, 41, 1),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                // the sorting bar
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 3),
                      blurRadius: 1,
                      color: Colors.black.withOpacity(0.2),
                    )
                  ]),
                  child: Row(
                    children: [
                      // the label
                      Text(
                        'Sort by...',
                        style: _style,
                      ),

                      // sort by time, group, user, etc
                      Container(
                        margin: const EdgeInsets.only(left: 12),
                        child: DropdownButton<String>(
                          value: sortingKey,
                          icon: null,
                          elevation: 8,
                          isDense: true,
                          style: _style,
                          items: <String>[
                            'Time',
                            'Location',
                            'User',
                            'Category'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String newValue) {
                            print('\"$newValue\" has been selected as sorting key');
                            setState(() {
                              sortingKey = newValue;
                            });
                          },
                        ),
                      ),

                      // sort ascending or descending
                      Container(
                        margin: const EdgeInsets.only(left: 12),
                        child: DropdownButton<String>(
                          value: sortingOrder,
                          icon: null,
                          elevation: 8,
                          isDense: true,
                          style: _style,
                          items: <String>['Asc', 'Desc'].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String newValue) {
                            print('\"$newValue\" has been selected as sorting order');
                            setState(() {
                              sortingOrder = newValue;
                            });
                          },
                        ),
                      ),

                      // confirm
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          width: 40,
                          child: OutlineButton(
                            splashColor: Theme.of(context).accentColor,
                            onPressed: () => sort(),
                            child: Text(
                              'Go',
                            )
                          ),
                        ),
                      )
                    ],
                  )
                ),

                // the feed
                FutureBuilder<List<Post>>(
                  future: _feedFuture,
                  builder: (context, snapshot) {
                    // if data isn't here yet...
                    if (snapshot.connectionState != ConnectionState.done)
                      return Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                    // if the data is here
                    if (snapshot.hasData) {
                      List<Post> posts = snapshot.data;
                      if (posts.length == 0)
                        return Expanded(
                          child: Center(
                            child: Text(
                              'No posts in your feed.\n\nJoin some groups!',
                              textAlign: TextAlign.center,
                              style: TextStyle( fontSize: 20, color: Colors.white ),
                            ),
                          ),
                        );
                      return Flexible(
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
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
                            }
                          ),
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
                      )
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;
  final int lineLimit;

  PostCard({@required this.post, @required this.lineLimit});

  @override
  _PostCardState createState() => _PostCardState();
}

// state
class _PostCardState extends State<PostCard> {
  
  // build method
  @override
  Widget build(BuildContext context) {
    TextStyle _styleHeaderEmphasis = TextStyle( color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, );
    TextStyle _styleHeaderNormal = TextStyle( color: Colors.white70, fontSize: 14, );
    TextStyle _styleTitle = TextStyle( color: Colors.white, fontSize: 20, );
    TextStyle _styleFooter = TextStyle( color: Colors.white70, fontSize: 16, );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color.fromRGBO(30, 30, 30, 1.0),
        // borderRadius: BorderRadius.only(topLeft: Radius.circular(4)),
        // To highlight the user's own posts
        border: Border(
          left: BorderSide(
            color: Theme.of(context).accentColor.withOpacity(widget.post.userId == userId ? 1.0 : 0.0),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // user in group
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.post.username,
                  style: _styleHeaderEmphasis.copyWith(
                      color: Theme.of(context).accentColor),
                ),
                TextSpan(text: ' in ', style: _styleHeaderNormal),
                TextSpan(
                  text: widget.post.groupname,
                  style: _styleHeaderEmphasis.copyWith(
                      color: Theme.of(context).accentColor),
                ),
              ],
            ),
          ),

          // spacing
          SizedBox(
            height: 4,
          ),

          // text
          Text(
            widget.post.text,
            maxLines: widget.lineLimit,
            overflow: TextOverflow.ellipsis,
            style: _styleTitle,
          ),

          // spacing
          SizedBox(
            height: 6,
          ),

          // plain white categories
          Text(
            widget.post.tag ?? '(no tag)',
            style: _styleFooter,
          )
        ],
      ),
    );
  }
}
