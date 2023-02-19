import 'dart:convert';
import 'dart:convert' show json;

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:launch_review/launch_review.dart';
import 'update_profile.dart';
import 'data_local.dart';
import 'game_play.dart';
import 'objres.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;
import 'package:flutter/services.dart' show rootBundle;

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

enum SCR { LOGIN, LOGINED, REGISTER }

enum VERSION { CURRENT, FORCED_UPDATE, CAN_USE, NO_INTERNET }

class LoginState extends State<Login> {
  String refreshToken;
  String displayName;
  String username = "user", password = "", confirm = "";
  bool isShowPassword = false;
  SCR statusScreen = SCR.LOGIN;
  String message = "";
  bool buttonPressed = false;
  String urlButtonClicked = "button_click.mp3";
  AudioCache audioCache;
  bool isWaitingLogin = false;
  bool isWaitingProfile = false;
  bool isUpdateUI = false;
  VERSION checkVer = VERSION.NO_INTERNET;

  // Widget globals
  TextStyle textStyleForSignUp = TextStyle(
    color: Colors.white,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
  );
  TextStyle textStyleForSignUpLink = TextStyle(
    color: Colors.yellowAccent,
    fontSize: 17.0,
    fontWeight: FontWeight.normal,
  );
  TextStyle textStyleForMessage = TextStyle(
    fontSize: 14.0,
    color: Colors.white,
  );

  Future getInfoUser({String username, String token}) async {
    print("==> ${username} ${token}");
    if (username.length > 0 && token.length > 0) {
      String urlGetInfo = globals.linksso + "/user/getinfo";
      var header = {'x-access-token': token, 'language': globals.language};
      var response = await http.get(urlGetInfo, headers: header);
      print("status : ${response.statusCode} | body : '${response.body}'");
      if (response.statusCode == 200) {
        ObjRes objRes = ObjRes.fromJson(json.decode(response.body));
        if (objRes.success == true) {
          ObjGetInfo objGetInfo = ObjGetInfo.fromJson(objRes.data);
          globals.username = objGetInfo.username;
          globals.displayName = objGetInfo.displayName;
          globals.email = objGetInfo.email;
          globals.phonenumber = objGetInfo.phoneNumber;
          globals.changeDisplayName = objGetInfo.changeDisplayName;
          globals.linkAvatar = objGetInfo.linkAvatar;
          globals.score = objGetInfo.currentScore;
          globals.points = objGetInfo.points;
          globals.totalMatch = objGetInfo.totalMatch;
          globals.totalWin = objGetInfo.totalWin;
          globals.totalWinRank = objGetInfo.totalWinRank;
          globals.totalMatchRank = objGetInfo.totalMatchRank;
          globals.token = token;
          displayName = objGetInfo.displayName;
        }
      }
    }
  }

  Future getVersion() async {
    String urlGetInfo = globals.linksso + "/data/version";
    var response = await http.get(urlGetInfo);
    print("status : ${response.statusCode} | body : '${response.body}'");
    if (response.statusCode == 200) {
      ObjRes objRes = ObjRes.fromJson(json.decode(response.body));
      if (objRes.success == true) {
        ObjVersion version = ObjVersion.fromJson(json.decode(objRes.data));
        globals.iosId = version.iosId;
        globals.androidId = version.androidId;
        if (version.version <= globals.currentVersion) {
          print("CURRENT");
          setState(() {
            checkVer = VERSION.CURRENT;
          });
        } else if (version.version > globals.currentVersion) {
          if (globals.currentVersion >= version.minVersion &&
              version.forcedUpdate != 1) {
            print("CAN_USE");
            setState(() {
              checkVer = VERSION.CAN_USE;
            });
          } else {
            print("FORCED_UPDATE");
            setState(() {
              checkVer = VERSION.FORCED_UPDATE;
            });
          }
        }
      }
    }
  }

  soundButtonClick() {
    if (globals.isSound && audioCache != null) {
      audioCache.play(urlButtonClicked, mode: PlayerMode.LOW_LATENCY);
    }
  }

