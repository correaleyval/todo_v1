import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:todo/services/contacts.dart';
import 'package:todo/services/phone.dart';
import 'package:todo/models/ussd_codes.dart';
import 'package:getflutter/getflutter.dart';

class UssdRootWidget extends StatefulWidget {
  _UssdRootState createState() => _UssdRootState();
}

class _UssdRootState extends State<UssdRootWidget> {
  List<UssdItem> items;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    final data = await rootBundle.loadString('config/ussd_codes.json');

    final parsedJson = jsonDecode(data);

    setState(() {
      items = UssdRoot.fromJson(parsedJson).items;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (items != null)
      return ListView.builder(
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == 0)
              return Container(
                height: 100,
                color: GFColors.FOCUS,
                child: Center(
                  child: Icon(Icons.developer_mode,
                      size: 64, color: GFColors.SUCCESS),
                ),
              );

            var item = items[index - 1];

            if (item.type == 'code')
              return UssdWidget(
                ussdCode: item,
              );
            else
              return UssdCategoryWidget(
                category: item,
              );
          });

    return Center(
      child: GFLoader(
        type: GFLoaderType.custom,
        loaderIconOne: Icon(
          Icons.developer_mode,
          size: 128,
        ),
        size: 100,
      ),
    );
  }
}

class UssdCategoryWidget extends StatelessWidget {
  final UssdCategory category;

  UssdCategoryWidget({this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UssdWidgets(
                title: category.name.toUpperCase(),
                ussdItems: category.items,
                icon: category.icon),
          ),
        );
      },
      child: Column(children: <Widget>[
        GFListTile(
          avatar: Icon(category.icon, color: GFColors.FOCUS),
          title: Text(
            category.name.toUpperCase(),
            style: TextStyle(color: GFColors.FOCUS),
          ),
        ),
        Divider(
          color: GFColors.FOCUS,
          thickness: 1.3,
        )
      ]),
    );
  }
}

class UssdWidgets extends StatelessWidget {
  final List<UssdItem> ussdItems;
  final String title;
  final IconData icon;

  UssdWidgets({this.ussdItems, this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GFAppBar(
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(color: GFColors.SUCCESS),
        ),
        backgroundColor: GFColors.FOCUS,
        iconTheme: IconThemeData(color: GFColors.SUCCESS),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
            itemCount: ussdItems.length + 1,
            itemBuilder: (context, index) {
              if (index == 0)
                return Container(
                  height: 100,
                  color: GFColors.FOCUS,
                  child: Icon(icon, size: 64, color: GFColors.SUCCESS),
                );

              var item = ussdItems[index - 1];

              if (item.type == 'code')
                return UssdWidget(
                  ussdCode: item,
                );
              else
                return UssdCategoryWidget(
                  category: item,
                );
            }),
      ),
    );
  }
}

class UssdWidget extends StatelessWidget {
  final UssdCode ussdCode;

  UssdWidget({this.ussdCode});

  @override
  Widget build(BuildContext context) {
    if (ussdCode.fields.isEmpty) {
      return SimpleCode(
        code: ussdCode.code,
        name: ussdCode.name,
        icon: ussdCode.icon,
      );
    }

    return CodeWithForm(code: ussdCode);
  }
}

class SimpleCode extends StatelessWidget {
  final String code;
  final String name;
  final IconData icon;

  SimpleCode({this.code, this.name, this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        callTo(code);
      },
      child: Column(children: <Widget>[
        GFListTile(
          avatar: Icon(icon, color: GFColors.FOCUS),
          title: Text(name.toUpperCase()),
        ),
        Divider(
          color: GFColors.FOCUS,
          thickness: 1.3,
        )
      ]),
    );
  }
}

class CodeWithForm extends StatelessWidget {
  final UssdCode code;

  CodeWithForm({this.code});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CodeFormPage(
              code: code,
            ),
          ),
        );
      },
      child: Column(children: <Widget>[
        GFListTile(
          avatar: Icon(code.icon, color: GFColors.FOCUS),
          title: Text(code.name.toUpperCase()),
        ),
        Divider(
          color: GFColors.FOCUS,
          thickness: 1.3,
        )
      ]),
    );
  }
}

class CodeFormPage extends StatelessWidget {
  final UssdCode code;

  CodeFormPage({this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GFAppBar(
        elevation: 0,
        title: Text(
          code.name.toUpperCase(),
          style: TextStyle(color: GFColors.SUCCESS),
        ),
        backgroundColor: GFColors.FOCUS,
        iconTheme: IconThemeData(color: GFColors.SUCCESS),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Center(
            child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Card(
                  child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CodeForm(
                        code: code.code,
                        fields: code.fields,
                        type: code.type,
                      )),
                ))),
      ),
    );
  }
}

