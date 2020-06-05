import 'package:flutter/material.dart';
import 'package:rw334/models/group.dart';
import 'package:rw334/screens/home/creategroup.dart';
import 'package:rw334/service/httpService.dart' as http;

class GroupsPage extends StatefulWidget {
  
  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  
  Future<List<Group>> _allGroups = http.getAllGroups();

  void refresh() {
    setState(() {
      this._allGroups = http.getAllGroups();
    });
  }  

  @override
  Widget build(BuildContext context) {
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
              builder: (context) => GroupCreatorPage(
                refreshCallback: refresh,
              )
            )
          );
        }
      ),
      body: Container(
        color: Color.fromRGBO(41, 41, 41, 1.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder<List<Group>>(
          future: _allGroups,
          builder: (context, snapshot) {

            if (snapshot.connectionState != ConnectionState.done) {
              return Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              );
            }

            if (snapshot.hasData) {
              List<Group> groups = snapshot.data;
              return Container(
                padding: const EdgeInsets.all(6),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                      child: GroupCard(
                        group: groups[index],
                        refreshCallback: refresh,
                      ),
                    );
                  }
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
              )
            );
          },
        ),
      ),
    );
  }
}

class GroupCard extends StatefulWidget {
  
  final Group group;
  final VoidCallback refreshCallback;
  GroupCard({@required this.group, @required this.refreshCallback});

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  
  bool _userOwnsThisGroup() {
    return widget.group.createdBy == http.globalUsername;
  }

  bool _userIsInThisGroup() {
    return http.getGlobalGroups().contains(widget.group.name);
  }

  @override
  Widget build(BuildContext context) {

    void _joinSequence() async {
      print('Attempting to join \"${widget.group.name}\".');
      int statusCode = await http.joinGroup(widget.group.name);
      if (statusCode != 200)
        showDialog(
          context: context,
          child: AlertDialog(
            title: Text('Error:  $statusCode'),
          ),
        );
      else widget.refreshCallback();
    }

    void _deleteSequence() async {
      print('Attempting to delete \"${widget.group.name}\".');
      int statusCode = await http.deleteGroup(widget.group.name);
      if (statusCode != 204)
        showDialog(
          context: context,
          child: AlertDialog(
            title: Text('Error:  $statusCode'),
          ),
        );
      else widget.refreshCallback();
    }

    void _leaveSequence() async {
      print('Attempting to leave \"${widget.group.name}\".');
      int statusCode = await http.leaveGroup(widget.group.name);
      if (statusCode != 200)
        showDialog(
          context: context,
          child: AlertDialog(
            title: Text('Error:  $statusCode'),
          ),
        );
      else widget.refreshCallback();
    }

    void _performAppropriateSequence() {
      // if not in the group, join it
      if (!_userIsInThisGroup()) _joinSequence();
      // if owns, delete it
      else if (_userOwnsThisGroup()) _deleteSequence();
      // else leave it     
      else _leaveSequence();
    }

    String _appropriateButtonText() {
      // if not in the group, join it
      if (!_userIsInThisGroup()) return 'JOIN';
      // if owns, delete it
      if (_userOwnsThisGroup()) return 'DELETE';
      // else leave it
      return 'LEAVE';
    }

    var _titleStyle = TextStyle( color: Theme.of(context).accentColor, fontSize: 20 );
    var _subtitleStyle = TextStyle( color: Colors.white, fontSize: 18 );
    var _descStyle = TextStyle( color: Colors.white70, fontSize: 16 );
    var _expandedStyle = TextStyle( color: Colors.white70, fontSize: 14 );
    var _expandedStyleEmp = TextStyle( color: Theme.of(context).accentColor, fontSize: 16, fontWeight: FontWeight.bold );
    var _buttonStyle = TextStyle( color: Color.fromRGBO(30, 30, 30, 1.0), fontSize: 18, fontWeight: FontWeight.bold );

    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(30, 30, 30, 1.0),
        // borderRadius: BorderRadius.all(Radius.circular(4)),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).accentColor.withOpacity(_userOwnsThisGroup() ? 1.0 : 0.0),
            width: 3,
          ),
        ),
      ),
      child: ExpansionTile(
        // initiallyExpanded: true,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
          child: Text(
            widget.group.name,
            style: _titleStyle,
          ),
        ),
        subtitle: Text(
          widget.group.tag.trimRight().trimLeft().length > 0
              ? widget.group.tag
              : '(no tags)',
          style: _subtitleStyle,
        ),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // the description
                Text(
                  widget.group.description.trim().length > 0
                      ? widget.group.description
                      : '(No description)',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 10,
                  style: _descStyle,
                ),
                SizedBox(
                  height: 4,
                ),
                // the rest
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // metadata
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Created at',
                                style: _expandedStyle
                              ),
                              TextSpan(
                                text: ' ${widget.group.timeCreated}',
                                style: _expandedStyleEmp
                              ),
                            ] 
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'by',
                                style: _expandedStyle
                              ),
                              TextSpan(
                                text: ' ${widget.group.createdBy}',
                                style: _expandedStyleEmp
                              ),
                            ] 
                          ),
                        )
                      ],
                    ),
                    // button
                    FlatButton(
                      onPressed: () {
                        print('Tapped on the action button for \"${widget.group.name}\".');
                        _performAppropriateSequence();
                      },
                      color: Theme.of(context).accentColor,
                      child: Text(
                        _appropriateButtonText(),
                        style: _buttonStyle
                      )
                    ),
                  ],
                )
              ],
            )
          ),
        ],
      ),
    );
  }
}