  void _loginButton() async {
    if (buttonPressed) {
      return;
    }
    soundButtonClick();
    buttonPressed = true;
    message = "";
    setState(() {
      isWaitingLogin = true;
    });
    if (username.length > 0 && password.length > 0) {
      print("login info : ${username} | ${password}");
      String urlLogin = globals.linksso + "/auth/login";
      Map body = {
        'username': username,
        'password': password,
        'language': globals.language
      };
      var response = await http.post(urlLogin,
          body: JsonEncoder().convert(body),
          headers: {'Content-Type': 'application/json'});
      print("status : ${response.statusCode} | body : '${response.body}'");
      if (response.statusCode == 200) {
        ObjRes objRes = ObjRes.fromJson(json.decode(response.body));
        if (objRes.success == true) {
          ObjLogin objLogin = ObjLogin.fromJson(objRes.data);
          await getInfoUser(username: username, token: objLogin.token);
          DataLocal dataLocal = new DataLocal(
              language: globals.language,
              token: objLogin.token,
              refreshToken: objLogin.refreshToken,
              username: username,
              displayName: displayName);
          await dataLocal.storeAccount();
          isUpdateUI = false;
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => new App()));
        } else {
          setState(() {
            message = objRes.message;
          });
          Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            fontSize: 16.0,
            textColor: Colors.red,
            backgroundColor: Colors.white,
          );
        }
      }
    } else if (username.length == 0 && password.length == 0) {
      setState(() {
        message = globals.getLocalization("scrLogin_login_failed");
      });
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
        textColor: Colors.red,
        backgroundColor: Colors.white,
      );
    } else {
      setState(() {
        message =
            globals.getLocalization("scrLogin_login_not_full_information");
      });
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
        textColor: Colors.red,
        backgroundColor: Colors.white,
      );
    }
    setState(() {
      isWaitingLogin = false;
    });
    buttonPressed = false;
  }

  void _loginScreenButton() {
    soundButtonClick();
    setState(() {
      statusScreen = SCR.LOGIN;
      message = "";
    });
  }

  resetMyInformation() async {
    DataLocal dataLocal = new DataLocal(
        language: globals.language,
        username: "",
        refreshToken: "",
        token: "",
        displayName: "");
    await dataLocal.storeAccount();
    globals.username = "";
    globals.token = "";
    username = "";
  }

  void _logoutButton() {
    soundButtonClick();
    resetMyInformation();
    setState(() {
      statusScreen = SCR.LOGIN;
      message = "";
    });
  }

  void _registerScreenButton() {
    soundButtonClick();
    setState(() {
      statusScreen = SCR.REGISTER;
      message = "";
    });
  }

  void _registerButton() async {
    soundButtonClick();
    message = "";
    if (username.length > 0 && password.length > 0) {
      setState(() {
        isWaitingLogin = true;
      });
      print("login register : ${username} | ${password} | ${confirm}");
      var urlRegister = globals.linksso + "/user";
      Map body = {
        'username': username,
        'password': password,
        'language': globals.language
      };
      var response = await http.post(urlRegister,
          body: JsonEncoder().convert(body),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        ObjRes objRes = ObjRes.fromJson(json.decode(response.body));
        if (objRes.success == true) {
          print(response.body);
          ///////////
          // login
          String urlLogin = globals.linksso + "/auth/login";
          var responseLogin = await http.post(urlLogin,
              body: JsonEncoder().convert(body),
              headers: {'Content-Type': 'application/json'});
          print(
              "status : ${responseLogin.statusCode} | body : '${responseLogin.body}'");
          if (responseLogin.statusCode == 200) {
            ObjRes objResLogin =
                ObjRes.fromJson(json.decode(responseLogin.body));
            if (objResLogin.success == true) {
              ObjLogin objLogin = ObjLogin.fromJson(objResLogin.data);
              await getInfoUser(username: username, token: objLogin.token);
              DataLocal dataLocal = new DataLocal(
                  language: globals.language,
                  token: objLogin.token,
                  refreshToken: objLogin.refreshToken,
                  username: username,
                  displayName: displayName);
              await dataLocal.storeAccount();
              isUpdateUI = false;
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => new App()));
            } else {
              setState(() {
                message = objResLogin.message;
              });
              Fluttertoast.showToast(
                msg: message,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                fontSize: 16.0,
                textColor: Colors.red,
                backgroundColor: Colors.white,
              );
            }
          }
          //////////
        } else {
          setState(() {
            message = objRes.message;
          });
          Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            fontSize: 16.0,
            textColor: Colors.red,
            backgroundColor: Colors.white,
          );
        }
      } else {
        setState(() {
          message = globals.getLocalization("scrLogin_register_failed");
        });
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
          textColor: Colors.red,
          backgroundColor: Colors.white,
        );
      }
      setState(() {
        isWaitingLogin = false;
      });
    } else {
      setState(() {
        message =
            globals.getLocalization("scrLogin_login_not_full_information");
      });
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
        textColor: Colors.red,
        backgroundColor: Colors.white,
      );
    }
  }

  _startButton() async {
    if (buttonPressed) {
      return;
    }
    message = "";
    soundButtonClick();
    setState(() {
      isWaitingLogin = true;
    });
    buttonPressed = true;
    var urlRelogin = globals.linksso + "/auth/relogin";
    var response = await http.post(urlRelogin, headers: {
      'x-access-token': refreshToken,
      'language': globals.language
    });
    if (response.statusCode == 200) {
      ObjRes objRes = ObjRes.fromJson(json.decode(response.body));
      if (objRes.success == true) {
        ObjLogin objLogin = ObjLogin.fromJson(objRes.data);
        await getInfoUser(username: username, token: objLogin.token);
        DataLocal dataLocal = new DataLocal(
            language: globals.language,
            token: objLogin.token,
            refreshToken: objLogin.refreshToken,
            username: username,
            displayName: displayName);
        refreshToken = objLogin.refreshToken;
        await dataLocal.storeAccount();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => new App()));
      } else {
        setState(() {
          message = objRes.message;
          statusScreen = SCR.LOGIN;
        });
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
          textColor: Colors.red,
          backgroundColor: Colors.white,
        );
      }
    }
    setState(() {
      isWaitingLogin = false;
    });
    buttonPressed = false;
  }

  _updateProfile() async {
    if (buttonPressed) {
      return;
    }
    soundButtonClick();
    setState(() {
      isWaitingProfile = true;
    });
    buttonPressed = true;
    var urlRelogin = globals.linksso + "/auth/relogin";
    var response = await http.post(urlRelogin, headers: {
      'x-access-token': refreshToken,
      'language': globals.language
    });
    if (response.statusCode == 200) {
      ObjRes objRes = ObjRes.fromJson(json.decode(response.body));
      if (objRes.success == true) {
        ObjLogin objLogin = ObjLogin.fromJson(objRes.data);
        await getInfoUser(username: username, token: objLogin.token);
        DataLocal dataLocal = new DataLocal(
            language: globals.language,
            token: objLogin.token,
            refreshToken: objLogin.refreshToken,
            username: username,
            displayName: displayName);
        refreshToken = objLogin.refreshToken;
        await dataLocal.storeAccount();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => new UpdateProfile()));
      } else {
        setState(() {
          message = objRes.message;
        });
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
          textColor: Colors.red,
          backgroundColor: Colors.white,
        );
      }
    }
    setState(() {
      isWaitingProfile = false;
    });
    buttonPressed = false;
  }

  getUILogin() {
    Widget widget;
    if (checkVer == VERSION.NO_INTERNET) {
      widget = new Container(
        height: MediaQuery.of(context).size.height * 0.65,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(),
        child: Center(
          child: Text(
            "",
//            globals.getLocalization("scrLogin_checkVersion_noInternet"),
            style: TextStyle(color: Colors.yellowAccent, fontSize: 20),
          ),
        ),
      );
    } else if (checkVer == VERSION.FORCED_UPDATE) {
      widget = new Container(
        height: MediaQuery.of(context).size.height * 0.65,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: Text(
                globals.getLocalization("scrLogin_checkVersion_forceUpdate"),
                style: TextStyle(color: Colors.yellowAccent, fontSize: 20),
              ),
            ),
            Container(
              decoration: BoxDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: GestureDetector(
                          onTap: () {
                            soundButtonClick();
                            LaunchReview.launch(
                                androidAppId: globals.androidId,
                                iOSAppId: globals.iosId);
                          },
                          child: Image.asset(
                              globals.getLocalization("BUTTON_UPDATE")),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (checkVer == VERSION.CAN_USE) {
      widget = new Container(
        height: MediaQuery.of(context).size.height * 0.65,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: Text(
                globals.getLocalization("scrLogin_checkVersion_canUse"),
                style: TextStyle(color: Colors.yellowAccent, fontSize: 20),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: GestureDetector(
                    onTap: () {
                      soundButtonClick();
                      setState(() {
                        checkVer = VERSION.CURRENT;
                      });
                    },
                    child:
                        Image.asset(globals.getLocalization("BUTTON_CANCEL")),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: GestureDetector(
                    onTap: () {
                      soundButtonClick();
                      LaunchReview.launch(
                          androidAppId: globals.androidId,
                          iOSAppId: globals.iosId);
                    },
                    child:
                        Image.asset(globals.getLocalization("BUTTON_UPDATE")),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      if (statusScreen == SCR.LOGIN) {
        // screen for login
        widget = new Container(
          height: MediaQuery.of(context).size.height * 0.65,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
//                color: Colors.amber,
              ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextField(
                      obscureText: false,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        hintText: globals.getLocalization("scrLogin_account"),
                        hintStyle:
                            TextStyle(fontSize: 20, color: Colors.grey[400]),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onChanged: (un) {
                        username = un;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextField(
                      obscureText: true,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.white,
                        ),
                        hintText: globals.getLocalization("scrLogin_password"),
                        hintStyle:
                            TextStyle(fontSize: 20, color: Colors.grey[400]),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onChanged: (pw) {
                        password = pw;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: GestureDetector(
                  onTap: _loginButton,
                  child: Image.asset(isWaitingLogin
                      ? globals.getLocalization("BUTTON_LOGIN_CLICKED")
                      : globals.getLocalization("BUTTON_LOGIN")),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                      child: Text(
                        "${message}",
                        textAlign: TextAlign.center,
                        style: textStyleForMessage,
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    ),
                    onTap: () {
                      soundButtonClick();
                      setState(() {
                        message = "";
                        globals.language =
                            ("EN".compareTo(globals.language) == 0
                                ? "VI"
                                : "EN");
                      });
                    },
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: GestureDetector(
                  onTap: _registerScreenButton,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          globals.getLocalization("scrLogin_button_signUp_1"),
                          style: textStyleForSignUp,
                        ),
                        Text(
                          globals.getLocalization("scrLogin_button_signUp_2"),
                          style: textStyleForSignUpLink,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (statusScreen == SCR.LOGINED) {
        // screen for logined
        widget = new Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      globals.getLocalization("scrLogin_logined_welcome_back"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "${username}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0,
                        color: Colors.yellowAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          print("Rate apps");
                          soundButtonClick();
                          LaunchReview.launch(
                                  androidAppId: globals.androidId,
                                  iOSAppId: globals.iosId);
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          child: SizedBox(
                            height: 25.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  globals.getLocalization("scrLogin_logined_rate"),
                                  style: TextStyle(
                                    fontFamily: 'Consolas',
                                    fontSize: 15.0,
                                    color: (isWaitingProfile
                                            ? Colors.grey[300]
                                            : Colors.white),
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Icon(
                                  Icons.stars,
                                  color: (isWaitingProfile
                                          ? Colors.grey[300]
                                          : Colors.white),
                                  size: 30.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          print("Update user information.");
                          _updateProfile();
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          child: SizedBox(
                            height: 25.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  globals.getLocalization(
                                          "scrLogin_logined_update_profile"),
                                  style: TextStyle(
                                    fontFamily: 'Consolas',
                                    fontSize: 15.0,
                                    color: (isWaitingProfile
                                            ? Colors.grey[300]
                                            : Colors.white),
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Icon(
                                  Icons.account_circle,
                                  color: (isWaitingProfile
                                          ? Colors.grey[300]
                                          : Colors.white),
                                  size: 30.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: GestureDetector(
                      onTap: () {
                        _logoutButton();
                      },
                      child:
                          Image.asset(globals.getLocalization("BUTTON_LOGOUT")),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: GestureDetector(
                      onTap: () {
                        _startButton();
                      },
                      child: Image.asset(isWaitingLogin
                          ? globals.getLocalization("BUTTON_START_CLICKED")
                          : globals.getLocalization("BUTTON_START")),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                      child: Text(
                        "${message}",
                        textAlign: TextAlign.center,
                        style: textStyleForMessage,
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    onTap: () {
                      soundButtonClick();
                      setState(() {
                        message = "";
                        globals.language =
                            ("EN".compareTo(globals.language) == 0
                                ? "VI"
                                : "EN");
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      } else {
        // Screen for register
        widget = new Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: TextField(
                  obscureText: false,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    prefixIcon: Icon(
                      Icons.person_add,
                      color: Colors.white,
                    ),
                    hintText: globals.getLocalization("scrLogin_account"),
                    hintStyle: TextStyle(fontSize: 20, color: Colors.grey[400]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  onChanged: (un) {
                    username = un;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: TextField(
                  obscureText: !isShowPassword,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.white,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        print("Show/Hide password");
                        FocusScope.of(context).requestFocus(new FocusNode());
                        setState(() {
                          isShowPassword = !isShowPassword;
                        });
                      },
                      child: Icon(
                        (isShowPassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        color: Colors.white,
                      ),
                    ),
                    hintText: globals.getLocalization("scrLogin_password"),
                    hintStyle: TextStyle(fontSize: 20, color: Colors.grey[400]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  onChanged: (pw) {
                    password = pw;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: GestureDetector(
                  onTap: _registerButton,
                  child: Image.asset(isWaitingLogin
                      ? globals.getLocalization("BUTTON_SIGNUP_CLICKED")
                      : globals.getLocalization("BUTTON_SIGNUP")),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                      child: Text(
                        "${message}",
                        textAlign: TextAlign.center,
                        style: textStyleForMessage,
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    onTap: () {
                      soundButtonClick();
                      setState(() {
                        message = "";
                        globals.language =
                            ("EN".compareTo(globals.language) == 0
                                ? "VI"
                                : "EN");
                      });
                    },
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: GestureDetector(
                  onTap: _loginScreenButton,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          globals.getLocalization("scrLogin_button_signIn_1"),
                          style: textStyleForSignUp,
                        ),
                        Text(
                            globals.getLocalization("scrLogin_button_signIn_2"),
                            style: textStyleForSignUpLink),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(),
      child: widget,
    );
  }

  _updateUI() async {
    print("Load Data");
    DataLocal dataLocal = new DataLocal();
    await dataLocal.loadAccount();
    print("username : ${dataLocal.username}");
    if (dataLocal.username != null && dataLocal.username.length > 0) {
      statusScreen = SCR.LOGINED;
      print("${dataLocal.refreshToken}");
      username = dataLocal.username;
      refreshToken = dataLocal.refreshToken;
    } else {
      statusScreen = SCR.LOGIN;
    }
  }

  Future _loadLanguage() async {
    String content = await rootBundle.loadString("assets/language.json");
    globals.languageValue = json.decode(content);
    print(globals.language);
  }

  // google sign in
//  GoogleSignInAccount _currentUser;
//  String _contactText;
//  GoogleSignIn _googleSignIn = GoogleSignIn(
//    scopes: <String>[
//      'email',
//      'https://www.googleapis.com/auth/contacts.readonly',
//    ],
//  );
//  Future<void> _handleGetContact() async {
//    setState(() {
//      _contactText = "Loading contact info...";
//    });
//    final http.Response response = await http.get(
//      'https://people.googleapis.com/v1/people/me/connections'
//          '?requestMask.includeField=person.names',
//      headers: await _currentUser.authHeaders,
//    );
//    if (response.statusCode != 200) {
//      setState(() {
//        _contactText = "People API gave a ${response.statusCode} "
//            "response. Check logs for details.";
//      });
//      print('People API ${response.statusCode} response: ${response.body}');
//      return;
//    }
//    final Map<String, dynamic> data = json.decode(response.body);
//    final String namedContact = _pickFirstNamedContact(data);
//    setState(() {
//      if (namedContact != null) {
//        _contactText = "I see you know $namedContact!";
//      } else {
//        _contactText = "No contacts to display.";
//      }
//    });
//  }
//
//  String _pickFirstNamedContact(Map<String, dynamic> data) {
//    final List<dynamic> connections = data['connections'];
//    final Map<String, dynamic> contact = connections?.firstWhere(
//          (dynamic contact) => contact['names'] != null,
//      orElse: () => null,
//    );
//    if (contact != null) {
//      final Map<String, dynamic> name = contact['names'].firstWhere(
//            (dynamic name) => name['displayName'] != null,
//        orElse: () => null,
//      );
//      if (name != null) {
//        return name['displayName'];
//      }
//    }
//    return null;
//  }
//
//  Future<void> _handleSignIn() async {
//    try {
//      if (_googleSignIn != null) {
//        print("Sign in");
//        await _googleSignIn.signIn();
//      } else {
//        print("_googleSignIn is null");
//      }
//    } catch (error) {
//      print(error);
//    }
//  }
//
//  Future<void> _handleSignOut() async {
//    _googleSignIn.disconnect();
//  }

  // Facebook sign in
//  static final FacebookLogin facebookSignIn = new FacebookLogin();
//  String _message = 'Log in/out by pressing the buttons below.';
//
//  Future<Null> _login() async {
//    final FacebookLoginResult result =
//    await facebookSignIn.logIn(['email']);
//
//    switch (result.status) {
//      case FacebookLoginStatus.loggedIn:
//        final FacebookAccessToken accessToken = result.accessToken;
//        _showMessage('''
//         Logged in!
//
//         Token: ${accessToken.token}
//         User id: ${accessToken.userId}
//         Expires: ${accessToken.expires}
//         Permissions: ${accessToken.permissions}
//         Declined permissions: ${accessToken.declinedPermissions}
//         ''');
//        break;
//      case FacebookLoginStatus.cancelledByUser:
//        _showMessage('Login cancelled by the user.');
//        break;
//      case FacebookLoginStatus.error:
//        _showMessage('Something went wrong with the login process.\n'
//            'Here\'s the error Facebook gave us: ${result.errorMessage}');
//        break;
//    }
//  }
//
//  Future<Null> _logOut() async {
//    await facebookSignIn.logOut();
//    _showMessage('Logged out.');
//  }
//
//  void _showMessage(String message) {
//    setState(() {
//      _message = message;
//    });
//  }

  @override
  void initState() {
//    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
//      setState(() {
//        _currentUser = account;
//      });
//      if (_currentUser != null) {
//        _handleGetContact();
//      }
//    });
//    _googleSignIn.signInSilently();
    _loadLanguage();
    audioCache = AudioCache();
    username = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    if (isUpdateUI == false) {
      isUpdateUI = true;
      _updateUI();
      getVersion();
    }
    return Material(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // logo
              Container(
                height: MediaQuery.of(context).size.height * 0.26,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Image.asset('assets/logo.png'),
                      ),
                    ),
                  ],
                ),
              ),
              // form login
              Stack(
                children: <Widget>[
                  getUILogin(),
//                getUIVersion(),
                ],
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
//                    Center(
//                      child: Text(
//                        "Phải nói rằng: \"Không có một trò chơi nào gần gũi với lứa tuổi học sinh hơn cờ caro\".\nĐúng vậy, trong môi trường giáo dục, đây là trò chơi rất lành mạnh, không mất tiền, các em lại được thư giãn.\nCờ caro thường được các bạn học sinh chơi vào lúc ra chơi nhưng cũng có bạn vì quá ham mê mà trong giờ học cũng lôi ra làm vài ván cho khuây khỏa để thoải mái đầu óc, tiếp thu bài nhanh hơn.Thế mới biết sức hấp dẫn của môn cờ này đến nhường nào. Cờ caro ở Việt Nam không quá phức tạp, tuy nhiên để trở thành một cao thủ thì người chơi cũng cần có những kỹ năng nhất định.",
//                        style: TextStyle(fontSize: 13.0, color: Colors.teal),
//                        textAlign: TextAlign.center,
//                      ),
//                    ),
                      Center(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  "––––––––––––––––––––––––––",
                                  style: TextStyle(
                                      fontSize: 13.0, color: Colors.white),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  globals
                                      .getLocalization("global_footer_text_1"),
                                  style: TextStyle(
                                      fontSize: 13.0, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  globals
                                      .getLocalization("global_footer_text_2"),
                                  style: TextStyle(
                                      fontSize: 13.0, color: Colors.yellow),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  globals
                                      .getLocalization("global_footer_text_3"),
                                  style: TextStyle(
                                      fontSize: 13.0, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  globals
                                      .getLocalization("global_footer_text_4"),
                                  style: TextStyle(
                                      fontSize: 13.0, color: Colors.yellow),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
