import 'dart:async';

import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'package:nauta_api/nauta_api.dart';
import 'package:todo/pages/login_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:getflutter/getflutter.dart';

class ConnectedForm extends StatefulWidget {
  final String username;

  ConnectedForm({this.username});

  @override
  _ConnectedFormState createState() => _ConnectedFormState();
}

class _ConnectedFormState extends State<ConnectedForm> {
  NautaClient nautaClient;
  ProgressDialog pr;
  get time => remaining.toString().split('.')[0];

  Duration remaining;
  Timer _timer;

  @override
  void initState() {
    super.initState();

    setState(() {
      nautaClient = NautaClient(user: widget.username, password: '');

      nautaClient.loadLastSession().then((value) => {
            nautaClient.remainingTime().then((value) {
              final rtime = value.split(':');
              final hour = rtime[0];
              final min = rtime[1];
              final sec = rtime[2];
              setState(() {
                remaining = Duration(
                    hours: int.parse(hour),
                    minutes: int.parse(min),
                    seconds: int.parse(sec));
              });
            })
          });
    });

    if (widget.username != null) startTime();
  }

  void startTime() {
    const oneSec = const Duration(seconds: 1);

    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (remaining.inSeconds < 1) {
            timer.cancel();
          } else {
            final newtime = remaining.inSeconds - 1;
            setState(() {
              remaining = Duration(seconds: newtime);
            });
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);

    pr.style(
      borderRadius: 0.0,
      progressWidget: Container(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(GFColors.FOCUS),
        ),
      ),
      messageTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 19.0,
      ),
    );

    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(4.0),
            child: Text(
              'Conectado',
              style: TextStyle(color: GFColors.SUCCESS, fontSize: 20),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Icon(
                Icons.network_wifi,
                size: 64,
                color: GFColors.SUCCESS,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              remaining == null ? '' : time,
              style: TextStyle(color: GFColors.WHITE, fontSize: 20),
            ),
          ),
          exitButton()
        ],
      ),
    );
  }

  Widget exitButton() {
    if (widget.username != null)
      return Padding(
        padding: EdgeInsets.all(10.0),
        child: GFButton(
          color: GFColors.SUCCESS,
          fullWidthButton: true,
          shape: GFButtonShape.pills,
          child: Text(
            'Salir',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () async {
            pr.style(message: 'Desconectando');
            await pr.show();

            try {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('nauta_username');
              await nautaClient.logout();

              _timer.cancel();
              await pr.hide();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(
                    title: 'NAUTA',
                  ),
                ),
              );
            } on NautaLogoutException catch (e) {
              await pr.hide();
              Scaffold.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  e.message,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ));
            }
          },
        ),
      );

    return Text('');
  }
}
