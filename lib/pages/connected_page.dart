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
        backgroundColor: GFColors.FOCUS,
        appBar: GFAppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: GFColors.SUCCESS),
          backgroundColor: Colors.transparent,
          title: Text(
            widget.title.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Monserrat',
              fontSize: 18.0,
              color: GFColors.SUCCESS,
            ),
          ),
          elevation: 0.0,
        ),
        body: ListView(
          children: <Widget>[
            SizedBox(height: 25.0),
            Container(
              height: 50,
              color: GFColors.FOCUS,
              child: Center(
                child: Icon(
                  Icons.wifi,
                  size: 64,
                  color: GFColors.SUCCESS,
                ),
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
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: GFColors.FOCUS,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(45.0),
                        topRight: Radius.circular(45.0),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: ConnectedForm(
                        username: widget.username,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
