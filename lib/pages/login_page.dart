import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:todo/components/login_form.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:nauta_api/nauta_api.dart';

import 'package:todo/pages/connected_page.dart';

import 'package:getflutter/getflutter.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title = 'NAUTA'}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  ProgressDialog pr;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);

    pr.style(
      borderRadius: 0.0,
      progressWidget: Container(
        padding: EdgeInsets.all(8.0),
        child: GFLoader(
          type: GFLoaderType.custom,
          loaderIconOne: Icon(
            Icons.developer_mode,
            size: 128,
          ),
          size: 32,
        ),
      ),
      messageTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 19.0,
      ),
    );

    reconnect();

    return Scaffold(
      key: _scaffoldKey,
      appBar: GFAppBar(
        iconTheme: IconThemeData(color: GFColors.SUCCESS),
        backgroundColor: GFColors.FOCUS,
        title: Text(
          widget.title,
          style: TextStyle(color: GFColors.SUCCESS),
        ),
        elevation: 0,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 100,
            color: GFColors.FOCUS,
            child: Center(
              child: Icon(
                Icons.wifi_lock,
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
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: LoginForm(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void reconnect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('nauta_username');

    try {
      if (await NautaProtocol.isConnected()) {
        pr.style(message: 'Reconectando');
        await pr.show();
        await pr.hide();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConnectedPage(
              title: 'Conectado',
              username: username,
            ),
          ),
        );
      } // end if isConnected
    } on NautaException catch (e) {
      await prefs.remove('nauta_username');
      await pr.hide();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.message,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ),
      );
    } // end try_catch
  } // end reconnect()
} // end _LoginPageState
