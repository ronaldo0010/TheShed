import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rw334/models/user.dart';
import 'package:rw334/service/httpService.dart';

class GroupCreatorPage extends StatefulWidget {
  
  final VoidCallback refreshCallback;
  GroupCreatorPage({@required this.refreshCallback});
  
  @override
  _GroupCreatorPageState createState() => _GroupCreatorPageState();
}

class _GroupCreatorPageState extends State<GroupCreatorPage> {
  
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  TextEditingController _tagController = new TextEditingController();

  @override
  Widget build(BuildContext context) {

    void _confirmSequence() async {
      print('Confirm button pressed');
      String name = _nameController.text.trim();
      String desc = _descriptionController.text.trim();
      String tag = _tagController.text.trim();
      if (name.length > 0 && desc.length > 0 && tag.length > 0) {
        int statusCode = await makeGroup(name, desc, tag);
        print(statusCode);
        if (statusCode == 201) {
          FocusScope.of(context).unfocus(); // to remove the keyboard
          Navigator.pop(context);
          widget.refreshCallback();
        } else {
          showDialog(
            context: context,
            child: AlertDialog(
              title: Text('Error:  $statusCode'),
            ),
          );
        }
      }
    }

    final _labelStyle = TextStyle(color: Colors.white, fontSize: 18);
    final _inputTextStyle = TextStyle(color: Colors.black, fontSize: 20.0);
    final _inputHintStyle = TextStyle(color: Colors.grey, fontSize: 20.0);
    final _metadataFieldStyle = TextStyle(color: Theme.of(context).accentColor, fontSize: 18, fontWeight: FontWeight.bold);
    final _metadataValueStyle = TextStyle(color: Colors.white, fontSize: 18);
    return Consumer<User>(builder: (context, user, child) {
      return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              'Creating Group',
            )),
        body: Container(
          padding: const EdgeInsets.all(8),
          color: Color.fromRGBO(41, 41, 41, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // group name
              Container(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: TextField(
                  maxLength: 30,
                  maxLengthEnforced: true,
                  // expands: true,
                  minLines: 1,
                  maxLines: 10,
                  style: _inputTextStyle,
                  controller: _nameController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Name',
                    hintStyle: _inputHintStyle,
                  ),
                ),
              ),
              BigSpacer(),

              // description
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
                  controller: _descriptionController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Description',
                    hintStyle: _inputHintStyle,
                  ),
                ),
              ),
              BigSpacer(),

              // tag
              Container(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: TextField(
                  maxLength: 30,
                  maxLengthEnforced: true,
                  // expands: true,
                  minLines: 1,
                  maxLines: 10,
                  style: _inputTextStyle,
                  controller: _tagController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Tag',
                    hintStyle: _inputHintStyle,
                  ),
                ),
              ),
              BigSpacer(),

              // metadata
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
                      'CREATE',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  onPressed: () async {
                    _confirmSequence();
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
