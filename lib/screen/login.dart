import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hr_mobile/injection/notifications/notifications.dart';
import 'package:hr_mobile/network_utils/api.dart';
import 'package:hr_mobile/screen/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hr_mobile/screen/register.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var email;
  var password;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  _showMsg(msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          // Some code to undo the change!
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
          color: Colors.blue[700],
          child: Stack(
            children: <Widget>[
              Positioned(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child:
                        Stack(
                            children: <Widget>[
                              // Stroked text as border.
                              Text(
                                'Компания-1',
                                style: TextStyle(
                                  fontSize: 50,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 6
                                    ..color = Colors.blue[800],
                                ),
                              ),
                              // Solid text as fill.
                              Text(
                                'Компания-1',
                                style: TextStyle(
                                  fontSize: 50,
                                  color: Colors.white,
                                ),
                              ),
                  
                            ],
                          )
                      ),
                      Card(
                        elevation: 4.0,
                        color: Colors.white,
                        margin: EdgeInsets.only(left: 20, right: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                TextFormField(
                                  style: TextStyle(color: Color(0xFF000000)),
                                  cursorColor: Color(0xFF9b9b9b),
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: Colors.grey,
                                    ),
                                    hintText: "Email",
                                    hintStyle: TextStyle(
                                        color: Color(0xFF9b9b9b),
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  validator: (emailValue) {
                                    if (emailValue.isEmpty) {
                                      return 'Please enter email';
                                    }
                                    email = emailValue;
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  style: TextStyle(color: Color(0xFF000000)),
                                  cursorColor: Color(0xFF9b9b9b),
                                  keyboardType: TextInputType.text,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.vpn_key,
                                      color: Colors.grey,
                                    ),
                                    hintText: "Password",
                                    hintStyle: TextStyle(
                                        color: Color(0xFF9b9b9b),
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  validator: (passwordValue) {
                                    if (passwordValue.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    password = passwordValue;
                                    return null;
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: FlatButton(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 8, bottom: 8, left: 10, right: 10),
                                      child: Text(
                                        _isLoading? 'Загрузка...' : 'Войти',
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.0,
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    color: Colors.green,
                                    disabledColor: Colors.grey,
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                        new BorderRadius.circular(20.0)),
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        _login();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      /*Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => Register()));
                          },
                          child: Text(
                            'Create new Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),*/
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
    );
  }
  void _login() async{
    setState(() {
      _isLoading = true;
    });
    var data = {
      'email' : email,
      'password' : password
    };
    Future<void> _showNotification(title, body) async {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              'your channel id', 'your MStroy', 'your channel description',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker');
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin
          .show(0, title, body, platformChannelSpecifics, payload: 'item x');
    }
    var res = await Network().authData(data, '/auth/login');
    var body = json.decode(res.body);
    print("ALL");
    print(body['access_token']);
    try{
      if(body['access_token']!=null){
        print("ALL USER INFO start");
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('token', json.encode(body));
        print("token");
        var res2 = await Network().getData('/auth/info');
        var body2 = json.decode(res2.body);
        print("ALL USER INFO");
        print(body2.toString());
        if(body2['id']!=null){
          localStorage.setString('user', json.encode(body2));
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => Home()
              ),
          );
        }
        else{
          _showNotification(body2.toString(),"Ошибка при получении данных о пользователе");
        }
        
      }else{
        _showNotification(body.toString(),"Ошибка при авторизации");
      }
    }catch(e){
      _showNotification(body.toString(),
                "Ошибка при авторизации body['access_token']==null");
      print('auth error !!! $e');
    }
    

    setState(() {
      _isLoading = false;
    });
    
  }
}