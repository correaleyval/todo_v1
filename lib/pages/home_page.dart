import 'package:flutter/material.dart';

import 'package:todo/pages/login_page.dart';

import 'package:todo/components/ussd_widget.dart';

import 'package:getflutter/getflutter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GFColors.FOCUS,
      floatingActionButton: FloatingActionButton(
        backgroundColor: GFColors.FOCUS,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(
                title: 'NAUTA',
              ),
            ),
          );
        },
        child: Icon(Icons.wifi, color: GFColors.SUCCESS),
      ),
      appBar: GFAppBar(
        elevation: 0.0,
        title: Text(
          widget.title,
          style: TextStyle(
            fontFamily: 'Monserrat',
            fontSize: 18.0,
            color: GFColors.SUCCESS,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 25.0),
          Container(
            height: 50,
            color: GFColors.FOCUS,
            child: Center(
              child:
                  Icon(Icons.developer_mode, size: 64, color: GFColors.SUCCESS),
            ),
          ),
          SizedBox(height: 40.0),
          Container(
            height: MediaQuery.of(context).size.height - 195.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(45.0),
                topRight: Radius.circular(45.0),
              ),
            ),
            child: UssdRootWidget(),
          ),
        ],
      ),
    );
  }
}
