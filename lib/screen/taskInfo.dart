import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hr_mobile/screen/home.dart';
import 'package:hr_mobile/screen/login.dart';
import 'package:hr_mobile/network_utils/api.dart';
import 'package:hr_mobile/screen/profil.dart';
import 'package:scrolling_page_indicator/scrolling_page_indicator.dart';
import 'package:hr_mobile/screen/home.dart';
import 'package:hr_mobile/injection/notifications/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hr_mobile/model/task.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'listTaskCoplete.dart';
class TaskInfo extends StatefulWidget {
  Task task;
  TaskInfo(this.task);

 
  @override
  _TaskInfoState createState() => _TaskInfoState(this.task);
}

class _TaskInfoState extends State<TaskInfo>{
  String name;
  int coin;
  int id;
  int experience;
  Task listTask;
  String rank_title;
  String rank_description;  
  String title;
  String description;
  int userID;
  String userName;
  int typeValue;
  String typeValueName;
  PageController _controller;
  var _currentPage = 0;
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  DateTime selectedDate1 = DateTime.now().add(Duration(days: 1));
  bool _isLoading = false;
  var alluser=<String,int>{};
  List<String>alluserName=[];
  Task task;
  _TaskInfoState(this.task);
  @override
  void initState(){
    _controller = PageController();
    _loadUserData();
    super.initState();
  }
  _loadUserData() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user'));
    if(user != null) {
      setState(() {
        id = user['id'];
      });
      await _getuserinfo(id);

    }
  }
  _getuserinfo(id) async{
    var res = await Network().getData('/user/user_info/$id');
    var body = json.decode(res.body);
  
    //coin = body['coin'];
    //experience = body['experience'];
    if(body!= null) {
      setState(() {
        name = body[0]['name'];
        experience = body[0]['experience'];
        coin = body[0]['coin'];
        rank_title = body[0]['rank_title'];
        rank_description = body[0]['rank_description'];
      });
    }
  }
  
 

  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    @override
    Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Container(child:
            Row( children: <Widget>[
                Expanded(
                    child: Container(
                        child: Text(task.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30.0,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.bold,
                              )),)),  
          ])), 
            backgroundColor: Colors.blue[700],
          ),
          body:ListView(children:[Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Container(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.amber[100],
                elevation: 10,
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text('\n${task.dateStart} - ${task.dateEnd}\n',style: TextStyle(
                                fontSize: 20.0,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.bold,
                              )),
                    subtitle: Text('${task.description}\n\nОчки: ${task.point}\n\nПоставновщик:\n${task.userManager}\n\nОтветственный:\n$name\n',style: TextStyle(
                                fontSize: 20.0,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.bold,
                              )),
                  ),
                ]),
              ),
            ),
          Container(
              padding: const EdgeInsets.only(top:30,left:8,right:8),
              child: 
              new Form(key: _formKey, 
              child: new Column(
              children: <Widget>[
                new TextFormField(
                  initialValue: "Комментарий",
                  validator: (value){
                    setState(() {
                      title=value;
                    });
                }),
                   Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: FlatButton(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 8, bottom: 8, left: 10, right: 10),
                        child: Text(
                          _isLoading? 'Загрузка...' : 'Выполнить',  
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
                          _create();
                        }
                      },
                    ),
                  ),
                  
                ]))) 
            ])),
          ]),
          bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor:Colors.grey[600],
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.announcement),
              title: Text('Задачи')
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_box),
              title: Text('Выполненные')
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_sharp),
              title: Text('Профиль'),
            ),
          ],
          currentIndex: _currentPage,
          fixedColor: Colors.blue,
          onTap: (int intIndex) {
            setState(() {
              _currentPage = intIndex;
            });
            if(intIndex==0){
               Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>Home()));
            }
            if(intIndex==1){
               Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>ListTask()));
            }
            if(intIndex==2){
               Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>Profil()));
            }
          },       
        ));
      }
      void _create()async{
        setState(() {
          _isLoading = true;
        });
        
       /* var res = await Network().authData(data, '/task/add');
        var body = json.decode(res.body);
        try{
          if(body['message']=='Successfully!'){
             _showNotification(' ',"Задание успешно создано");
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => Home()
              ),
          );
          }
          else{
            _showNotification(body,"При сохранении прогресса произошла ошибка");
          }
        }catch(e){
          _showNotification(' ',"При сохранении прогресса произошла ошибка");
          print('Create Task!!!!!!!!!! $e');
        }
        */
        setState(() {
          _isLoading = false;
        });
        
      }

  Future<void> _showNotification(title, body) async {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              '12', 'hr_mobile', 'task_complete',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker');
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin
          .show(0, title, body, platformChannelSpecifics, payload: 'item x');
    }
}
