import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hr_mobile/screen/login.dart';
import 'package:hr_mobile/network_utils/api.dart';
import 'package:scrolling_page_indicator/scrolling_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hr_mobile/model/task.dart';
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{
  String name;
  int coin;
  int id;
  int experience;
  String rank_title;
  String rank_description;
  PageController _controller;
  List<Task>listTaskNew;
  List<int>listTaskIDNew;

  List<Task>listTask;
  List<int>listTaskID;
  var _currentPage = 0;

  @override
  void initState(){
    _controller = PageController();
    listTaskNew=[];
    listTaskIDNew=[];
    listTask=[];
    listTaskID=[];
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
      await _getTask(id);
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
  _getTask(id)async{
    var res = await Network().getData('/task/tasks/$id');
    var body = json.decode(res.body);
    if(body!= null) {
      setState(() {
        for (var i = 0; i < body.length; i++) {
          if(listTaskIDNew==null || !listTaskID.contains(body[i]['id']) && body[i]['status_name']=='Новая задача'){
            listTaskIDNew.add(body[i]['id']);
            listTaskNew.add(new Task(
              body[i]['date_end'],
              body[i]['date_start'],
              body[i]['description'],
              body[i]['id'],
              body[i]['priority_experience_point'],
              body[i]['priority_name'],
              body[i]['status_name'],
              body[i]['title'],
              body[i]['user_id'],
              body[i]['user_manager']));
          }
          if(listTaskID==null || !listTaskID.contains(body[i]['id']) && body[i]['status_name']!='Новая задача'){
            listTaskID.add(body[i]['id']);
            listTask.add(new Task(
              body[i]['date_end'],
              body[i]['date_start'],
              body[i]['description'],
              body[i]['id'],
              body[i]['priority_experience_point'],
              body[i]['priority_name'],
              body[i]['status_name'],
              body[i]['title'],
              body[i]['user_id'],
              body[i]['user_manager']));
          }
        }
      
      });
    }
  }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Container(child:
            Row(textDirection: TextDirection.ltr, children: <Widget>[
                Expanded(
                    child: Container(
                        child: Text('Мои задачи',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30.0,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.bold,
                              )),)),
                Expanded(
                    child: Container(
                        child: 
                        RaisedButton(
                          onPressed: (){
                            logout();
                          },
                          color: Colors.grey[600],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          child: Text('Выйти',style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.0,
                                              decoration: TextDecoration.none,
                                              fontWeight: FontWeight.bold,
                                            ),),
                        ),))
                  
          ])), 
            backgroundColor: Colors.blue[700],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child:
                    new ListView.builder(
                    itemCount:listTaskNew!=null
                    ?listTaskNew.length
                    :0,
                    itemBuilder: (context, index) {
                      if(listTaskNew[index].priorityName=='Высокий'){
                        return  Container(
                          width: 200,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            color: Colors.red,
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.album, size: 70),
                                  title: Text(listTaskNew[index].title, style: TextStyle(color: Colors.white)),
                                  subtitle: Text(listTaskNew[index].description, style: TextStyle(color: Colors.white)),
                                ),
                                ButtonTheme.bar(
                                  child: ButtonBar(
                                    children: <Widget>[
                                      FlatButton(
                                        child: const Text('Выполнить', style: TextStyle(color: Colors.white)),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ) ; 
                      }
                      if(listTaskNew[index].priorityName=='Средний'){
                        return  Container(
                          width: 200,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            color: Colors.amber,
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.album, size: 70),
                                  title: Text(listTaskNew[index].title, style: TextStyle(color: Colors.white)),
                                  subtitle: Text(listTaskNew[index].description, style: TextStyle(color: Colors.white)),
                                ),
                                ButtonTheme.bar(
                                  child: ButtonBar(
                                    children: <Widget>[
                                      FlatButton(
                                        child: const Text('Выполнить', style: TextStyle(color: Colors.white)),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ) ;
                      }
                      if(listTaskNew[index].priorityName=='Низкий'){
                        return  Container(
                          width: 200,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            color: Colors.blue,
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.album, size: 70),
                                  title: Text(listTaskNew[index].title, style: TextStyle(color: Colors.white)),
                                  subtitle: Text(listTaskNew[index].description, style: TextStyle(color: Colors.white)),
                                ),
                                ButtonTheme.bar(
                                  child: ButtonBar(
                                    children: <Widget>[
                                      FlatButton(
                                        child: const Text('Выполнить', style: TextStyle(color: Colors.white)),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ) ;
                      }
                      return Container();
                    },
                  )
                  )
                ],
              ),
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

  void logout() async{
    var res = await Network().getData('/auth/logout');
    var body = json.decode(res.body);
    print(body);
    try{
      if(body!=null){
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.remove('user');
        localStorage.remove('token');
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context)=>Login()));
      }
    }catch(e){
      print(body);
      print('logout error !!!!! $e');
    }
    
  }
}