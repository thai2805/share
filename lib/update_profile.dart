import 'dart:convert';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'objres.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;
import 'gp_userInfo.dart' as gp;

class UpdateProfile extends StatefulWidget {
  @override
  UpdateProfileState createState() {
    return UpdateProfileState();
  }
}

enum Type { NONE, AVATAR, DISPLAY_NAME, PHONE_NUMBER, EMAIL }

class UpdateProfileState extends State<UpdateProfile> {
  String linkAvatar = globals.linkAvatar;
  String displayName = globals.displayName;
  String email = globals.email;
  String phoneNumber = globals.phonenumber;
  String displayNameTmp = globals.displayName;
  String emailTmp = globals.email;
  String phoneNumberTmp = globals.phonenumber;
  Type type;
  AudioCache audioCache;
  String urlButtonClicked = "button_click.mp3";
  bool isUpdated = false;
  bool isClickedUpdate = false;

  Future getInfoUser({String username, String token}) async {
    print("==> ${username} ${token}");
    if (username.length > 0 && token.length > 0) {
      String urlGetInfo = globals.linksso + "/user/getinfo";
      var header = {
        'x-access-token': token,
        'language': globals.language
      };
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
          globals.linkAvatar = objGetInfo.linkAvatar;
          globals.score = objGetInfo.currentScore;
          globals.points = objGetInfo.points;
          globals.totalMatch = objGetInfo.totalMatch;
          globals.totalWin = objGetInfo.totalWin;
          globals.totalWinRank = objGetInfo.totalWinRank;
          globals.totalMatchRank = objGetInfo.totalMatchRank;
        }
      }
    }
  }

  Future updateInformation(
      {String token,
      String linkAvatar,
      String displayName,
      String email,
      String phoneNumber}) async {
    if (isClickedUpdate == true) {
      return;
    }
    isClickedUpdate = true;
    String urlUpdateInfo = globals.linksso + "/user";
    var header = {'x-access-token': token, 'Content-Type': 'application/json'};
    Map body = {
      'linkAvatar': linkAvatar,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'language': globals.language
    };
    var response = await http.put(urlUpdateInfo,
        headers: header, body: JsonEncoder().convert(body));
    print(
        "status : ${response.statusCode} | body : '${response.body}' | json req.body : ${JsonEncoder().convert(body)}");
    if (response.statusCode == 200) {
      ObjRes objRes = ObjRes.fromJson(json.decode(response.body));
      if (objRes.success == true) {
        Fluttertoast.showToast(
          msg: "${objRes.message}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
          backgroundColor: Colors.white,
          textColor: Colors.teal,
        );
        Navigator.of(context).pop();
      } else {
        Fluttertoast.showToast(
          msg: "${objRes.message}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
          backgroundColor: Colors.white,
          textColor: Colors.teal,
        );
      }
    }
    isClickedUpdate = false;
  }

  _formProfile(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 0.7;
    double width = MediaQuery.of(context).size.width;
    double widthOfTitle = width * 0.4;
    TextStyle textStyleForTitle = TextStyle(
      color: Colors.white,
      fontSize: 15.0,
    );
    TextStyle textStyleForAccount = TextStyle(
      color: Colors.white,
      fontSize: 17.0,
      fontWeight: FontWeight.bold
    );
    TextStyle textStyleForEdit = TextStyle(
      color: Colors.yellow,
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    );
    TextStyle textStyleForShow = TextStyle(
      color: Colors.white,
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    );
    return new Stack(
      children: <Widget>[
        Container(
          height: height,
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
          decoration: BoxDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      print("Edit Avatar");
                      soundButtonClick();
                      setState(() {
                        if (type == Type.AVATAR) {
                          type = Type.NONE;
                        } else {
                          type = Type.AVATAR;
                        }
                      });
                    },
                    child: Container(
                      height: height * 0.2,
                      child: Stack(
                        children: <Widget>[
                          Image.asset("assets/${linkAvatar}"),
                          Positioned(
                            right: 5.0,
                            bottom: 5.0,
                            child: Icon(
                              Icons.edit,
                              color: Colors.yellowAccent,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "${globals.username}",
                        style: textStyleForAccount,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    child: Text(
                    globals.getLocalization("scrProfile_display_name"), style: textStyleForTitle,),
                    width: widthOfTitle,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "${displayName}",
                        style: textStyleForEdit,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("Edit display name");
                      soundButtonClick();
                      setState(() {
                        if (type == Type.DISPLAY_NAME) {
                          type = Type.NONE;
                        } else {
                          type = Type.DISPLAY_NAME;
                        }
                      });
                    },
                    child: Icon(
                      Icons.edit,
                      color: Colors.yellowAccent,
                      size: 20,
                    ),
                  ),
                ],
              ),
              /*Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    child: Text(globals.getLocalization("scrProfile_email"), style: textStyleForTitle,),
                    width: widthOfTitle,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "${email ?? ''}",
                        style: textStyleForEdit,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("Edit email");
                      soundButtonClick();
                      setState(() {
                        if (type == Type.EMAIL) {
                          type = Type.NONE;
                        } else {
                          type = Type.EMAIL;
                        }
                      });
                    },
                    child: Icon(
                      Icons.edit,
                      color: Colors.yellowAccent,
                      size: 20,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    child: Text(globals.getLocalization("scrProfile_phone_number"), style: textStyleForTitle,),
                    width: widthOfTitle,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "${phoneNumber ?? ''}",
                        style: textStyleForEdit,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("Edit phone number");
                      soundButtonClick();
                      setState(() {
                        if (type == Type.PHONE_NUMBER) {
                          type = Type.NONE;
                        } else {
                          type = Type.PHONE_NUMBER;
                        }
                      });
                    },
                    child: Icon(
                      Icons.edit,
                      color: Colors.yellowAccent,
                      size: 20,
                    ),
                  ),
                ],
              ),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    child: Text(globals.getLocalization("scrProfile_rename_card"), style: textStyleForTitle,),
                    width: widthOfTitle,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "${globals.changeDisplayName}",
                        style: textStyleForShow,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.edit,
                    color: Colors.teal,
                    size: 20,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    child: Text(globals.getLocalization("scrProfile_total_match"), style: textStyleForTitle,),
                    width: widthOfTitle,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "${globals.totalMatch}",
                        style: textStyleForShow,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.edit,
                    color: Colors.teal,
                    size: 20,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    child: Text(globals.getLocalization("scrProfile_pc_win"), style: textStyleForTitle,),
                    width: widthOfTitle,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "${globals.totalMatch > 0 ? (100 * globals.totalWin / globals.totalMatch).round() : 0}%",
                        style: textStyleForShow,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.edit,
                    color: Colors.teal,
                    size: 20,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    child: Text(globals.getLocalization("scrProfile_total_match_in_rank"), style: textStyleForTitle,),
                    width: widthOfTitle,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "${globals.totalMatchRank}",
                        style: textStyleForShow,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.edit,
                    color: Colors.teal,
                    size: 20,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    child: Text(globals.getLocalization("scrProfile_pc_win_in_rank"), style: textStyleForTitle,),
                    width: widthOfTitle,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "${globals.totalMatchRank > 0 ? (100 * globals.totalWinRank / globals.totalMatchRank).round() : 0}%",
                        style: textStyleForShow,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.edit,
                    color: Colors.teal,
                    size: 20,
                  ),
                ],
              ),
              Container(
                height: height * 0.2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          gp.GamePart().getRankLevel4Profile(globals.score),
                    ),
                    Image.asset(gp.GamePart().getImgRank(globals.score)),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: GestureDetector(
                      onTap: () {
                        print("Cancel");
                        soundButtonClick();
                        Navigator.of(context).pop();
                      },
                      child: Image.asset(globals.getLocalization("BUTTON_CANCEL")),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: GestureDetector(
                      onTap: () {
                        print("Update");
                        soundButtonClick();
                        updateInformation(
                            token: globals.token,
                            linkAvatar: linkAvatar,
                            displayName: displayName,
                            email: email,
                            phoneNumber: phoneNumber);
                      },
                      child: Image.asset(globals.getLocalization("BUTTON_UPDATE")),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _popupUpdate(type, context),
      ],
    );
  }

  showAllAvatar() {
    int numOfAvatar = 42;
    List<Widget> list = new List<Widget>();
    for (int i = 1; i <= numOfAvatar; i++) {
      list.add(
        new GestureDetector(
            onTap: () {
              print("Tap id : $i");
              soundButtonClick();
              setState(() {
                linkAvatar = "img_avatar_${i}.png";
                type = Type.NONE;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(0.0),
              decoration: BoxDecoration(),
              child: Image.asset("assets/img_avatar_${i}.png"),
            )),
      );
    }
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: list,
    );
  }

  showEditDisplayName() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TextField(
            obscureText: false,
            autocorrect: false,
            autofocus: true,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.text,
            style: TextStyle(
              fontSize: 15,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '${displayName}',

            ),
            onChanged: (pw) {
              displayNameTmp = pw;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Material(
                elevation: 5.0,
                color: Colors.teal,
                child: MaterialButton(
                  onPressed: () {
                    print("Cancel for displayname");
                    soundButtonClick();
                    setState(() {
                      displayNameTmp = displayName;
                      type = Type.NONE;
                    });
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6 * 0.3,
                    child: Text(
                      globals.getLocalization("BUTTON_TEXT_CANCEL"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Consolas',
                          fontSize: 15.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Material(
                elevation: 5.0,
                color: Colors.teal,
                child: MaterialButton(
                  onPressed: () {
                    print("Update for displayname");
                    soundButtonClick();
                    setState(() {
                      if (displayNameTmp != null && displayNameTmp.length > 0) {
                        if (displayNameTmp.length > 18) {
                          displayNameTmp = displayNameTmp.substring(0, 18);
                        }
                        displayName = displayNameTmp;
                      }
                      type = Type.NONE;
                    });
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6 * 0.3,
                    child: Text(
                      globals.getLocalization("BUTTON_TEXT_OK"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Consolas',
                          fontSize: 15.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  showEditEmail() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TextField(
            obscureText: false,
            autocorrect: false,
            autofocus: true,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              fontSize: 15,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '${email ?? ""}',
            ),
            onChanged: (pw) {
              emailTmp = pw;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Material(
                elevation: 5.0,
                color: Colors.teal,
                child: MaterialButton(
                  onPressed: () {
                    print("Cancel for email");
                    soundButtonClick();
                    setState(() {
                      emailTmp = email;
                      type = Type.NONE;
                    });
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6 * 0.3,
                    child: Text(
                      globals.getLocalization("BUTTON_TEXT_CANCEL"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Consolas',
                          fontSize: 15.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Material(
                elevation: 5.0,
                color: Colors.teal,
                child: MaterialButton(
                  onPressed: () {
                    print("Update for email");
                    soundButtonClick();
                    setState(() {
                      if (emailTmp != null && emailTmp.length > 0) {
                        RegExp regExp =
                            RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                        if (regExp.hasMatch(emailTmp)) {
                          email = emailTmp;
                        } else {
                          Fluttertoast.showToast(
                            msg: globals.getLocalization("scrProfile_email_invalid"),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            fontSize: 16.0,
                            backgroundColor: Colors.white,
                            textColor: Colors.teal,
                          );
                        }
                      }
                      type = Type.NONE;
                    });
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6 * 0.3,
                    child: Text(
                      globals.getLocalization("BUTTON_TEXT_OK"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Consolas',
                          fontSize: 15.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  showEditPhoneNumber() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TextField(
            obscureText: false,
            autocorrect: false,
            autofocus: true,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.phone,
            style: TextStyle(
              fontSize: 15,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '${phoneNumber ?? ""}',
            ),
            onChanged: (pw) {
              phoneNumberTmp = pw;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Material(
                elevation: 5.0,
                color: Colors.teal,
                child: MaterialButton(
                  onPressed: () {
                    print("Cancel for phone number");
                    soundButtonClick();
                    setState(() {
                      phoneNumberTmp = phoneNumber;
                      type = Type.NONE;
                    });
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6 * 0.3,
                    child: Text(
                      globals.getLocalization("BUTTON_TEXT_CANCEL"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Consolas',
                          fontSize: 15.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Material(
                elevation: 5.0,
                color: Colors.teal,
                child: MaterialButton(
                  onPressed: () {
                    print("Update for phone number");
                    soundButtonClick();
                    setState(() {
                      if (phoneNumberTmp != null && phoneNumberTmp.length > 0) {
                        RegExp regExp = RegExp(r'^[0-9]+$');
                        if (regExp.hasMatch(phoneNumberTmp)) {
                          phoneNumber = phoneNumberTmp;
                        } else {
                          Fluttertoast.showToast(
                            msg: globals.getLocalization("scrProfile_phone_number_invalid"),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            fontSize: 16.0,
                            backgroundColor: Colors.white,
                            textColor: Colors.teal,
                          );
                        }
                      }
                      type = Type.NONE;
                    });
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6 * 0.3,
                    child: Text(
                      globals.getLocalization("BUTTON_TEXT_OK"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Consolas',
                          fontSize: 15.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _popupUpdate(Type T, BuildContext context) {
    if (Type.NONE == T) {
      return Container();
    } else if (Type.AVATAR == T) {
      double heght = MediaQuery.of(context).size.height * 0.7 * 0.5;
      double width = MediaQuery.of(context).size.width * 0.6;
      return Positioned(
        left: MediaQuery.of(context).size.width * 0.5 - width / 2,
        top: MediaQuery.of(context).size.height * 0.3 - heght / 2,
        child: Container(
          height: heght,
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.teal),
          ),
          child: showAllAvatar(),
        ),
      );
    } else if (Type.DISPLAY_NAME == T ||
        Type.PHONE_NUMBER == T ||
        Type.EMAIL == T) {
      double heght = MediaQuery.of(context).size.height * 0.7 * 0.25;
      double width = MediaQuery.of(context).size.width * 0.6;
      Widget widget;
      if (Type.DISPLAY_NAME == T) {
        widget = showEditDisplayName();
      } else if (Type.PHONE_NUMBER == T) {
        widget = showEditPhoneNumber();
      } else {
        widget = showEditEmail();
      }
      double top = MediaQuery.of(context).size.height * 0.3 - heght / 2;
      print(MediaQuery.of(context).size.height);
      print(MediaQuery.of(context).viewInsets.bottom);
//      if (MediaQuery.of(context).viewInsets.bottom > 0) {
//        top = MediaQuery.of(context).size.height -
//            MediaQuery.of(context).viewInsets.bottom -
//            MediaQuery.of(context).size.height * 0.2 -
//            heght;
//        print(top);
//      }
      return Positioned(
        left: MediaQuery.of(context).size.width * 0.5 - width / 2,
        top: top,
        child: Container(
          height: heght,
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.teal),
          ),
          child: widget,
        ),
      );
    }
  }

  soundButtonClick() {
    if (globals.isSound && audioCache != null) {
      audioCache.play(urlButtonClicked, mode: PlayerMode.LOW_LATENCY);
    }
  }

  @override
  void initState() {
    audioCache = AudioCache();
    type = Type.NONE;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Material(
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
              height: MediaQuery.of(context).size.height * 0.2,
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
            // form Profile
            _formProfile(context),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
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
                                globals.getLocalization("global_footer_text_1"),
                                style: TextStyle(
                                        fontSize: 13.0, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                globals.getLocalization("global_footer_text_2"),
                                style: TextStyle(
                                        fontSize: 13.0, color: Colors.yellow),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                globals.getLocalization("global_footer_text_3"),
                                style: TextStyle(
                                        fontSize: 13.0, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                globals.getLocalization("global_footer_text_4"),
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
    );
  }
}
