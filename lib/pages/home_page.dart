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
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(color: GFColors.SUCCESS),
        ),
        backgroundColor: GFColors.FOCUS,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: UssdRootWidget(),
      ),
    );
  }
}
