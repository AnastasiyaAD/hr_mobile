import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hr_mobile/screen/home.dart';
import 'package:hr_mobile/screen/login.dart';
import 'package:hr_mobile/network_utils/api.dart';
import 'package:scrolling_page_indicator/scrolling_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hr_mobile/model/task.dart';
import 'package:intl/intl.dart';
class TaskCreate extends StatefulWidget {
 
  @override
  _TaskCreateState createState() => _TaskCreateState();
}

class _TaskCreateState extends State<TaskCreate>{
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
  @override
  void initState(){
    _controller = PageController();
    _getuserinfoAll();
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
  _getuserinfoAll() async{
    var res = await Network().getData('/user/all');
    var body = json.decode(res.body);
  
    //coin = body['coin'];
    //experience = body['experience'];
    if(body!= null) {
      setState(() {
        for (var i = 0; i < body.length; i++) {
          alluser.addAll({body[i]['name']:body[i]['id']});
          alluserName.add(body[i]['name']);
        }
        print(alluser);
      });
    }
  }
    

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null || picked != selectedDate)
      if((picked.day==selectedDate1.day &&  picked.month==selectedDate1.month&&  picked.year==selectedDate1.year)||selectedDate1.isBefore(picked)){
        setState(() {
          Duration d =Duration(days: picked.compareTo(selectedDate1));
          selectedDate1=selectedDate1.add(d);
          selectedDate1=selectedDate1.add(Duration(days: 1));
        });
      }
      setState(() {
        selectedDate = picked;
      });
  }
  Future<void> _selectDate1(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate1,
        firstDate: selectedDate,
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate1 && picked!=selectedDate)
      setState(() {
        selectedDate1 = picked;
      });
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
                        child: Text('Добавить задачу',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30.0,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.bold,
                              )),)),  
          ])), 
            backgroundColor: Colors.blue[700],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: 
              new Form(key: _formKey, 
              child: new Column(
              children: <Widget>[
                new TextFormField(
                  initialValue: "Название",
                  validator: (value){
                  if (value.isEmpty || value=="Название") 
                  return 'Пожалуйста введите название';
                  else{
                    setState(() {
                      title=value;
                    });
                  }
                }),
                 new SizedBox(height: 20.0),
                new TextFormField(
                  initialValue: "Описание",
                  validator: (v){
                  if (v.isEmpty || v=="Описание") 
                  return 'Пожалуйста введите описание';
                  else{
                    setState(() {
                      description=v;
                    });
                  }
                }),
                 new SizedBox(height: 20.0),
                 new DropdownButton<String>(
                   hint:typeValueName!=null 
                   ?Text(typeValueName)
                   :Text('Пожалуйста выберите приоритет задачи'),
                    items: <String>['Высокий                                              ', 'Средний', 'Низкий'].map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value,style: TextStyle(fontSize: 16.0),),
                      );
                    }).toList(),
                    onChanged:(value) {
                      setState(() {
                      typeValueName=value;
                    });}
                  ),
                  new SizedBox(height: 20.0),
                  new DropdownButton<String>(
                    hint: userName!=null
                    ?Text(userName)
                    :Text('Пожалуйста выберите ответственного    '),
                    items: alluserName.map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value,style: TextStyle(fontSize: 16.0),),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                      userName=value;
                    });
                    },
                  ),
                  new SizedBox(height: 20.0),
                  new Row(children: [
                  Text("Дата начала:                  ${selectedDate.toLocal().day}/${selectedDate.toLocal().month}/${selectedDate.toLocal().year}                    "),
                  RaisedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Выбрать дату'),
                  ),]),
                  new SizedBox(height: 20.0),
                  new Row(children: 
                  [Text("Дата конца:                    ${selectedDate1.toLocal().day}/${selectedDate1.toLocal().month}/${selectedDate1.toLocal().year}                    "),
                  RaisedButton(
                    onPressed: () => _selectDate1(context),
                    child: Text('Выбрать дату'),
                  ),],),
                   Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 8, bottom: 8, left: 10, right: 10),
                        child: Text(
                          _isLoading? 'Загрузка...' : 'Сохранить',
                          
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
            ),
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
          },       
        ));
      }
      void _create()async{
        setState(() {
          _isLoading = true;
        });
        int priority;
        if(typeValueName=="Высокий"){
          setState(() {
            priority=1;
          });
        }
        if(typeValueName=="Средний"){
          setState(() {
            priority=2;
          });
        }
        if(typeValueName=="Низкий"){
          setState(() {
            priority=3;
          });
        }
        print(alluser[userName]);
        var data = {
          "title": title,
          "description": description,
          "date_start": dateFormat.format(selectedDate).toString(),
          "date_end": dateFormat.format(selectedDate1).toString(),
          "user_id": alluser[userName],
          "user_manager":name,
          "priority_id": priority
        };

        var res = await Network().authData(data, '/task/add');
        var body = json.decode(res.body);
        print(body);
        try{
          if(body['message']=='Successfully!'){
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => Home()
              ),
          );
          }
        }catch(e){
          print('Create Task!!!!!!!!!! $e');
        }
        setState(() {
          _isLoading = false;
        });
      }

  
}