import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'package:todo/models/user.dart';
import 'package:todo/pages/connected_page.dart';

import 'package:nauta_api/nauta_api.dart';

import 'package:webview_flutter/webview_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();



  User _user = User();

  ProgressDialog pr;

  @override
  Widget build(BuildContext context) {

    pr = ProgressDialog(context, isDismissible: false);

    pr.style(
      borderRadius: 0.0,
      progressWidget: Container(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      ),
      messageTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 19.0,
      ),
    );

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              'Login Nauta',
              style: TextStyle(color: Colors.blue, fontSize: 20),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: TextFormField(
              autovalidate: true,
              decoration: InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: Icon(
                    Icons.alternate_email,
                    size: 28,
                  )),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Este campo no debe estar vacío';
                }

                return null;
              },
              enableSuggestions: true,
              keyboardType: TextInputType.emailAddress,
              onSaved: (val) => setState(() => _user.username = val),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: TextFormField(
              obscureText: true,
              autovalidate: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  size: 28,
                ),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Este campo no debe estar vacío';
                }

                return null;
              },
              keyboardType: TextInputType.emailAddress,
              onSaved: (val) => setState(() => _user.password = val),
            ),
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: MaterialButton(
                  color: Colors.blue,
                  minWidth: MediaQuery.of(context).size.width,
                  child: Text(
                    'Conectar',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: login,
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(2.0),
                child: MaterialButton(
                  color: Colors.lightBlue,
                  child: Text(
                    'Consultar crédito',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: credit,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(2.0),
                child: MaterialButton(
                  color: Colors.lightBlue,
                  child: Text(
                    'Portal Nauta',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: portalNauta,
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: MaterialButton(
              color: Colors.lightBlueAccent,
              minWidth: MediaQuery.of(context).size.width,
              child: Text(
                'Reconectar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: reconnect,
            ),
          ),
        ],
      ),
    );
  }

  void reconnect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('nauta_username');

    if(username != null && await NautaProtocol.isConnected()){
      pr.style(message: 'Reconectando');
      await pr.show();

      try {
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
      } on NautaException catch (e) {
        await prefs.remove('nauta_username');
        await pr.hide();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              e.message,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),
        );
      }
    }
    else{
      await prefs.remove('nauta_username');
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "No se ha podido recuperar la sesión",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  void login() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      if (!_user.username.contains('@')) {
        _user.username += '@nauta.com.cu';
      }

      var nautaClient =
          NautaClient(user: _user.username, password: _user.password);

      pr.style(message: 'Conectando');
      await pr.show();

      try {
        await nautaClient.login();

        await pr.hide();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConnectedPage(
              title: 'Conectado',
              username: _user.username,
            ),
          ),
        );
      } on NautaException catch (e) {
        await pr.hide();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              e.message,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),
        );
      }
    } // end if (form.validate())
  } // end login()

  void credit() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      if (!_user.username.contains('@')) {
        _user.username += '@nauta.com.cu';
      }

      var nautaClient =
          NautaClient(user: _user.username, password: _user.password);

      pr.style(message: 'Solicitando');
      await pr.show();

      try {
        final userCredit = await nautaClient.userCredit();

        await pr.hide();

        Scaffold.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 10),
          backgroundColor: Colors.blueAccent,
          content: Text(
            'Crédito: $userCredit',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
        ));
      } on NautaException catch (e) {
        await pr.hide();
        Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.message,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ));
      }
    } // end if (form.validate())
  } // end credit()

  void portalNauta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PortalNauta(),
      ),
    );
  }
}

class PortalNauta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Portal Nauta'),
        elevation: 0,
      ),
      body: WebView(
        initialUrl: "https://www.portal.nauta.cu",
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
