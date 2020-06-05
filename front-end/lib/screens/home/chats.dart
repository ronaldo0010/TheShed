import 'package:flutter/material.dart';
import 'package:rw334/screens/home/chatscreen.dart';
import 'package:rw334/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rw334/service/httpService.dart' as httpService;

class ChatsPage extends StatefulWidget {
  
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {

  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    int userID = httpService.userId;

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
          showDialog(
            context: context,
            child: AlertDialog(
              title: Text('Search for username'),
              content: TextField(
                decoration: InputDecoration(
                  hintText: 'Username'
                ),
                controller: _searchController,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Search'),
                  onPressed: () async {
                    String username = _searchController.text.trim();
                    print('Searching for \"$username\"');
                    int userID = await httpService.userID(username);
                    // if user was not found
                    if (userID == null) {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      showDialog(
                        context: context,
                        child: AlertDialog(
                          title: Text('Username \"$username\" not found.'),
                        )
                      );
                    }
                    // if user was found
                    else {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          thisUserID: httpService.userId,
                          // otherUserID: this._searchResults[index].id,
                          otherUserID: userID,
                          otherUsername: username
                        ),
                      ));
                    }
                  }
                )
              ],
            ),
          );
        },
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('messages').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(41, 41, 41, 1)
              ),
              child: Center(
                child: CircularProgressIndicator(),
                // child: Text('Loading...'),
              ),
            );
          }
          List<Message> allMessagesList = [];
          for (int i = 0; i < snapshot.data.documents.length; i++) {
            Message msg = Message.fromDocumentSnapshot(snapshot.data.documents[i]);
            if ([msg.senderId, msg.receiverId].contains(userID)) {
              allMessagesList.add(msg);
            }
          }
          allMessagesList.sort((a, b) => b.epochTime.compareTo(a.epochTime));
          return ConversationList(
            allMessagesList: allMessagesList,
          );
        }   
      ),
    );
  }
}

class ConversationList extends StatelessWidget {
  
  List<Message> allMessagesList = [];
  ConversationList({@required this.allMessagesList});

  int getOtherUserID(BuildContext context, Message msg) {
    List<int> idsInvolved = [msg.senderId, msg.receiverId];
    idsInvolved.remove(httpService.userId);
    return idsInvolved[0];
  }

  Map mapOtherUserToMessages(BuildContext context) {
    Map<int, List<Message>> map = {};
    for (int i = 0; i < allMessagesList.length; i++) {
      Message msg = allMessagesList[i];
      int otherId = getOtherUserID(context, msg);
      // if the sender id of message i is already listed, add it to that list
      if (!map.keys.contains(otherId)) {
        map[otherId] = [];
      }
      map[otherId].add(msg);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    
    var otherUserToMessagesMap = mapOtherUserToMessages(context);

    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(41, 41, 41, 1)
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(4),
        itemBuilder: (context, i) {
          if (i < otherUserToMessagesMap.keys.length) {
            int key = otherUserToMessagesMap.keys.toList()[i];
            List<Message> messagesList = otherUserToMessagesMap[key];
            return InkWell(
              // tapping opens the chat
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return ChatScreen(
                      otherUserID: key,
                    );
                  }
                ));
              },
              // build the chat row
              child: Conversation(
                lastMessage: messagesList[0],
              ),
            );
          } else {
            return null;
          }
        }
      ),
    );
  }
}

// displays the last message's text, time, and sender
class Conversation extends StatelessWidget {

  final Message lastMessage;  
  Conversation({@required this.lastMessage});

  int _getOtherID() {
    List<int> idsInvolved = [lastMessage.senderId, lastMessage.receiverId];
    idsInvolved.remove(httpService.userId);
    return idsInvolved[0];
  }

  @override
  Widget build(BuildContext context) {

    final debug = false;

    final _chatColor = Colors.white.withOpacity(0.0); // to allow tapping anywhere on the chat name

    final _senderStyle = TextStyle(fontSize: 16.0, color: Theme.of(context).accentColor);
    final _textStyle = const TextStyle(fontSize: 14.0, color: Colors.white);
    final _timeStyle = TextStyle(fontSize: 14.0, color: Theme.of(context).accentColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 4, top: 4),
      padding: const EdgeInsets.all(4),
      color: debug ? Colors.black : _chatColor,
      child: Row(
        children: [
          
          // avatar
          Container(
            margin:  const EdgeInsets.only(right: 10),
            width: 38,
            height: 36,
            color: debug ? Colors.blue : _chatColor,
            child: FutureBuilder<String> (
              future: httpService.getUsernameFromID(_getOtherID()),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  String imageURL = "https://ui-avatars.com/api/?name=${snapshot.data[0]}&background=0D8ABC&background=ff9900&bold=true&color=292929&font-size=0.6";
                  return CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(imageURL),
                  );
                }
                return Icon(
                  Icons.face,
                  color: Theme.of(context).accentColor,
                  size: 40,
                );
              },
            ),
          ),

          // username  --->  time
          // text
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 70,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        color: debug ? Colors.white : _chatColor,
                        child: FutureBuilder<String>(
                          future: httpService.getUsernameFromID(_getOtherID()),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState != ConnectionState.done) {
                              return Text(
                                'Loading...',
                                style: _senderStyle,
                              );
                            }
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data,
                                style: _senderStyle,
                              );
                            }
                            return Text(
                              'Error',
                              style: _senderStyle,
                            );
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 30,
                      child: Container(
                        alignment: Alignment.centerRight,
                        color: debug ? Colors.red : _chatColor,
                        child: Text(
                          lastMessage.getListTimeStamp(),
                          style: _timeStyle,
                        ),
                      )
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  alignment: Alignment.centerLeft,
                  color: debug ? Colors.purple : _chatColor,
                  child: Text(
                    lastMessage.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _textStyle,
                  ),
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}