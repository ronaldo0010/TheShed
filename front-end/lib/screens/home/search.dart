import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
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
      body: Container(
        color: Color.fromRGBO(41, 41, 41, 1),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          scrollDirection: Axis.vertical,
          children:[
            SearchBar(),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget { 

  final TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {

    final _inputTextStyle = TextStyle(color: Colors.black, fontSize: 16.0);
    final _inputHintStyle = TextStyle(color: Colors.grey);    

    return Container(
      // white rectangle
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 3),
            blurRadius: 1,
            color: Colors.black.withOpacity(0.2),
          )
        ]
      ),
      child: Container(
        padding: const EdgeInsets.all(4),

        // grey rounded
        child: Container(
          padding: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          
          // text
          child: TextField(
            style: _inputTextStyle,
            controller: controller,
            decoration: InputDecoration.collapsed(
              hintText: 'Search...',
              hintStyle: _inputHintStyle,
            ),
          ),
        ),
      ),
    );
  }
}