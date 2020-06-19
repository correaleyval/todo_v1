import 'package:flutter/material.dart';
import 'package:getflutter/getflutter.dart';
import 'package:todo/components/connected_form.dart';

class ConnectedPage extends StatefulWidget {
  ConnectedPage({Key key, this.title = 'Conectado', this.username})
      : super(key: key);

  final String title;
  final String username;

  @override
  _ConnectedPageState createState() => _ConnectedPageState();
}

class _ConnectedPageState extends State<ConnectedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GFAppBar(
          centerTitle: true,
          iconTheme: IconThemeData(color: GFColors.SUCCESS),
          backgroundColor: GFColors.FOCUS,
          title: Text(
            widget.title.toUpperCase(),
            style: TextStyle(color: GFColors.SUCCESS),
          ),
          elevation: 0,
        ),
        body: ListView(
          children: <Widget>[
            Container(
              height: 80,
              color: GFColors.FOCUS,
              child: Center(
                child: Icon(
                  Icons.wifi,
                  size: 64,
                  color: GFColors.SUCCESS,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Center(
                  child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Card(
                        color: GFColors.FOCUS,
                        child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: ConnectedForm(
                              username: widget.username,
                            )),
                      ))),
            ),
          ],
        ));
  }
}
