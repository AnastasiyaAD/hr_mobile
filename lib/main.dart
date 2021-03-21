import 'package:flutter/material.dart';
import 'package:hr_mobile/screen/login.dart';
import 'package:hr_mobile/screen/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hr_mobile/injection/notifications/notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main () async{
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          onDidReceiveLocalNotification:
              (int id, String title, String body, String payload) async {
            didReceiveLocalNotificationSubject.add(ReceivedNotification(
                id: id, title: title, body: body, payload: payload));
          });
  
  WidgetsFlutterBinding.ensureInitialized();
  const MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false);
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    selectedNotificationPayload = payload;
    selectNotificationSubject.add(payload);
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
   Widget build(BuildContext context) {
    return MaterialApp(
    title: 'Test App',
    debugShowCheckedModeBanner: false,
    home: CheckAuth(),
        );
      }

}

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;
  @override
  void initState() {
    _checkIfLoggedIn();
    super.initState();
  }

  void _checkIfLoggedIn() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if(token != null){
      setState(() {
 isAuth = true;
      });
    }
  }
  @override
   Widget build(BuildContext context) {
    Widget child;
    if (isAuth) {
    child = Home();
    } else {
    child = Login();
        }
        return Scaffold(
    body: child,
        );
      }
}