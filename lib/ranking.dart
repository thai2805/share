import 'dart:convert';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'objres.dart';
import 'rankinfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;
import 'gp_userInfo.dart' as gp;

class Ranking extends StatefulWidget {
  @override
  RankingState createState() {
    return RankingState();
  }
}

class RankingState extends State<Ranking> {
  String urlButtonClicked = "button_click.mp3";
  AudioCache audioCache;
  Size _wSize;
  var messageInRanking = "";
  var gamer;
  bool isGetResult = false;
  TextStyle _rankingTitle = new TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 30.0,
  );
  TextStyle _st = new TextStyle(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0);
  TextStyle _1stColor = new TextStyle(color: Colors.yellow[700]);
  TextStyle _2stColor = new TextStyle(color: Colors.grey[300]);
  TextStyle _3stColor = new TextStyle(color: Colors.orange[800]);
  TextStyle _stColor = new TextStyle(color: Colors.black);

  soundButtonClick() {
    if (globals.isSound && audioCache != null) {
      audioCache.play(urlButtonClicked, mode: PlayerMode.LOW_LATENCY);
    }
  }

  Future getRank() async {
    String urlGetRank = globals.linksso + "/data/ranking";
    var response = await http.get(urlGetRank, headers: {
      'language': globals.language
    });
    print("status : ${response.statusCode} | body : '${response.body}'");
    if (response.statusCode == 200) {
      ObjRes objRes = ObjRes.fromJson(json.decode(response.body));
      if (objRes.success == true) {
        setState(() {
          gamer = JsonDecoder().convert(objRes.data);
          messageInRanking = objRes.message;
//          messageInRanking = "Kết thúc mùa 1 : 01/01/2020";
        });
      }
    }
  }

  Future getInfoUser({String username, String token}) async {
    print("==> ${username} ${token}");
    if (username.length > 0 && token.length > 0) {
      String urlGetInfo = globals.linksso + "/user/getinfo";
      var header = {
        'x-access-token': token,
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
          globals.changeDisplayName = objGetInfo.changeDisplayName;
          globals.linkAvatar = objGetInfo.linkAvatar;
          globals.score = objGetInfo.currentScore;
          globals.points = objGetInfo.points;
          globals.totalMatch = objGetInfo.totalMatch;
          globals.totalWin = objGetInfo.totalWin;
          globals.totalWinRank = objGetInfo.totalWinRank;
          globals.totalMatchRank = objGetInfo.totalMatchRank;
          globals.token = token;
        }
      }
    }
  }

  showBanner() {
    Widget widget;
    widget = new Container(
      height: _wSize.height * 0.1,
      decoration: BoxDecoration(
//        image: DecorationImage(
//          image: AssetImage("assets/background_ranking.jpg"),
//          fit: BoxFit.fitWidth
//        ),
          ),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              soundButtonClick();
              Navigator.of(context).pop();
            },
            child: Container(
              width: _wSize.height * 0.1,
              height: _wSize.height * 0.1,
              child: Icon(
                Icons.arrow_back_ios,
                size: 30.0,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        globals.getLocalization("scrRanking_title"),
                        style: _rankingTitle,
                      ),
                      messageInRanking.length > 3
                          ? Text(
                              messageInRanking,
                              style: TextStyle(
                                  color: Colors.lightGreenAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              soundButtonClick();
              Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => new RankInfo()));
            },
            child: Container(
              width: _wSize.height * 0.1,
              height: _wSize.height * 0.1,
              child: Icon(
                Icons.message,
                size: 30.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    return widget;
  }

  showRanking() {
    Widget widget;
    widget = new Container(
      height: _wSize.height * 0.7,
      decoration: BoxDecoration(
//        border: Border.all(),
          ),
      child: Stack(
        children: <Widget>[
          ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: (gamer != null ? gamer.length : 0),
            itemBuilder: (BuildContext context, int index) {
              ObjGetInfo objGetInfo = ObjGetInfo.fromJson(gamer[index]);
              print(gamer[index]);
              return GestureDetector(
                onTapDown: (td) {
                  setState(() {
                    globals.isShowFullInfoInRanking = true;
                    globals.info = objGetInfo;
                  });
                },
                onTapUp: (tu) {
                  setState(() {
                    globals.isShowFullInfoInRanking = false;
                    globals.info = null;
                  });
                },
                onPanStart: (ps) {
                  setState(() {
                    globals.isShowFullInfoInRanking = false;
                    globals.info = null;
                  });
                },
                child: Container(
                  height: _wSize.height * 0.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          height: _wSize.height * 0.1,
                          decoration: BoxDecoration(),
                          padding: EdgeInsets.all(_wSize.height * 0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                width: _wSize.width * 0.07,
                                height: _wSize.width * 0.07,
                                child: Center(
                                  child: (index + 1 == 1
                                      ? Image.asset("assets/background_1st.png")
                                      : (index + 1 == 2
                                          ? Image.asset(
                                              "assets/background_2st.png")
                                          : (index + 1 == 3
                                              ? Image.asset(
                                                  "assets/background_3st.png")
                                              : Text("${index + 1}",
                                                  style: _st)))),
                                ),
                              ),
                              Image.asset("assets/${objGetInfo.linkAvatar}"),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      SizedBox(
                                        child: Text(
                                          "${objGetInfo.displayName}",
                                          style: TextStyle(
                                              color: (index + 1 == 1
                                                  ? _1stColor.color
                                                  : (index + 1 == 2
                                                      ? _2stColor.color
                                                      : (index + 1 == 3
                                                          ? _3stColor.color
                                                          : _stColor.color))),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: gp.GamePart().getRankLevel(
                                              objGetInfo.currentScore),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width:
                                    _wSize.height * 0.098 + _wSize.width * 0.07,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Image.asset(gp.GamePart()
                                        .getImgRank(objGetInfo.currentScore)),
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
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
              color: Colors.white,
              thickness: 1.0,
            ),
          ),
          gp.GamePart().getFullInfoUserInRanking(_wSize),
        ],
      ),
    );
    return widget;
  }

  showMyRanking() {
    Widget widget;
    int index = -1;
    if (gamer != null) {
      for (int i = 0; i < gamer.length; i++) {
        ObjGetInfo objGetInfo = ObjGetInfo.fromJson(gamer[i]);
        if (globals.username == objGetInfo.username) {
          index = i;
          break;
        }
      }
    }

    var position;

    if (index == -1) {
      position = Icon(
        Icons.all_inclusive,
        color: _st.color,
        size: _st.fontSize,
      );
    } else {
      position = Container(
        width: _wSize.width * 0.07,
        height: _wSize.width * 0.07,
        child: Center(
          child: (index + 1 == 1
              ? Image.asset("assets/background_1st.png")
              : (index + 1 == 2
                  ? Image.asset("assets/background_2st.png")
                  : (index + 1 == 3
                      ? Image.asset("assets/background_3st.png")
                      : Text("${index + 1}", style: _st)))),
        ),
      );
    }

    widget = new Container(
      height: _wSize.height * 0.1,
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
//        borderRadius: Border(top: BorderSide(color: Colors.red, width: 1.0, style: BorderStyle.solid)),
        border: Border(
            top: BorderSide(
                color: Colors.yellow, width: 2.0, style: BorderStyle.solid)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
            width: _wSize.width * 0.06,
            child: position,
          ),
          Image.asset("assets/${globals.linkAvatar}"),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    child: Text(
                      "${globals.displayName}",
                      style: TextStyle(
                          color: (index + 1 == 1
                              ? _1stColor.color
                              : (index + 1 == 2
                                  ? _2stColor.color
                                  : (index + 1 == 3
                                      ? _3stColor.color
                                      : _stColor.color))),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: gp.GamePart().getRankLevel(globals.score),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: _wSize.height * 0.098 + _wSize.width * 0.07,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image.asset(gp.GamePart().getImgRank(globals.score)),
              ],
            ),
          ),
        ],
      ),
    );
    return widget;
  }

  showAboutAndAdmob() {
    Widget widget;
    widget = new Expanded(
      child: Container(
        height: _wSize.height * 0.7,
        decoration: BoxDecoration(),
      ),
    );
    return widget;
  }

  @override
  void initState() {
    audioCache = AudioCache();
  }

  @override
  Widget build(BuildContext context) {
    _wSize = MediaQuery.of(context).size;
    if (isGetResult == false) {
      isGetResult = true;
      getRank();
    }

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
            showBanner() ?? new Container(),
            showRanking() ?? new Container(),
            showMyRanking() ?? new Container(),
            showAboutAndAdmob() ?? new Container(),
          ],
        ),
      ),
    );
  }
}