class CodeForm extends StatefulWidget {
  final List<UssdCodeField> fields;
  final String code;
  final String type;

  CodeForm({this.code, this.fields, this.type});

  _CodeFormState createState() => _CodeFormState();
}

class _CodeFormState extends State<CodeForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController phoneNumberController = TextEditingController();

  String code;

  @override
  void initState() {
    super.initState();

    setState(() {
      code = widget.code;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView.builder(
        itemCount: widget.fields.length + 1,
        itemBuilder: (contex, index) {
          if (index == widget.fields.length) {
            return Padding(
              padding: EdgeInsets.all(10.0),
              child: GFButton(
                color: GFColors.FOCUS,
                shape: GFButtonShape.pills,
                child: Text(
                  'Aceptar',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  final form = _formKey.currentState;

                  if (widget.type == "debug") {
                    if (form.validate()) {
                      form.save();

                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('Run USSD Code\n$code'),
                      ));
                    }
                  } else {
                    if (form.validate()) {
                      form.save();
                      callTo(code);
                    }
                  }
                },
              ),
            );
          }

          final UssdCodeField field = widget.fields[index];

          switch (field.type) {
            // INPUT PHONE_NUMBER
            case 'phone_number':
              return TextFormField(
                controller: phoneNumberController,
                maxLength: 8,
                autovalidate: true,
                decoration: InputDecoration(
                    labelText: field.name.toUpperCase(),
                    suffixIcon: FlatButton(
                      onPressed: () async {
                        String number = await getContactPhoneNumber();

                        phoneNumberController.text = number;
                        phoneNumberController.addListener(() {
                          phoneNumberController.selection =
                              TextSelection(baseOffset: 8, extentOffset: 8);
                        });
                      },
                      child: Icon(
                        Icons.contacts,
                        color: GFColors.FOCUS,
                        size: 32,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.phone,
                      color: GFColors.FOCUS,
                    )),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Este campo no debe estar vacío';
                  }

                  if (value.length < 8) {
                    return 'Este campo debe contener 8 digitos';
                  }

                  if (value[0] != '5') {
                    return 'Este campo debe comenzar con el dígito 5';
                  }

                  return null;
                },
                keyboardType: TextInputType.phone,
                onSaved: (val) {
                  String rem = '{${field.name}}';

                  String newCode = code.replaceAll(rem, val);

                  setState(() {
                    code = newCode;
                  });
                },
              );

            // INPUT MONEY
            case 'money':
              return TextFormField(
                  autovalidate: true,
                  decoration: InputDecoration(
                      labelText: field.name.toUpperCase(),
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: GFColors.FOCUS,
                      )),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Este campo no debe estar vacío';
                    }

                    try {
                      if (int.parse(value) <= 0) {
                        return 'Debe poner una cantidad mayor que cero';
                      }
                    } catch (e) {
                      return 'Este campo solo puede conetener digitos';
                    }

                    return null;
                  },
                  keyboardType: TextInputType.number,
                  onSaved: (val) {
                    String rem = '{${field.name}}';

                    String newCode = code.replaceAll(rem, val);

                    setState(() {
                      code = newCode;
                    });
                  });

            // INPUT KEY
            case 'key_number':
              return TextFormField(
                obscureText: true,
                maxLength: 4,
                autovalidate: true,
                decoration: InputDecoration(
                    labelText: field.name.toUpperCase(),
                    prefixIcon: Icon(
                      Icons.vpn_key,
                      color: GFColors.FOCUS,
                    )),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Este campo no debe estar vacío';
                  }

                  if (value.length != 4) {
                    return 'La clave debe contener 4 dígitos';
                  }

                  return null;
                },
                keyboardType: TextInputType.number,
                onSaved: (val) {
                  String rem = '{${field.name}}';

                  String newCode = code.replaceAll(rem, val);

                  setState(() {
                    code = newCode;
                  });
                },
              );

            // INPUT CARD NUMBER
            case 'card_number':
              return TextFormField(
                maxLength: 16,
                autovalidate: true,
                decoration: InputDecoration(
                    labelText: field.name.toUpperCase(),
                    prefixIcon: Icon(
                      Icons.credit_card,
                    )),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Este campo no debe estar vacío';
                  }

                  if (value.length != 16) {
                    return 'El número de la tarjeta debe contener 16 dígitos';
                  }

                  return null;
                },
                keyboardType: TextInputType.number,
                onSaved: (val) {
                  String rem = '{${field.name}}';

                  String newCode = code.replaceAll(rem, val);

                  setState(() {
                    code = newCode;
                  });
                },
              );

            // DEFAULT ONLY FOR DEBUG
            default:
              return Text('Type of field ${field.type} unknown');
          }
        },
      ),
    );
  }
}
