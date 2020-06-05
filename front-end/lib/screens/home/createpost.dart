import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rw334/models/user.dart';
import 'package:rw334/service/httpService.dart';

class PostCreatorPage extends StatefulWidget {
  
  final VoidCallback refreshCallback;
  PostCreatorPage({@required this.refreshCallback});
  
  @override
  _PostCreatorPageState createState() => _PostCreatorPageState();
}

class _PostCreatorPageState extends State<PostCreatorPage> {
  
  String _selectedGroup;

  Future<String> _locationName = getCurrentLocationName();
  TextEditingController textController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _style = TextStyle(fontSize: 20, color: Colors.black);
    final _labelStyle = TextStyle(color: Colors.white, fontSize: 18);
    final _metadataFieldStyle = TextStyle(color: Theme.of(context).accentColor, fontSize: 18, fontWeight: FontWeight.bold);
    final _metadataValueStyle = TextStyle(color: Colors.white, fontSize: 18);
    final _inputTextStyle = TextStyle(color: Colors.black, fontSize: 20.0);
    final _inputHintStyle = TextStyle(color: Colors.grey, fontSize: 20.0);
    return Consumer<User>(builder: (context, user, child) {
      return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              'Posting',
            )),
        body: Container(
          padding: const EdgeInsets.all(8),
          color: Color.fromRGBO(41, 41, 41, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // post body
              Container(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: TextField(
                  maxLength: 200,
                  maxLengthEnforced: true,
                  // expands: true,
                  minLines: 1,
                  maxLines: 10,
                  style: _inputTextStyle,
                  controller: textController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Body',
                    hintStyle: _inputHintStyle,
                  ),
                ),
              ),

              BigSpacer(),

              // group selection
              Text(
                'in group',
                style: _labelStyle,
              ),
              SmallSpacer(),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedGroup,
                  icon: null,
                  elevation: 8,
                  isDense: true,
                  style: _style,
                  items: getGlobalGroups().map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String newValue) {
                    print('\"$newValue\" has been selected as group');
                    setState(() {
                      this._selectedGroup = newValue;
                    });
                  },
                ),
              ),

              BigSpacer(),

              // metadata (such as location, time, etc)
              Text(
                'with metadata',
                style: _labelStyle,
              ),
              SmallSpacer(),
              Table(
                columnWidths: {
                  0: FractionColumnWidth(.35),
                  // 1: FractionColumnWidth(.7),
                },
                children: [
                  TableRow(children: [
                    Text('USERNAME', style: _metadataFieldStyle),
                    Text(user.getUsername(), style: _metadataValueStyle),
                  ]),
                  TableRow(children: [
                    Text('TIME', style: _metadataFieldStyle),
                    Text('${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}', style: _metadataValueStyle),
                  ]),
                  TableRow(children: [
                    Text('LOCATION', style: _metadataFieldStyle),
                    FutureBuilder<String>(
                      future: _locationName,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done)
                          return Text('Loading...', style: _metadataValueStyle);
                        if (snapshot.hasData)
                          return Text(snapshot.data, style: _metadataValueStyle);
                        return Text('ERROR', style: _metadataValueStyle);
                      },
                    ),
                  ]),
                ],
              ),

              BigSpacer(),

              // submit button
              Center(
                child: RaisedButton(
                  color: Theme.of(context).accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'POST',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  onPressed: () async {
                    String txt = textController.text;
                    user.updatePosts();
                    if (txt.trimRight().trimLeft().length > 1) {
                      makePost(txt, _selectedGroup);
                      Navigator.pop(context);
                      widget.refreshCallback();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class BigSpacer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 14);
  }
}

class SmallSpacer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 4);
  }
}
