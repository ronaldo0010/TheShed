import 'package:flutter/material.dart';
import 'package:rw334/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rw334/service/httpService.dart' as httpService;

class ChatScreen extends StatefulWidget {

  final int otherUserID;
  final int thisUserID;
  final String otherUsername;
  const ChatScreen({@required this.otherUserID, this.thisUserID, this.otherUsername});

  @override
  _ChatScreenState createState() => _ChatScreenState();

}

class _ChatScreenState extends State<ChatScreen> {

  int _otherUserID;
  final TextEditingController _inputController = new TextEditingController();
  final ScrollController _scrollController = new ScrollController();

  Future<String> _otherUserName;

  @override
  void initState() { 
    super.initState();
    this._otherUserID = widget.otherUserID;
    this._otherUserName = httpService.getUsernameFromID(this._otherUserID);
  }

  @override
  Widget build(BuildContext context) {

    int currentUserID;
    if (widget.thisUserID != null) {
      print('if was sufficient');
      currentUserID = widget.thisUserID;
    } else {
      print('had to go into else');
      currentUserID = httpService.userId;
    }

    int getOtherPersonId() {
      List<int> idsInvolved = [currentUserID, this._otherUserID];//[_messageList[0].senderId, _messageList[0].receiverId];
      idsInvolved.remove(currentUserID);
      return idsInvolved[0];
    }

    Message _generateMessage() => Message(
      text: this._inputController.value.text.trimRight().trimLeft(),
      senderId: currentUserID,
      receiverId: getOtherPersonId(),
      epochTime: (DateTime.now().millisecondsSinceEpoch/1000).floor()
    );

    void _pushMessageToFirestore(Message message) {
      Firestore.instance.collection('messages').add(message.toMap());
    }

    void _sendMessageSequence() {
      if (this._inputController.value.text.trimLeft().trimRight().length > 0) {
        _pushMessageToFirestore(_generateMessage());
        this._inputController.clear();
        this._scrollController.jumpTo(this._scrollController.position.maxScrollExtent);
      }      
    }

    final _inputTextStyle = TextStyle(color: Colors.black, fontSize: 16.0);
    final _inputHintStyle = TextStyle(color: Colors.grey);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String> (
          future: this._otherUserName,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Text(
                'Loading...',
              );
            }
            if (snapshot.hasData) {
              return Text(
                snapshot.data,
              );
            }
            return Text(
              'Other user',
            );
          },
        ),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[

              // the messages
              StreamBuilder(
                stream: Firestore.instance.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(41, 41, 41, 1)
                      ),
                      child: Center(
                        child: Text('Loading...'),
                      ),
                    );
                  }
                  List<Message> messagesInThisChat = [];
                  List<int> validIDs = [this._otherUserID, currentUserID];
                  for (int i = 0; i < snapshot.data.documents.length; i++) {
                    Message msg = Message.fromDocumentSnapshot(snapshot.data.documents[i]);
                    if (validIDs.contains(msg.senderId) && validIDs.contains(msg.receiverId)) {
                      messagesInThisChat.add(msg);
                    }
                  }
                  messagesInThisChat.sort((a, b) => -b.epochTime.compareTo(a.epochTime));
                  return Flexible(
                    child: Container(
                      color: Color.fromRGBO(41, 41, 41, 1),
                      child: ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemCount: messagesInThisChat.length,
                        controller: this._scrollController,
                        itemBuilder: (context, index) {
                          return MessageWidget(
                            message: messagesInThisChat[index],
                            me: currentUserID == messagesInThisChat[index].senderId,
                          );
                        },
                      ),
                    )
                  );
                }
              ),

              // the input widget
              Container(
                width: double.infinity,
                height: 70.0,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey,
                      width: 0.5
                    )
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, -3),
                      blurRadius: 1,
                      color: Colors.black.withOpacity(0.2),
                    )
                  ]
                ),
                child: Row(
                  children: <Widget>[

                    // emoji button
                    new Container(
                      margin: new EdgeInsets.symmetric(horizontal: 1.0),
                      child: new IconButton(
                        onPressed: () => print('Emoji pls'),
                        icon: new Icon(
                          Icons.face
                        ),
                        iconSize: 30,
                        color: Color.fromRGBO(255, 153, 0, 1.0),
                      ),
                    ),

                    // text input
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 2, 2, 2),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        child: TextField(
                          style: _inputTextStyle,
                          controller: this._inputController,
                          // expands: true,
                          minLines: 1,
                          maxLines: 5,
                          decoration: InputDecoration.collapsed(
                            hintText: 'Type a message...',
                            hintStyle: _inputHintStyle,
                          ),
                        ),
                      ),
                    ),

                    // send message button
                    Container(
                      margin: new EdgeInsets.symmetric(horizontal: 8.0),
                      child: new IconButton(
                        icon: new Icon(
                          Icons.send
                        ),
                        iconSize: 30,
                        onPressed: () {
                          _sendMessageSequence();
                        },
                        color: Color.fromRGBO(255, 153, 0, 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ]
      )
    );
  }

}

class MessageWidget extends StatelessWidget {

  final Message message;
  final bool me;
  MessageWidget({@required this.message, @required this.me});

  @override
  Widget build(BuildContext context) {

    final _messageStyle = const TextStyle(fontSize: 16.0);
    final _messageTimeStyle = const TextStyle(fontSize: 14.0, color: Color.fromRGBO(120, 120, 120, 1.0)); 
    
    // data to be displayed
    String text = this.message.text;
    String time = this.message.getInChatTimeStamp();

    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: me
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
        children: <Widget>[
          
          // the message text
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width*0.7
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              boxShadow: [
                BoxShadow(
                  offset: Offset(1, 1),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.3)
                ),
              ],
              color: me
              ? Colors.white
              : Color.fromRGBO(255, 153, 0, 1.0)
            ),
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text(
              text,
              style: _messageStyle,
            ),
          ),
          
          // the message time
          Container(
            padding: const EdgeInsets.only(top: 3, bottom: 4, left: 8, right: 8),
            child: Text(
              time,
              style: _messageTimeStyle,
            ),
          )
        ],
      ),
    );
  }
}