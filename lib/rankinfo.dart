import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'globals.dart' as globals;

class RankInfo extends StatefulWidget {
  @override
  State createState() {
    return new RankInfoState();
  }
}

class RankInfoState extends State<RankInfo> {
  Size _wSize;
  AudioCache audioCache;
  String urlButtonClicked = "button_click.mp3";

  TextStyle _rankingTitle = new TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 30.0,
  );

  @override
  void initState() {
    audioCache = AudioCache();
  }

  @override
  Widget build(BuildContext context) {
    _wSize = MediaQuery.of(context).size;

    SystemChrome.setEnabledSystemUIOverlays([]);
    return Material(
      child: show(),
    );
  }

  Widget show() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          showBanner(),
          showRankingInfo(),
        ],
      ),
    );
  }

  soundButtonClick() {
    if (globals.isSound && audioCache != null) {
      audioCache.play(urlButtonClicked, mode: PlayerMode.LOW_LATENCY);
    }
  }

  showBanner() {
    Widget widget;
    widget = new Container(
      height: _wSize.height * 0.1,
      decoration: BoxDecoration(),
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
                        globals.getLocalization("scrRankingInfo_title"),
                        style: _rankingTitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: _wSize.height * 0.1,
            height: _wSize.height * 0.1,
          ),
        ],
      ),
    );
    return widget;
  }

  showRankingInfo() {
    Widget widget;
    widget = new Container(
      height: _wSize.height * 0.87,
      decoration: BoxDecoration(),
      child: Image.asset(globals.getLocalization("scrRankingInfo")),
    );
    return widget;
  }
}
