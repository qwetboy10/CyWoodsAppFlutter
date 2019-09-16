import 'package:http/http.dart' as http;
import 'stateData.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'profile.dart';

//if you name the class login it causes compile errors
//just dont ask
class NotLogin extends StatefulWidget {
  State<NotLogin> createState() => NotLoginState();
}

class NotLoginState extends State<NotLogin> {
  TextEditingController usernameController;
  TextEditingController passwordController;
  Future<List<String>> login;
  //returns first name on success, null on failure

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      //always use safe area as parent widget so stuff doesnt get cut off by the notch
      body: SafeArea(
        child: FutureBuilder(
          future: login,
          builder: (BuildContext context, AsyncSnapshot<List<String>> login) {
            switch (login.connectionState) {
              case ConnectionState.none:
                //initializes future
                return buildLogin();
              case ConnectionState.active:
              case ConnectionState.waiting:
                //loading indicator
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                );
              case ConnectionState.done:
                if (login.data == null)
                  return Center(
                    child: Text('Unknown Error'),
                  );
                if (login.data[0] != null) {
                  Navigator.of(context).pop();
                  return Center(
                    child: Text(
                      'Welcome, ${login.data[0]}',
                      textScaleFactor: 1.5,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                } else
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Login Failed',
                            textScaleFactor: 1.5,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            login.data[1],
                            textScaleFactor: .8,
                            style: TextStyle(color: Colors.grey),
                          )
                        ],
                      ),
                    ),
                  );

              //done
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget buildLogin() {
    return Builder(builder: (BuildContext context) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              TextField(
                autocorrect: false,
                autofocus: true,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: 'Username',
                ),
                controller: usernameController,
              ),
              TextField(
                autocorrect: false,
                maxLines: 1,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
                controller: passwordController,
              ),
              Container(height: 8.0),
              RaisedButton(
                child: Center(child: Text('Login')),
                onPressed: () {
                  login = authenticate(
                      usernameController.text, passwordController.text);
                  //hides keyboard
                  FocusScope.of(context).requestFocus(new FocusNode());
                  //called after response from server
                },
              ),
            ],
          ),
        ),
      );
    });
  }

//returns name on success, null on failure
//also creates / saves profile on success
//also sets new profile as default
  Future<List<String>> authenticate(String username, String password) async {
    http.Response response = await http.post('${StateData.url}/Student', body: {
      "username": username,
      "password": password,
      "id": StateData.deviceID
    });
    try {
      if (response.statusCode == 200) {
        String data = response.body;
        Map<String, dynamic> json = jsonDecode(data);
        if (json.containsKey('success') && json['success'] == false) {
          //login failed
          StateData.logError("Login Failed: $data");
          if (json.containsKey('message'))
            return [null, json['message']];
          else
            return [null, null];
        } else {
          //creates profile
          Profile p = Profile.fromRemote(username, password, data);
          Profile.save(p);
          Profile.setDefaultProfile(p);
          p.updateParser();
          StateData.logInfo('Profile Created');
          return [p.getName(), null];
        }
      } else {
        StateData.logError('Login Failed: ${response.toString()}');
        try {
          String data = response.body;
          Map<String, dynamic> json = jsonDecode(data);
          if (json.containsKey('message'))
            return [null, json['message']];
          else
            return [null, null];
        } catch (e, t) {
          StateData.logError('Bad Response', error: e, trace: t);
          return [null, null];
        }
      }
      //if auth returns a non null value this should also create the profile
    } catch (e, t) {
      StateData.logError('Login Failed', error: e, trace: t);
      return [null,null];
    }
  }
}
