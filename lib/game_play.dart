import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'ranking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'dart:math';
import 'dart:io';
import 'dart:io' show Platform;
import 'globals.dart' as globals;
import 'gp_userInfo.dart' as gp;
import 'dart:convert' show utf8;
import 'package:http/http.dart' as http;
import 'objres.dart';
import 'package:vibrate/vibrate.dart';
import 'package:firebase_admob/firebase_admob.dart';

enum Graphics { SHOW_MENU, PLAYING }

enum GameState { INIT, START, OK, PLAYING, VICTORY, END, ERROR }

enum GameMenu {
  GAME_MENU,
  FINDING_OPPONENT,
  READY,
  WAITING_OPPONENT,
  PLAYING,
  FRIEND_MATCH,
  JOIN_ROOM,
  JOINING_ROOM,
  CREATE_ROOM,
  WAITING_IN_ROOM,
  WINNER,
  LOSER
}

//const String testDevice = 'A9147A2443CBF29902F4F1961DF40F39';
const String testDevice = null;

class App extends StatefulWidget {
  @override
  AppState createState() => AppState();
}

class AppState extends State<App> with WidgetsBindingObserver {
  int SIZEBOARD = 23;
  double height_user_info = 150;
  Size _wSize;
  double posx = 0, posy = 0;
  Matrix4 _matrix4 = Matrix4.identity();
  Offset trans = Offset.zero;
  double scale = 1.0;
  List<List<int>> arr;
  bool isRandomChessman = false;
  Random random = new Random();
  bool isShowFocus = false;
  double pos_x = 0, pos_y = 0;
  Graphics graphics = Graphics.SHOW_MENU;
  GameMenu gameMenu = GameMenu.GAME_MENU;
  Socket socket;
  String CRLF = "\r\n";
  String SPEC = "|";
  int key;
  int idChatIcon = 0;
  int idChatIconOpponent = 0;
  Timer timerChat;
  Timer timerChatOpponent;
  int timeoutChat = 0;
  int timeoutChatOpponent = 0;
  double widthMaxChatIcon = 0;
  int timeoutPressButton = 0;
  Timer timerPressButton;
  bool buttonPressed = false;
  String urlButtonClicked = "button_click.mp3";
  String urlChessMove = "chess_move_new.mp3";
  String urlLoser = "over.wav";
  String urlStartGame = "erase.wav";
  String urlVictory = "newbest.wav";
  String urlMessageNotification = "message_notification.mp3";
  AudioCache audioCache;
  bool isShowSetting = false;

  // value for const height
  double HEIGHT_USER_INFO, HEIGHT_BOARD, HEIGHT_ICON_CHAT, HEIGHT_ADS;
  double MAX_HEIGHT = 576.0;
  double _left = 0;

  // value for status game
  String chessman;
  int roomId;
  int timeout = 0;
  String usernameOpponent;
  String currentTurn;
  int myTurn = 0, opponentTurn = 0;
  Timer timer;
  double rememberX, rememberY;
  Timer timeFinding;
  String timeText = "00:00";
  int timeCount = 0;
  var focusChat = new FocusNode();
  TextEditingController _controller = new TextEditingController();
  bool isShowChat = false, isShowChatBox = false, isShowMyChatText = false;
  String myScore = "0", opponentScore = "0";
  String msgChat = "", tempMsgChat = "";
  bool isShowInviteBox = false;
  Timer timerCloseInvite;
  int timeoutCloseInvite = 10;
  int roomIdInvite;
  int keyInvite;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
  }

  TextStyle textScore = TextStyle(
    color: Colors.teal,
    fontSize: 25,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        blurRadius: 10.0,
        color: Colors.teal,
        offset: Offset(2.0, 2.0),
      ),
    ],
  );

  // for ads
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['Caro', 'caro online', 'chess', 'gomoku', 'game online'],
    contentUrl: 'http://rankvn.com',
    childDirected: true,
    nonPersonalizedAds: true,
  );

  BannerAd _bannerAd;
  bool isShowAd = false;

  BannerAd createBannerAd() {
    String appId = "";
    if (Platform.isIOS) {
      print("### IOS");
      appId = 'ca-app-pub-1236691098488009/3475695441';
    } else {
      print("### Android");
      appId = 'ca-app-pub-1236691098488009/3014824152';
    }
    return BannerAd(
      adUnitId: appId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
//        if (event == MobileAdEvent.failedToLoad) {
//          sleep(const Duration(seconds: 1));
//          createBannerAd()..load();
//        }
      },
    );
  }

  // end ads

  void setTimeout() {
    if (timer != null) timer.cancel();
    const oneSec = const Duration(seconds: 1);
    timer = new Timer.periodic(oneSec, (Timer t) {
      if (timer != null) {
        setState(() {
          if (timeout < 0) {
            timer.cancel();
          } else {
            timeout -= 1;
          }
        });
      }
    });
  }

  void setTimeoutMsgInvite() {
    if (timerCloseInvite != null) timerCloseInvite.cancel();
    const oneSec = const Duration(seconds: 1);
    timerCloseInvite = new Timer.periodic(oneSec, (Timer t) {
      if (timerCloseInvite != null) {
        setState(() {
          if (timeoutCloseInvite <= 1) {
            timerCloseInvite.cancel();
            isShowInviteBox = false;
          } else {
            timeoutCloseInvite -= 1;
          }
        });
      }
    });
  }

  void setTimeoutChat() {
    if (timerChat != null) timerChat.cancel();
    const oneSec = const Duration(seconds: 1);
    timerChat = new Timer.periodic(oneSec, (Timer t) {
      if (timerChat != null) {
        setState(() {
          if (timeoutChat < 0) {
            timerChat.cancel();
            setState(() {
              idChatIcon = 0;
              isShowChatBox = false;
            });
          } else {
            timeoutChat -= 1;
          }
        });
      }
    });
  }

  void setTimeoutPressButton() {
    if (timerPressButton != null) timerPressButton.cancel();
    const oneSec = const Duration(seconds: 1);
    timerPressButton = new Timer.periodic(oneSec, (Timer t) {
      if (timerPressButton != null) {
        setState(() {
          if (timeoutPressButton < 0) {
            timerPressButton.cancel();
            setState(() {
              buttonPressed = false;
            });
          } else {
            timeoutPressButton -= 1;
          }
        });
      }
    });
  }

  void setTimeoutChatOpponent() {
    if (timerChatOpponent != null) timerChatOpponent.cancel();
    const oneSec = const Duration(seconds: 1);
    timerChatOpponent = new Timer.periodic(oneSec, (Timer t) {
      if (timerChatOpponent != null) {
        setState(() {
          if (timeoutChatOpponent < 0) {
            timerChatOpponent.cancel();
            setState(() {
              idChatIconOpponent = 0;
              isShowChatBox = false;
            });
          } else {
            timeoutChatOpponent -= 1;
          }
        });
      }
    });
  }

  void showTime() {
    const oneSec = const Duration(seconds: 1);
    if (timeFinding != null) timeFinding.cancel();
    timeFinding = new Timer.periodic(oneSec, (Timer t) {
      timeCount += 1;
      setState(() {
        timeText = formatHHMMSS(timeCount);
      });
    });
  }

  void offTime() {
    if (timeFinding != null) timeFinding.cancel();
    timeCount = 0;
    timeText = "00:00";
  }

  String formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return "$minutesStr:$secondsStr";
    }

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  connectServer() async {
    try {
      socket = await Socket.connect(globals.serverApps, globals.portApps);
    } catch (e) {
      print(e);
    }
    if (socket != null) {
      print("Connected to server");
      socket.listen(onData);
      socket.setOption(SocketOption.tcpNoDelay, true);
      var msg = "USERNAME|" + globals.username + SPEC + CRLF + CRLF;
      print(msg);
      socket.write(msg);
    } else {
      onError();
      Navigator.of(context).pop();
    }
  }

  onError() {
    print("Kết nối mạng có vấn đề, vui lòng kiểm tra lại.");
    Navigator.of(context).pop();
    Fluttertoast.showToast(
      msg: "Kết nối mạng có vấn đề, vui lòng kiểm tra lại.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      fontSize: 16.0,
      textColor: Colors.red,
      backgroundColor: Colors.white,
    );
  }

  processData(String cmd) async {
    print("DATA : '" + cmd + "'");
    if (cmd != null && cmd.length > 0) {
      if (cmd.startsWith("GAME|INIT|")) {
        //GAME|INIT|{username}|{X|O}|{roomId}|{timeout}|{key of username*}| CRLF CRLF
        offTime();
        var sp = cmd.split(SPEC);
        if (sp.length >= 8 && int.parse(sp[6]) == key) {
          setState(() {
            graphics = Graphics.SHOW_MENU;
            gameMenu = GameMenu.READY;
            chessman = sp[3];
            roomId = int.parse(sp[4]);
            timeout = int.parse(sp[5]);
            print(sp);
          });
          msgInit();
          if (globals.isVibrate) {
            Vibrate.vibrate();
          }
        }
      } else if (cmd.startsWith("GAME|START|")) {
        //GAME|START|{timeout}|{key of username*}| CRLF CRLF
        var sp = cmd.split(SPEC);
        if (sp.length >= 5 && int.parse(sp[3]) == key) {
          setState(() {
            timeout = int.parse(sp[2]);
          });
        }
      } else if (cmd.startsWith("GAME|OK|")) {
        //GAME|OK|{username_x(your turn)}|{username_o}|{timeout}|{key of username*}| CRLF CRLF
        var sp = cmd.split(SPEC);
        if (sp.length >= 7 && int.parse(sp[5]) == key) {
          currentTurn = sp[2];
          if (globals.username.compareTo(sp[2]) == 0) {
            usernameOpponent = sp[3];
          } else {
            usernameOpponent = sp[2];
          }
          timeout = int.parse(sp[4]);
          arr = _initState();
          if (currentTurn.compareTo(globals.username) == 0) {
            myTurn = 1;
            opponentTurn = 0;
          } else {
            myTurn = 0;
            opponentTurn = 1;
          }
          setTimeout();
          await getInfoUser(username: globals.username, token: globals.token);
          await getInfoOpponent(
              username: usernameOpponent, token: globals.token);
          setState(() {
            gameMenu = GameMenu.PLAYING;
            graphics = Graphics.PLAYING;
          });
          if (globals.isVibrate) {
            Vibrate.vibrate();
          }
          if (globals.isSound && audioCache != null) {
            audioCache.play(urlStartGame, mode: PlayerMode.LOW_LATENCY);
          }
        }
      } else if (cmd.startsWith("GAME|PLAYING|")) {
        //GAME|PLAYING|{username_o(your turn)}|{2|3}|{position_x}|{position_y}|{timeout}|{key of username*}| CRLF CRLF
        var sp = cmd.split(SPEC);
        if (sp.length >= 9 && int.parse(sp[7]) == key) {
          // update status of chessman
          for (var i = 1; i < SIZEBOARD; i++) {
            for (var j = 1; j < SIZEBOARD; j++) {
              if (arr[i][j] == 2) {
                arr[i][j] = 1;
              }
              if (arr[i][j] == 3) {
                arr[i][j] = 0;
              }
            }
          }
          currentTurn = sp[2];
          arr[int.parse(sp[4])][int.parse(sp[5])] = int.parse(sp[3]);
          timeout = int.parse(sp[6]);
          if (currentTurn.compareTo(globals.username) == 0) {
            myTurn = 1;
            opponentTurn = 0;
            if (globals.isVibrate) {
              Vibrate.vibrate();
            }
          } else {
            myTurn = 0;
            opponentTurn = 1;
          }
          if (globals.isSound && audioCache != null) {
            audioCache.play(urlChessMove, mode: PlayerMode.LOW_LATENCY);
          }
          setTimeout();
          setState(() {});
        }
      } else if (cmd.startsWith("GAME|VICTORY|")) {
        //GAME|VICTORY|{username_winner}|{timeout}|{key of username*}|{score_winer}|{score_loser}| CRLF CRLF
        var sp = cmd.split(SPEC);
        if (sp.length >= 6 && int.parse(sp[4]) == key) {
          for (var i = 1; i < SIZEBOARD; i++) {
            for (var j = 1; j < SIZEBOARD; j++) {
              if (arr[i][j] == 2) {
                arr[i][j] = 1;
              }
              if (arr[i][j] == 3) {
                arr[i][j] = 0;
              }
            }
          }
          myTurn = 0;
          opponentTurn = 0;
          await getInfoUser(username: globals.username, token: globals.token);
          await getInfoOpponent(
              username: usernameOpponent, token: globals.token);
          setState(() {
            graphics = Graphics.SHOW_MENU;
            if (globals.username.compareTo(sp[2]) == 0) {
              if (globals.isSound && audioCache != null) {
                audioCache.play(urlVictory, mode: PlayerMode.LOW_LATENCY);
              }
              gameMenu = GameMenu.WINNER;
              myScore = sp[5];
              opponentScore = sp[6];
            } else {
              if (globals.isSound && audioCache != null) {
                audioCache.play(urlLoser, mode: PlayerMode.LOW_LATENCY);
              }
              gameMenu = GameMenu.LOSER;
              myScore = sp[6];
              opponentScore = sp[5];
            }
            timeout = int.parse(sp[3]);
          });
        }
      } else if (cmd.startsWith("GAME|END|")) {
        // GAME|END|{key of username}|{timeout}|{key of username*}| CRLF CRLF
        var sp = cmd.split(SPEC);
        if (sp.length >= 6 && int.parse(sp[4]) == key) {
          resetInfoOpponent();
          await getInfoUser(username: globals.username, token: globals.token);
          setState(() {
            graphics = Graphics.SHOW_MENU;
            gameMenu = GameMenu.GAME_MENU;
          });
        }
      } else if (cmd.startsWith("GAME|ERROR|")) {
        //GAME|ERROR|{key of username}| CRLF CRLF
        var sp = cmd.split(SPEC);
        if (sp.length >= 4 && int.parse(sp[2]) == key) {
          resetInfoOpponent();
          await getInfoUser(username: globals.username, token: globals.token);
          setState(() {
            graphics = Graphics.SHOW_MENU;
            gameMenu = GameMenu.GAME_MENU;
          });
        }
      } else if (cmd.startsWith("GRANDBATTLE|CREATEROOM|")) {
        //GRANDBATTLE|CREATEROOM|{roomId}|CRLF CRLF
        var sp = cmd.split(SPEC);
        setState(() {
          graphics = Graphics.SHOW_MENU;
          gameMenu = GameMenu.WAITING_IN_ROOM;
          roomId = int.parse(sp[2]);
        });
      } else if (cmd.startsWith("CHAT|ICON|")) {
        // CHAT|ICON|{roomId}|{username}|{id}|{key of username*}|CRLF CRLF
        var sp = cmd.split(SPEC);
        if (sp.length >= 7 && int.parse(sp[5]) == key) {
          if (globals.usernameOpponent.compareTo(sp[3]) == 0) {
            if (globals.isSound && audioCache != null) {
              audioCache.play(urlMessageNotification,
                  mode: PlayerMode.LOW_LATENCY);
            }
            setState(() {
              timeoutChatOpponent = 3;
              idChatIconOpponent = int.parse(sp[4]);
              setTimeoutChatOpponent();
            });
          }
        }
      } else if (cmd.startsWith("CHAT|MSG|")) {
        // CHAT|MSG|{roomId}|{username}|{msg}|{key of username*}|CRLF CRLF
        var sp = cmd.split(SPEC);
        if (sp.length >= 7 && int.parse(sp[5]) == key) {
          if (globals.usernameOpponent.compareTo(sp[3]) == 0) {
            if (globals.isSound && audioCache != null) {
              audioCache.play(urlMessageNotification,
                  mode: PlayerMode.LOW_LATENCY);
            }
            setState(() {
              timeoutChatOpponent = 3;
              tempMsgChat = sp[4];
              isShowChatBox = true;
              isShowMyChatText = false;
              setTimeoutChatOpponent();
            });
          }
        }
      } else if (cmd.startsWith("GAME|INVITE|")) {
        // GAME|INVITE|{username}|X|{roomId}|{timeout}|{key of username*}| CRLF CRLF
        var sp = cmd.split(SPEC);
        if (sp.length >= 7) {
          print("INVITE : " + cmd);
          if (globals.isSound && audioCache != null) {
            audioCache.play(urlMessageNotification,
                mode: PlayerMode.LOW_LATENCY);
          }
          setState(() {
            isShowInviteBox = true;
            timeoutCloseInvite = int.parse(sp[5]);
            roomIdInvite = int.parse(sp[4]);
            keyInvite = int.parse(sp[6]);
            setTimeoutMsgInvite();
            msgReceivedInvite();
          });
        }
      }
    }
  }

  void onData(data) {
//    String cmd = new String.fromCharCodes(data);
    String cmd = utf8.decode(data);
    var sp = cmd.split(CRLF + CRLF);
    for (int i = 0; i < sp.length; i++) {
      processData(sp[i]);
    }
  }

  resetInfoOpponent() {
    globals.usernameOpponent =
        globals.getLocalization("global_name_default_opponent");
    globals.displayNameOpponent =
        globals.getLocalization("global_name_default_opponent");
    globals.scoreOpponent = 0;
    globals.totalMatchRankOpponent = 0;
    globals.totalWinRankOpponent = 0;
    globals.totalMatchOpponent = 0;
    globals.linkAvatarOpponent = "img_avatar_1.png";
    myTurn = 0;
    opponentTurn = 0;
    roomId = 0;
    myScore = "0";
    opponentScore = "0";
    isShowAd = false;
  }

  resetDowncount() {
    if (timer != null) {
      timer.cancel();
    }
    if (timerChat != null) {
      timerChat.cancel();
    }
    if (timerChatOpponent != null) {
      timerChatOpponent.cancel();
    }
    if (timerPressButton != null) {
      timerPressButton.cancel();
    }
  }

  msgFindingMatchInRank() async {
    if (socket != null) {
      // FINDMATCHRANK|app|{username}|{score}|{key}| CRLF CRLF
      var msg =
          "FINDMATCHRANK|app|${globals.username}|${globals.score}|${key}|" +
              CRLF +
              CRLF;
      print(msg);
      socket.write(msg);
    } else {
      print("socket is null");
    }
  }

  msgPlayWithAI() {
    if (socket != null) {
      // AIBATTLE|app|{username}|{score}|{key}| CRLF CRLF
      var msg = "AIBATTLE|app|${globals.username}|${globals.score}|${key}|" +
          CRLF +
          CRLF;
      print(msg);
      socket.write(msg);
    } else {
      print("socket is null");
    }
  }

  msgInit() async {
    if (socket != null) {
      // GAME|INIT|{roomId}|{username}|{key}|{current_score}| CRLF CRLF
      var msg =
          "GAME|INIT|${roomId}|${globals.username}|${key}|${globals.score}|" +
              CRLF +
              CRLF;
      print(msg);
      socket.write(msg);
    } else {
      print("socket is null");
    }
  }

  msgStart() async {
    if (socket != null) {
      //GAME|START|{roomId}|{username}|{key}| CRLF CRLF
      var msg =
          "GAME|START|${roomId}|${globals.username}|${key}|" + CRLF + CRLF;
      print(msg);
      socket.write(msg);
    } else {
      print("socket is null");
    }
  }

  msgReady() async {
    if (socket != null) {
      // FINDMATCHRANK|app|{username}|{token}|{key}| CRLF CRLF
      var msg =
          "FINDMATCHRANK|app|${globals.username}|${globals.token}|${key}|" +
              CRLF +
              CRLF;
      print(msg);
      socket.write(msg);
    } else {
      print("socket is null");
    }
  }

  msgPositionOfChessman() async {
    if (socket != null) {
      // GAME|PLAYING|{roomId}|{username_x}|{key}|{position_x}|{position_y}| CRLF CRLF
      var msg =
          "GAME|PLAYING|${roomId}|${globals.username}|${key}|${rememberX.round()}|${rememberY.round()}|" +
              CRLF +
              CRLF;
      print(msg);
      socket.write(msg);
    } else {
      print("socket is null");
    }
  }

  msgIconChat(int id) async {
    if (socket != null) {
      // CHAT|ICON|{roomId}|{id}| CRLF CRLF
      var msg = "CHAT|ICON|${roomId}|${id}|" + CRLF + CRLF;
      print(msg);
      socket.write(msg);
    } else {
      print("socket is null");
    }
  }

  msgFindingFriendMatch() {
    if (socket != null) {
      // GRANDBATTLE|CREATEROOM|app|{username}|{token}|{key}|CRLF CRLF
      var msg =
          "GRANDBATTLE|CREATEROOM|app|${globals.username}|${globals.token}|${key}|" +
              CRLF +
              CRLF;
      print(msg);
      socket.write(msg);
    } else {
      print("socket is null");
    }
  }

  msgConnectingToRoom() {
    if (socket != null) {
      // GRANDBATTLE|JOIN|app|{username}|{token}|{key}|{roomId}|CRLF CRLF
      var msg =
          "GRANDBATTLE|JOIN|app|${globals.username}|${globals.token}|${key}|${roomId}|" +
              CRLF +
              CRLF;
      print(msg);
      socket.write(msg);
    } else {
      print("socket is null");
    }
  }

  msgCancelFriendMatch() {
    if (socket != null) {
      // GRANDBATTLE|CANCEL|app|{username}|{token}|{key}|{roomId}|CRLF CRLF
      var msg =
          "GRANDBATTLE|CANCEL|app|${globals.username}|${globals.token}|${key}|${roomId}|" +
              CRLF +
              CRLF;
      print(msg);
      socket.write(msg);
    } else {
      print("socket is null");
    }
  }

  msgKeepStar() {
    if (socket != null) {
      // GAME|INVITEACCEPT|{roomId}|{username}|{key}| CRLF CRLF
      var msg =
          "GAME|KEEPSTAR|${roomId}|${globals.username}|${key}|" + CRLF + CRLF;
      print(msg);
      socket.write(msg);
    } else {
      print("socket is null");
    }
  }

  msgReceivedInvite() {
    if (socket != null) {
      // GAME|INVITERECEIVE|{roomId}|{username}|{key}| CRLF CRLF
      var msg =
          "GAME|INVITERECEIVE|${roomIdInvite}|${globals.username}|${keyInvite}|" +
              CRLF +
              CRLF;
      print(msg);
      socket.write(msg);
    } else {
      print("socket is null");
    }
  }

  msgAcceptInvite() {
    if (socket != null) {
      // GAME|INVITEACCEPT|{roomId}|{username}|{key}| CRLF CRLF
      var msg =
          "GAME|INVITEACCEPT|${roomIdInvite}|${globals.username}|${keyInvite}|" +
              CRLF +
              CRLF;
      print(msg);
      socket.write(msg);
      roomId = roomIdInvite;
      key = keyInvite;
    } else {
      print("socket is null");
    }
  }

  msgCancelInvite() {
    if (socket != null) {
      // GAME|INVITECANCEL|{roomId}|{username}|{key}| CRLF CRLF
      var msg =
          "GAME|INVITECANCEL|${roomIdInvite}|${globals.username}|${keyInvite}|" +
              CRLF +
              CRLF;
      print(msg);
      socket.write(msg);
    } else {
      print("socket is null");
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_bannerAd != null) {
      _bannerAd.dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    audioCache = AudioCache();
    resetInfoOpponent();
    key = random.nextInt(9999) + 1000;
    graphics = Graphics.SHOW_MENU;
    gameMenu = GameMenu.GAME_MENU;
    arr = _initState();
    String appId = "";
    if (Platform.isIOS) {
      print("### IOS init");
      appId = "ca-app-pub-1236691098488009~2410025780";
    } else {
      print("### Android init");
      appId = "ca-app-pub-1236691098488009~8895543082";
    }

    FirebaseAdMob.instance.initialize(appId: appId);
    _bannerAd = createBannerAd()..load();
    connectServer();
  }

  List<List<int>> _initState() {
    List<List<int>> arrTmp = new List<List<int>>();
    for (var i = 0; i < SIZEBOARD; i++) {
      List<int> _row = new List<int>();
      for (var j = 0; j < SIZEBOARD; j++) {
        _row.add(-1);
      }
      arrTmp.add(_row);
    }
    return arrTmp;
  }

  List<List<int>> _randomChessman() {
    List<List<int>> arrTmp = new List<List<int>>();
    for (var i = 0; i < SIZEBOARD; i++) {
      List<int> _row = new List<int>();
      for (var j = 0; j < SIZEBOARD; j++) {
        if (i == 0 || j == 0) {
          _row.add(-1);
        } else {
          var rc = random.nextInt(3) - 1;
          _row.add(rc);
        }
      }
      arrTmp.add(_row);
    }
    return arrTmp;
  }

  String returnChessman(int id) {
    switch (id) {
      case 1:
        return 'assets/x.png';
      case 0:
        return 'assets/o.png';
      case 2:
        return 'assets/x_new.png';
      case 3:
        return 'assets/o_new.png';
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
          globals.linkAvatar = objGetInfo.linkAvatar;
          globals.score = objGetInfo.currentScore;
          globals.points = objGetInfo.points;
          globals.totalMatch = objGetInfo.totalMatch;
          globals.totalWinRank = objGetInfo.totalWinRank;
          globals.totalMatchRank = objGetInfo.totalMatchRank;
        }
      }
    }
  }

  Future getInfoOpponent({String username, String token}) async {
    print("==> ${username} ${token}");
    if (username.length > 0 && token.length > 0) {
      String urlGetInfoOfUsername = globals.linksso + "/user/getinfo/username";
      var header = {
        'x-access-token': token,
        'username': username,
      };
      var response = await http.get(urlGetInfoOfUsername, headers: header);
      print("status : ${response.statusCode} | body : '${response.body}'");
      if (response.statusCode == 200) {
        ObjRes objRes = ObjRes.fromJson(json.decode(response.body));
        if (objRes.success == true) {
          ObjGetInfo objGetInfo = ObjGetInfo.fromJson(objRes.data);
          globals.usernameOpponent = objGetInfo.username;
          globals.displayNameOpponent = objGetInfo.displayName;
          globals.linkAvatarOpponent = objGetInfo.linkAvatar;
          globals.scoreOpponent = objGetInfo.currentScore;
          globals.totalMatchOpponent = objGetInfo.totalMatch;
          globals.totalWinRankOpponent = objGetInfo.totalWinRank;
          globals.totalMatchRankOpponent = objGetInfo.totalMatchRank;
        }
      }
    }
  }

  Widget drawChessmanOnBoard() {
    checkCaro();
    List<Widget> lstWg = new List<Widget>();
    lstWg.add(Image.asset('assets/board.png'));
    var size = _wSize.width / SIZEBOARD;
    if (arr != null) {
      for (var i = 1; i < SIZEBOARD; i++) {
        for (var j = 1; j < SIZEBOARD; j++) {
          // convert to position of chessman
          var X = i * size;
          var Y = j * size;
          if (arr[i][j] < 0) continue;
          lstWg.add(
            new Positioned(
              child: Container(
                width: _wSize.width / SIZEBOARD,
                height: _wSize.width / SIZEBOARD,
                decoration: BoxDecoration(),
                child: Image.asset(returnChessman(arr[i][j])),
              ),
              left: X,
              top: Y,
            ),
          );
        }
      }
    }
    if (isShowFocus == true) {
      var X = pos_x * size;
      var Y = pos_y * size;
      if (pos_x >= 1 &&
          pos_y >= 1 &&
          pos_x <= SIZEBOARD - 1 &&
          pos_y <= SIZEBOARD - 1 &&
          arr[pos_x.round()][pos_y.round()] == -1) {
        lstWg.add(new Positioned(
          child: Container(
            width: _wSize.width / SIZEBOARD,
            height: _wSize.width / SIZEBOARD,
            decoration: BoxDecoration(),
            child: Image.asset('assets/focus.png'),
          ),
          left: X,
          top: Y,
        ));
        rememberX = pos_x;
        rememberY = pos_y;
      } else {
        isShowFocus = false;
      }
    }
    return new Stack(children: lstWg);
  }

  _onTapDown(BuildContext context, TapDownDetails details) {
    if (graphics == Graphics.SHOW_MENU) {
      return;
    }
    scale = MatrixGestureDetector.decomposeToValues(_matrix4).scale;
    trans = MatrixGestureDetector.decomposeToValues(_matrix4).translation;
    var size = scale * _wSize.width / SIZEBOARD;
    var p = 0;
    print("${details.globalPosition}");
    final RenderBox _renderBoxBoard = context.findRenderObject();
    final Offset _offsetLocal =
        _renderBoxBoard.globalToLocal(details.globalPosition);
    setState(() {
      Offset _newPos = _offsetLocal - trans;
      print("newPos ${_newPos}");
      // convert to position of chessman
      var _posx = _newPos.dx - p - _left;
      var _posy = (_newPos.dy - height_user_info) - p;
      var X = (_posx - (_posx % size)) / size;
      var Y = (_posy - (_posy % size)) / size;
      posx = X * size;
      posy = Y * size;
      pos_x = X;
      pos_y = Y;
      print("$posx - $posy | $X - $Y");
      if (rememberX == X && rememberY == Y && isShowFocus == true) {
        msgPositionOfChessman();
        isShowFocus = false;
      } else {
        rememberX = X;
        rememberY = Y;
        print("remember ${rememberX} - ${rememberY} - ${isShowFocus}");
        isShowFocus = true;
      }
    });
  }

  Widget _gamemenu() {
    Widget widget;
    if (gameMenu == GameMenu.GAME_MENU) {
      if (isShowAd == false) {
        print("=============>>> SHOW AD");
        isShowAd = true;
        _bannerAd ??= createBannerAd();
        _bannerAd
          ..load()
          ..show();
      }
      widget = new Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
            ),
            height: _wSize.width,
            width: _wSize.width,
          ),
          Positioned(
            top: _wSize.width * (0.5 - 0.3),
            left: _wSize.width * (0.5 - 0.25),
            child: Container(
              height: _wSize.width * 0.6,
              width: _wSize.width * 0.5,
              decoration: BoxDecoration(
//                border: Border.all(color: Colors.black),
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        key = random.nextInt(9999) + 1000;
                        gameMenu = GameMenu.FINDING_OPPONENT;
                        showTime();
                      });
                      print("FRINDING RANK");
                      msgFindingMatchInRank();
                      if (globals.isSound && audioCache != null) {
                        audioCache.play(urlButtonClicked,
                            mode: PlayerMode.LOW_LATENCY);
                      }
                    },
                    child: Image.asset(
                        globals.getLocalization("BUTTON_RANKED_MATCH")),
                  ),
                  MaterialButton(
                    onPressed: () {
                      print("FRIEND MATCH");
                      setState(() {
                        key = random.nextInt(9999) + 1000;
                        gameMenu = GameMenu.FRIEND_MATCH;
                      });
                      if (globals.isSound && audioCache != null) {
                        audioCache.play(urlButtonClicked,
                            mode: PlayerMode.LOW_LATENCY);
                      }
                    },
                    child: Image.asset(
                        globals.getLocalization("BUTTON_FRIEND_MATCH")),
                  ),
                  MaterialButton(
                    onPressed: () {
                      print("vs COMPUTER");
                      setState(() {
                        key = random.nextInt(9999) + 1000;
                        gameMenu = GameMenu.FINDING_OPPONENT;
                      });
                      msgPlayWithAI();
                      if (globals.isSound && audioCache != null) {
                        audioCache.play(urlButtonClicked,
                            mode: PlayerMode.LOW_LATENCY);
                      }
                    },
                    child: Image.asset(
                        globals.getLocalization("BUTTON_BOT_MATCH")),
                  ),
                  MaterialButton(
                    onPressed: () {
                      print("RANKING");
                      if (globals.isSound && audioCache != null) {
                        audioCache.play(urlButtonClicked,
                            mode: PlayerMode.LOW_LATENCY);
                      }
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => new Ranking()));
                    },
                    child:
                        Image.asset(globals.getLocalization("BUTTON_RANKING")),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (gameMenu == GameMenu.FINDING_OPPONENT) {
      widget = new Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
            ),
            height: _wSize.width,
            width: _wSize.width,
          ),
          Positioned(
            top: _wSize.width / 4,
            left: _wSize.width / 4,
            child: Container(
              height: _wSize.width / 2,
              width: _wSize.width / 2,
              decoration: BoxDecoration(
//                border: Border.all(color: Colors.black),
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      print("FINDING OPPONENT");
                    },
                    child: Image.asset(
                        globals.getLocalization("BUTTON_FINDING_OPPONENT")),
                  ),
                  Text(
                    timeText,
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0),
                  ),
                  MaterialButton(
                    onPressed: () {
                      print("BACK");
                      offTime();
                      setState(() {
                        resetInfoOpponent();
                        key = random.nextInt(9999) + 1000;
                        gameMenu = GameMenu.GAME_MENU;
                      });
                      if (globals.isSound && audioCache != null) {
                        audioCache.play(urlButtonClicked,
                            mode: PlayerMode.LOW_LATENCY);
                      }
                    },
                    child: Image.asset(globals.getLocalization("BUTTON_BACK")),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (gameMenu == GameMenu.READY) {
      widget = new Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
            ),
            height: _wSize.width,
            width: _wSize.width,
          ),
          Positioned(
            top: _wSize.width / 4,
            left: _wSize.width / 4,
            child: Container(
              height: _wSize.width / 2,
              width: _wSize.width / 2,
              decoration: BoxDecoration(
//                border: Border.all(color: Colors.black),
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      print("READY");
                      setState(() {
                        gameMenu = GameMenu.WAITING_OPPONENT;
                      });
                      if (globals.isSound && audioCache != null) {
                        audioCache.play(urlButtonClicked,
                            mode: PlayerMode.LOW_LATENCY);
                      }
                      msgStart();
                    },
                    child: Image.asset(globals.getLocalization("BUTTON_READY")),
                  ),
                  MaterialButton(
                    onPressed: () {
                      print("BACK");
                      offTime();
                      setState(() {
                        resetInfoOpponent();
                        key = random.nextInt(9999) + 1000;
                        gameMenu = GameMenu.GAME_MENU;
                      });
                      if (globals.isSound && audioCache != null) {
                        audioCache.play(urlButtonClicked,
                            mode: PlayerMode.LOW_LATENCY);
                      }
                    },
                    child: Image.asset(globals.getLocalization("BUTTON_BACK")),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (gameMenu == GameMenu.WAITING_OPPONENT) {
      widget = new Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
            ),
            height: _wSize.width,
            width: _wSize.width,
          ),
          Positioned(
            top: _wSize.width / 4,
            left: _wSize.width / 4,
            child: Container(
              height: _wSize.width / 2,
              width: _wSize.width / 2,
              decoration: BoxDecoration(
//                border: Border.all(color: Colors.black),
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      print("READY");
                    },
                    child: Image.asset(
                        globals.getLocalization("BUTTON_WAITING_OPPONENT")),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (gameMenu == GameMenu.WINNER) {
      widget = new Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
            ),
            height: _wSize.width,
            width: _wSize.width,
          ),
          Positioned(
            top: _wSize.width / 4,
            left: _wSize.width / 4,
            child: Container(
              height: _wSize.width / 2,
              width: _wSize.width / 2,
              decoration: BoxDecoration(
//                border: Border.all(color: Colors.black),
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: _wSize.width * 0.1,
                        child: Text(
                          myScore,
                          textAlign: TextAlign.start,
                          style: textScore,
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      SizedBox(
                        width: _wSize.width * 0.1,
                        child: Text(opponentScore,
                            textAlign: TextAlign.end, style: textScore),
                      ),
                    ],
                  ),
                  MaterialButton(
                    onPressed: () {
                      print("WINNER");
                    },
                    child: Image.asset('assets/winner.png'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (gameMenu == GameMenu.LOSER) {
      widget = new Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
            ),
            height: _wSize.width,
            width: _wSize.width,
          ),
          Positioned(
            top: _wSize.width / 4,
            left: _wSize.width / 4,
            child: Container(
              height: _wSize.width / 2,
              width: _wSize.width / 2,
              decoration: BoxDecoration(
//                border: Border.all(color: Colors.black),
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: _wSize.width * 0.1,
                        child: Text(
                          myScore,
                          textAlign: TextAlign.start,
                          style: textScore,
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      SizedBox(
                        width: _wSize.width * 0.1,
                        child: Text(opponentScore,
                            textAlign: TextAlign.end, style: textScore),
                      ),
                    ],
                  ),
                  MaterialButton(
                    onPressed: () {
                      print("LOSER");
                    },
                    child: Image.asset('assets/loser.png'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (gameMenu == GameMenu.FRIEND_MATCH) {
      widget = new Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
            ),
            height: _wSize.width,
            width: _wSize.width,
          ),
          Positioned(
            top: _wSize.width / 4,
            left: _wSize.width / 4,
            child: Container(
              height: _wSize.width / 2,
              width: _wSize.width / 2,
              decoration: BoxDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      print("CREATE ROOM");
                      setState(() {
                        gameMenu = GameMenu.CREATE_ROOM;
                      });
                      msgFindingFriendMatch();
                      if (globals.isSound && audioCache != null) {
                        audioCache.play(urlButtonClicked,
                            mode: PlayerMode.LOW_LATENCY);
                      }
                    },
                    child: Image.asset(
                        globals.getLocalization("BUTTON_CREATE_ROOM")),
                  ),
                  MaterialButton(
                    onPressed: () {
                      print("JOIN ROOM");
                      setState(() {
                        gameMenu = GameMenu.JOIN_ROOM;
                      });
                      if (globals.isSound && audioCache != null) {
                        audioCache.play(urlButtonClicked,
                            mode: PlayerMode.LOW_LATENCY);
                      }
                    },
                    child: Image.asset(
                        globals.getLocalization("BUTTON_JOIN_ROOM")),
                  ),
                  MaterialButton(
                    onPressed: () {
                      print("BACK");
                      setState(() {
                        key = random.nextInt(9999) + 1000;
                        gameMenu = GameMenu.GAME_MENU;
                      });
                      if (globals.isSound && audioCache != null) {
                        audioCache.play(urlButtonClicked,
                            mode: PlayerMode.LOW_LATENCY);
                      }
                    },
                    child: Image.asset(globals.getLocalization("BUTTON_BACK")),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (gameMenu == GameMenu.WAITING_IN_ROOM) {
      widget = new Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
            ),
            height: _wSize.width,
            width: _wSize.width,
          ),
          Positioned(
            top: _wSize.width / 2 - _wSize.width / 1.5 / 2,
            left: _wSize.width / 2 - _wSize.width / 1.5 / 2,
            child: Container(
              height: _wSize.width / 1.5,
              width: _wSize.width / 1.5,
              decoration: BoxDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    globals.getLocalization("scrGamePlay_show_roomId_1"),
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.yellow,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    globals.getLocalization("scrGamePlay_show_roomId_2") +
                        "(${roomId})" +
                        globals.getLocalization("scrGamePlay_show_roomId_3"),
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.yellow,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  MaterialButton(
                    onPressed: () {
                      print("BACK");
                      msgCancelFriendMatch();
                      setState(() {
                        key = random.nextInt(9999) + 1000;
                        gameMenu = GameMenu.GAME_MENU;
                      });
                      if (globals.isSound && audioCache != null) {
                        audioCache.play(urlButtonClicked,
                            mode: PlayerMode.LOW_LATENCY);
                      }
                    },
                    child: SizedBox(
                      width: _wSize.width / 2.5,
                      child:
                          Image.asset(globals.getLocalization("BUTTON_BACK")),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (gameMenu == GameMenu.JOIN_ROOM) {
      widget = new Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
            ),
            height: _wSize.width,
            width: _wSize.width,
          ),
          Positioned(
            top: _wSize.width / 4,
            left: _wSize.width / 4,
            child: Container(
              height: _wSize.width / 2,
              width: _wSize.width / 2,
              decoration: BoxDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            globals
                                .getLocalization("scrGamePlay_connect_roomId"),
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.yellow,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            width: 60.0,
                            height: 20.0,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue)),
                            child: TextField(
                              obscureText: false,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Consolas',
                              ),
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 1),
                                  hintText: ""),
                              onChanged: (rid) {
                                roomId = int.parse(rid);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  MaterialButton(
                    onPressed: () {
                      print("CONNECT");
                      if (buttonPressed == false) {
                        setState(() {
                          buttonPressed = true;
                          timeoutPressButton = 4;
                        });
                        setTimeoutPressButton();
                        msgConnectingToRoom();
                        if (globals.isSound && audioCache != null) {
                          audioCache.play(urlButtonClicked,
                              mode: PlayerMode.LOW_LATENCY);
                        }
                      }
                    },
                    child: Image.asset(buttonPressed == true
                        ? globals.getLocalization("BUTTON_CONNECT_CLICKED")
                        : globals.getLocalization("BUTTON_CONNECT")),
                  ),
                  MaterialButton(
                    onPressed: () {
                      print("BACK");
                      setState(() {
                        key = random.nextInt(9999) + 1000;
                        gameMenu = GameMenu.GAME_MENU;
                      });
                      if (globals.isSound && audioCache != null) {
                        audioCache.play(urlButtonClicked,
                            mode: PlayerMode.LOW_LATENCY);
                      }
                    },
                    child: Image.asset(globals.getLocalization("BUTTON_BACK")),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      widget = new Container(
        height: 0.1,
        width: 0.1,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
        ),
      );
    }
    return widget;
  }

  void onTapChatId(int id) {
    if (globals.isSound && audioCache != null) {
      audioCache.play(urlButtonClicked, mode: PlayerMode.LOW_LATENCY);
    }
    print("Send msg with : $id");
    var msg = "CHAT|ICON|${roomId}|${globals.username}|$id|" + CRLF + CRLF;
    if (socket != null && roomId != null && roomId > 0) {
      print(msg);
      socket.write(msg);
    }
    setState(() {
      timeoutChat = 3;
      idChatIcon = id;
      setTimeoutChat();
    });
  }

  void onTapChatMsg(String msgChat) {
    if (globals.isSound && audioCache != null) {
      audioCache.play(urlButtonClicked, mode: PlayerMode.LOW_LATENCY);
    }
    print("Send msg with : $msgChat");
    var msg = "CHAT|MSG|${roomId}|${globals.username}|$msgChat|" + CRLF + CRLF;
    if (socket != null && roomId != null && roomId > 0) {
      print(msg);
      socket.write(msg);
    }
    setState(() {
      timeoutChat = 3;
      setTimeoutChat();
    });
  }

  getAssestChatIcon(int id) {
    String iconStr = "";
    switch (id) {
      case 1:
        iconStr = "assets/conga.gif";
        break;
      case 2:
        iconStr = "assets/haha.gif";
        break;
      case 3:
        iconStr = "assets/haha2.gif";
        break;
      case 4:
        iconStr = "assets/hihi.gif";
        break;
      case 5:
        iconStr = "assets/luom.gif";
        break;
      case 6:
        iconStr = "assets/ngacnhien.gif";
        break;
      case 7:
        iconStr = "assets/nhindeu.gif";
        break;
      case 8:
        iconStr = "assets/nuocmat.gif";
        break;
      case 9:
        iconStr = "assets/raihoa.gif";
        break;
      case 10:
        iconStr = "assets/ram.gif";
        break;
      case 11:
        iconStr = "assets/tim2.gif";
        break;
      case 12:
        iconStr = "assets/yeu.gif";
        break;
      case 13:
        iconStr = "assets/accept.gif";
        break;
      case 14:
        iconStr = "assets/bye.gif";
        break;
      case 15:
        iconStr = "assets/cay.gif";
        break;
      case 16:
        iconStr = "assets/colen.gif";
        break;
      case 17:
        iconStr = "assets/lamquen.gif";
        break;
    }
    return iconStr;
  }

  getAssestChatIconPNG(int id) {
    String iconStr = "";
    switch (id) {
      case 1:
        iconStr = "assets/conga.png";
        break;
      case 2:
        iconStr = "assets/haha.png";
        break;
      case 3:
        iconStr = "assets/haha2.png";
        break;
      case 4:
        iconStr = "assets/hihi.png";
        break;
      case 5:
        iconStr = "assets/luom.png";
        break;
      case 6:
        iconStr = "assets/ngacnhien.png";
        break;
      case 7:
        iconStr = "assets/nhindeu.png";
        break;
      case 8:
        iconStr = "assets/nuocmat.png";
        break;
      case 9:
        iconStr = "assets/raihoa.png";
        break;
      case 10:
        iconStr = "assets/ram.png";
        break;
      case 11:
        iconStr = "assets/tim2.png";
        break;
      case 12:
        iconStr = "assets/yeu.png";
        break;
      case 13:
        iconStr = "assets/accept.png";
        break;
      case 14:
        iconStr = "assets/bye.png";
        break;
      case 15:
        iconStr = "assets/cay.png";
        break;
      case 16:
        iconStr = "assets/colen.png";
        break;
      case 17:
        iconStr = "assets/lamquen.png";
        break;
    }
    return iconStr;
  }

  Widget chatId(int id) {
    String iconStr = getAssestChatIconPNG(id);
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (timeoutChat <= 0) {
              onTapChatId(id);
            }
          },
          child: Container(
            height: widthMaxChatIcon,
            width: widthMaxChatIcon,
            decoration: BoxDecoration(),
            child: Image.asset(iconStr),
          ),
        ),
      ],
    );
  }

  Widget chatMsg() {
    String iconStr = "assets/chat.png";
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (globals.isSound && audioCache != null) {
              audioCache.play(urlButtonClicked, mode: PlayerMode.LOW_LATENCY);
            }
            if (gameMenu == GameMenu.PLAYING) {
              isShowChat = true;
              FocusScope.of(context).requestFocus(focusChat);
            }
          },
          child: Container(
            height: widthMaxChatIcon,
            width: widthMaxChatIcon,
            decoration: BoxDecoration(),
            child: Image.asset(iconStr),
          ),
        ),
      ],
    );
  }

  Widget _draw() {
    Widget widget;
    if (graphics == Graphics.SHOW_MENU) {
      widget = new Container(
          decoration: BoxDecoration(),
          height: _wSize.width,
          width: _wSize.width,
          child: Container(
            decoration: BoxDecoration(),
            child: Stack(
              children: <Widget>[
                drawChessmanOnBoard(),
                _gamemenu(),
              ],
            ),
          ));
    } else if (graphics == Graphics.PLAYING) {
      widget = new MatrixGestureDetector(
        shouldRotate: false,
        onMatrixUpdate: (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {
          setState(() {
            _matrix4 = m;
          });
        },
        child: Transform(
          transform: _matrix4,
          child: Container(
            decoration: BoxDecoration(),
            height: _wSize.width,
            width: _wSize.width,
            child: Container(
              decoration: BoxDecoration(),
              child: drawChessmanOnBoard(),
            ),
          ),
        ),
      );
    }
    return widget;
  }

  Widget showMyChat(int id) {
    if (id <= 0) {
      return new Container();
    }
    return new Positioned(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: HEIGHT_USER_INFO * 0.45,
            width: HEIGHT_USER_INFO * 0.45,
            decoration: BoxDecoration(
//              color: Colors.white,
                ),
            child: Image.asset(getAssestChatIcon(id)),
          )
        ],
      ),
    );
  }

  Widget showOpponentChat(int id) {
    if (id <= 0) {
      return new Container();
    }
    return new Positioned(
      left: HEIGHT_USER_INFO * 0.45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: HEIGHT_USER_INFO * 0.45,
            width: HEIGHT_USER_INFO * 0.45,
            decoration: BoxDecoration(
//              color: Colors.white,
                ),
            child: Image.asset(getAssestChatIcon(id)),
          )
        ],
      ),
    );
  }

  Widget managerInviteBox() {
    Widget widgetInviteBox;
    if (isShowInviteBox == false) {
      widgetInviteBox = new Container();
    } else {
      widgetInviteBox = Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        height: HEIGHT_ICON_CHAT,
        width: _wSize.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                Center(
                    child: Text(
                  "Bạn có một yêu cầu thách đấu ? ($timeoutCloseInvite s)",
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                )),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "(Lưu ý : Đồng ý sẽ ",
                        style: TextStyle(
                            fontSize: 15, color: Colors.deepOrangeAccent),
                      ),
                      Text(
                        "KHÔNG ",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.deepOrangeAccent,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "mất sao trận hiện tại.)",
                        style: TextStyle(
                            fontSize: 15, color: Colors.deepOrangeAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.lightGreenAccent,
                      size: 30,
                    ),
                  ),
                  onTap: () {
                    if (globals.isSound && audioCache != null) {
                      audioCache.play(urlButtonClicked,
                          mode: PlayerMode.LOW_LATENCY);
                    }
                    msgKeepStar();
                    setState(() {
                      isShowInviteBox = false;
                      timeout = 0;
                      resetInfoOpponent();
                      if (timer != null) timer.cancel();
                    });
                    sleep(const Duration(milliseconds: 500));
                    msgAcceptInvite();
                    sleep(const Duration(milliseconds: 500));
                  },
                ),
                GestureDetector(
                  child: Container(
                      decoration: BoxDecoration(),
                      child: Icon(
                        Icons.cancel,
                        color: Colors.redAccent,
                        size: 30,
                      )),
                  onTap: () {
                    if (globals.isSound && audioCache != null) {
                      audioCache.play(urlButtonClicked,
                          mode: PlayerMode.LOW_LATENCY);
                    }
                    setState(() {
                      isShowInviteBox = false;
                      msgCancelInvite();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }
    return widgetInviteBox;
  }

  Widget managerChatBox() {
    Widget widgetShowSettingBox;
    if (isShowSetting == false) {
      widgetShowSettingBox = new Container();
    } else {
      widgetShowSettingBox = new Positioned(
        top: HEIGHT_ICON_CHAT * 0.025,
        left: _wSize.width * 0.25,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
          height: HEIGHT_ICON_CHAT * 0.95,
          width: _wSize.width * 0.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
//                    border: Border.all(color: Colors.red),
                      ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            globals.getLocalization("scrGamePlay_vibrate"),
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            globals.getLocalization("scrGamePlay_sound"),
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              print("Vibrate");
                              if (globals.isVibrate == false) {
                                Vibrate.vibrate();
                              }
                              if (globals.isSound && audioCache != null) {
                                audioCache.play(urlButtonClicked,
                                    mode: PlayerMode.LOW_LATENCY);
                              }
                              setState(() {
                                globals.isVibrate = !globals.isVibrate;
                              });
                            },
                            child: Icon(
                              Icons.vibration,
                              color:
                                  globals.isVibrate ? Colors.blue : Colors.grey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              print("Sound");
                              if (globals.isSound == false &&
                                  audioCache != null) {
                                audioCache.play(urlButtonClicked,
                                    mode: PlayerMode.LOW_LATENCY);
                              }
                              setState(() {
                                globals.isSound = !globals.isSound;
                              });
                            },
                            child: Icon(
                              Icons.music_note,
                              color:
                                  globals.isSound ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: _wSize.width * 0.5 * 1 / 4,
                decoration: BoxDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(),
                        child: Icon(
                          Icons.language,
                          color: Colors.teal,
                          size: 30.0,
                        ),
                      ),
                      onTap: () {
                        if (globals.isSound && audioCache != null) {
                          audioCache.play(urlButtonClicked,
                              mode: PlayerMode.LOW_LATENCY);
                        }
                        setState(() {
                          globals.language =
                              ("EN".compareTo(globals.language) == 0
                                  ? "VI"
                                  : "EN");
                        });
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(),
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 30.0,
                        ),
                      ),
                      onTap: () {
                        if (globals.isSound && audioCache != null) {
                          audioCache.play(urlButtonClicked,
                              mode: PlayerMode.LOW_LATENCY);
                        }
                        setState(() {
                          isShowSetting = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return new Stack(
      children: <Widget>[
        Container(
          height: HEIGHT_ICON_CHAT,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: Colors.blue[100],
                            width: 1.0,
                            style: BorderStyle.solid)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                chatMsg(),
                                chatId(4),
                                chatId(9),
                                chatId(15),
                                chatId(2),
                                chatId(14),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                chatId(7),
                                chatId(8),
                                chatId(5),
                                chatId(10),
                                chatId(16),
                                chatId(12),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: Colors.blue[100],
                              width: 1.0,
                              style: BorderStyle.solid)),
                    ),
                    width: widthMaxChatIcon * 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            print("setting");
                            if (globals.isSound && audioCache != null) {
                              audioCache.play(urlButtonClicked,
                                  mode: PlayerMode.LOW_LATENCY);
                            }
                            setState(() {
                              isShowSetting = !isShowSetting;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                child: Icon(
                                  Icons.settings,
                                  color: Colors.lightBlueAccent,
                                  size: widthMaxChatIcon,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            print("logout");
                            if (globals.isSound && audioCache != null) {
                              audioCache.play(urlButtonClicked,
                                  mode: PlayerMode.LOW_LATENCY);
                            }
                            resetInfoOpponent();
                            if (_bannerAd != null) {
                              _bannerAd?.dispose();
                            }
                            _bannerAd = null;
                            if (socket != null) {
                              socket.destroy();
                            }
                            resetDowncount();
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                child: Icon(
                                  Icons.home,
                                  color: Colors.lightBlueAccent,
                                  size: widthMaxChatIcon,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        widgetShowSettingBox,
        managerInviteBox(),
      ],
    );
  }

  setResolutionMax() {
    if (_wSize.width > MAX_HEIGHT) {
      _left = (_wSize.width - MAX_HEIGHT) / 2;
      print("MAX W : ${_wSize.width} | Left  : ${_left}");
      _wSize = new Size(MAX_HEIGHT, _wSize.height);
    }
  }

  @override
  Widget build(BuildContext context) {
//    if (isShowAd == false) {
//      isShowAd = true;
//      String appId = "";
//      if (Platform.isIOS) {
//        print("### IOS init");
//        appId = "ca-app-pub-6954823977438177~4546625223";
//      } else {
//        print("### Android init");
//        appId = "ca-app-pub-6954823977438177~7438875277";
//      }
//
//      FirebaseAdMob.instance.initialize(appId: appId).then((response) {
//        _bannerAd
//          ..load()
//          ..show();
//      });
////      if (isShowAd == false) {
////        isShowAd = true;
////        _bannerAd ??= createBannerAd();
////        _bannerAd
////          ..load()
////          ..show(
////            anchorType: AnchorType.bottom,
////          );
////      }
//    }
    _wSize = MediaQuery.of(context).size;
    setResolutionMax();
    HEIGHT_BOARD = _wSize.width;
    HEIGHT_USER_INFO = (_wSize.height - _wSize.width) * 0.46;
    if (HEIGHT_USER_INFO > _wSize.width) {
      print(
          "HEIGHT_USER_INFO ? _wSize.width | ${HEIGHT_USER_INFO} , ${_wSize.width}");
      HEIGHT_USER_INFO = _wSize.width;
    }
    HEIGHT_ICON_CHAT = (_wSize.height - _wSize.width) * 0.29;
    HEIGHT_ADS = (_wSize.height - _wSize.width) * 0.25;
    widthMaxChatIcon = HEIGHT_ICON_CHAT * 0.45;
    height_user_info = HEIGHT_USER_INFO;
    int numOfLineIcon = 6;
    if (widthMaxChatIcon * numOfLineIcon >
        (_wSize.width - HEIGHT_ICON_CHAT * 1.2)) {
      widthMaxChatIcon =
          (_wSize.width - HEIGHT_ICON_CHAT * 1.2) / numOfLineIcon;
    }
    if (isRandomChessman == false) {
      isRandomChessman = true;
      arr = _randomChessman();
    }

    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Widget gameUI = Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: HEIGHT_USER_INFO,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[100]),
//                      color: Colors.grey,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              GestureDetector(
                                onTapDown: (td) {
                                  print("My info show");
                                  if (globals.isSound && audioCache != null) {
                                    audioCache.play(urlButtonClicked,
                                        mode: PlayerMode.LOW_LATENCY);
                                  }
                                  setState(() {
                                    globals.isShowFullMyInfo = true;
                                  });
                                },
                                onTapUp: (tu) {
                                  print("My info hide");
                                  setState(() {
                                    globals.isShowFullMyInfo = false;
                                  });
                                },
                                onPanStart: (ps) {
                                  print("My info hide");
                                  setState(() {
                                    globals.isShowFullMyInfo = false;
                                  });
                                },
                                child: Stack(
                                  children: <Widget>[
                                    Positioned(
                                      child: Row(
                                        children: gp.GamePart().getMyInfo(
                                            HEIGHT_USER_INFO,
                                            showChatId: idChatIcon),
                                      ),
                                    ),
                                    showMyChat(idChatIcon),
                                  ],
                                ),
                              ),
                              Row(
                                children: gp.GamePart().getMyRankInfo(
                                    globals.score, HEIGHT_USER_INFO),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  myTurn != 0
                                      ? Container(
                                          height: HEIGHT_USER_INFO * 0.06,
                                          width: _wSize.width / 3,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: (myTurn == 0
                                                    ? Colors.white
                                                    : Colors.red)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              Container(
                                                height: HEIGHT_USER_INFO * 0.05,
                                                width:
                                                    (_wSize.width / 3 - 2.0) *
                                                        timeout /
                                                        30 *
                                                        myTurn,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          height: HEIGHT_USER_INFO * 0.06,
                                        ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            // opponent
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  GestureDetector(
                                    onTapDown: (td) {
                                      print("Opponent info show");
                                      if (globals.isSound &&
                                          audioCache != null) {
                                        audioCache.play(urlButtonClicked,
                                            mode: PlayerMode.LOW_LATENCY);
                                      }
                                      setState(() {
                                        globals.isShowFullOpponentInfo = true;
                                      });
                                    },
                                    onTapUp: (tu) {
                                      print("Opponent info hide");
                                      setState(() {
                                        globals.isShowFullOpponentInfo = false;
                                      });
                                    },
                                    onPanStart: (ps) {
                                      print("Opponent info hide");
                                      setState(() {
                                        globals.isShowFullOpponentInfo = false;
                                      });
                                    },
                                    child: Stack(
                                      children: <Widget>[
                                        Positioned(
                                          child: Row(
                                            children: gp.GamePart()
                                                .getOpponentInfo(
                                                    HEIGHT_USER_INFO,
                                                    showChatId:
                                                        idChatIconOpponent),
                                          ),
                                        ),
                                        showOpponentChat(idChatIconOpponent),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: gp.GamePart().getOpponentRank(
                                        globals.scoreOpponent,
                                        HEIGHT_USER_INFO),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      opponentTurn != 0
                                          ? Container(
                                              height: HEIGHT_USER_INFO * 0.06,
                                              width: _wSize.width / 3,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: (opponentTurn == 0
                                                        ? Colors.white
                                                        : Colors.red)),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    height:
                                                        HEIGHT_USER_INFO * 0.05,
                                                    width: (_wSize.width / 3 -
                                                            2.0) *
                                                        timeout /
                                                        30 *
                                                        opponentTurn,
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              height: HEIGHT_USER_INFO * 0.06,
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    children: <Widget>[
                      // Board
                      GestureDetector(
                        onTapDown: (details) => _onTapDown(context, details),
//                      onDoubleTap: _onDoubleTap,
                        child: Container(
                          decoration: BoxDecoration(
//                        border: Border.all(color: Colors.blue),
                              ),
                          height: HEIGHT_BOARD,
                          width: HEIGHT_BOARD,
                          child: _draw(),
                        ),
                      ),
                      managerChatBox(),
                      Expanded(
                        // Ads
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image:
                                            AssetImage("assets/banner_ad.png"),
                                        fit: BoxFit.fill)),
                              ),
//                            child: new Text("Ads : ${_wSize.width} - ${_wSize.height} | ${posx.round()} - ${posy.round()}"),
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
          gp.GamePart().getFullInfoUser(_wSize),
        ],
      ),
    );

    Widget chatUI = Positioned(
      top: _wSize.height -
          (gameMenu != GameMenu.PLAYING
              ? 0
              : MediaQuery.of(context).viewInsets.bottom) -
          (isShowChat ? 40 : 0),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white, border: Border.all(color: Colors.grey)),
          width: _wSize.width,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
//                    width: _wSize.width * 0.85,
                  height: 40.0,
                  child: TextField(
                    controller: _controller,
                    obscureText: false,
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Consolas',
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                      border: InputBorder.none,
                      hintText: "Message",
//                      suffixIcon:
                    ),
                    onChanged: (msg) {
                      msgChat = msg.replaceAll("|", "");
                    },
                    focusNode: focusChat,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.teal,
                ),
                onPressed: () {
                  setState(() {
                    msgChat = "";
                    this._controller.clear();
                  });
                },
              ),
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  if (msgChat.length > 0) {
                    onTapChatMsg(msgChat);
                    _controller.clear();
                    setState(() {
                      isShowMyChatText = true;
                      isShowChatBox = true;
                      tempMsgChat = msgChat;
                      msgChat = "";
                      isShowChat = false;
                    });
                  }
                },
                child: Container(
                    height: 40,
                    width: _wSize.width * 0.15,
                    decoration: BoxDecoration(color: Colors.lightBlue),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          "SEND",
                          style: TextStyle(
                              color: Colors.white,
                              backgroundColor: Colors.lightBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    )),
              )
            ],
          )),
    );

    Widget showChatUI = Positioned(
      top: HEIGHT_USER_INFO * 0.45,
      child: Container(
        decoration: BoxDecoration(),
        height: HEIGHT_USER_INFO * 0.55,
        width: _wSize.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            isShowChatBox
                ? Container(
                    decoration: BoxDecoration(),
                    width: _wSize.width * 0.6,
                    height: HEIGHT_USER_INFO * 0.4,
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Stack(
                      children: <Widget>[
                        Image.asset(isShowMyChatText
                            ? "assets/chatbox_my.png"
                            : "assets/chatbox_opponent.png"),
                        Positioned(
                          left: _wSize.width * 0.07,
                          top: HEIGHT_USER_INFO * 0.07,
                          child: SizedBox(
                            width: _wSize.width * 0.4,
                            height: HEIGHT_USER_INFO * 0.3,
                            child: Text(
                              tempMsgChat,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
//            Expanded(
//              child: Container(
//                decoration: BoxDecoration(),
//              ),
//            ),
//            Container(
//              decoration: BoxDecoration(),
//              width: _wSize.width * 0.1,
//              height: HEIGHT_USER_INFO * 0.3,
//              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
//              child: Text(
//                opponentScore,
//                style: TextStyle(
//                    color: Colors.yellow,
//                    fontWeight: FontWeight.bold,
//                    fontSize: 25),
//                textAlign: TextAlign.end,
//              ),
//            )
          ],
        ),
      ),
    );

    return Material(
        child: Stack(
      children: <Widget>[
        gameUI,
        chatUI,
        showChatUI,
      ],
    ));
  }

  void checkCaro() {
    List<List<int>> arrayCheck = _initState();
    const numberChessmanWin = 5;
    for (var i = 1; i < SIZEBOARD; i++) {
      for (var j = 1; j < SIZEBOARD; j++) {
        // kiem tra chieu ngang
        var count = 0;
        for (var ii = i; ii < i + numberChessmanWin && ii < SIZEBOARD; ii++) {
          if (ii == i) {
            // First
            count++;
            continue;
          }
          if (arr[i][j] == arr[ii][j]) {
            count++;
          } else {
            break;
          }
          if (count == numberChessmanWin) {
            for (var ii = i;
                ii < i + numberChessmanWin && ii < SIZEBOARD;
                ii++) {
              arrayCheck[ii][j] = 1;
            }
          }
        }
        // kiem tra chieu doc
        count = 0;
        for (var jj = j; jj < j + numberChessmanWin && jj < SIZEBOARD; jj++) {
          if (jj == j) {
            count++;
            continue;
          }
          if (arr[i][j] == arr[i][jj]) {
            count++;
          } else {
            break;
          }
          if (count == numberChessmanWin) {
            for (var jj = j;
                jj < j + numberChessmanWin && jj < SIZEBOARD;
                jj++) {
              arrayCheck[i][jj] = 1;
            }
          }
        }
        // kiem tra duong cheo /
        count = 0;
        if (i >= numberChessmanWin && j < SIZEBOARD - numberChessmanWin + 1) {
          for (var c = 0; c < numberChessmanWin; c++) {
            if (c == 0) {
              count++;
              continue;
            }
            if (arr[i][j] == arr[i - c][j + c]) {
              count++;
            } else {
              break;
            }
            if (count == numberChessmanWin) {
              for (var c = 0; c < numberChessmanWin; c++) {
                arrayCheck[i - c][j + c] = 1;
              }
            }
          }
        }
        // kiem tra cheo \
        count = 0;
        if (i < SIZEBOARD - numberChessmanWin + 1 &&
            j < SIZEBOARD - numberChessmanWin + 1) {
          for (var c = 0; c < numberChessmanWin; c++) {
            if (c == 0) {
              count++;
              continue;
            }
            if (arr[i][j] == arr[i + c][j + c]) {
              count++;
            } else {
              break;
            }
            if (count == numberChessmanWin) {
              for (var c = 0; c < numberChessmanWin; c++) {
                arrayCheck[i + c][j + c] = 1;
              }
            }
          }
        }
      }
    }
    // Set chessman winner.
    for (var i = 0; i < SIZEBOARD; i++) {
      for (var j = 0; j < SIZEBOARD; j++) {
        if (arrayCheck[i][j] != -1) {
          if (arr[i][j] == 1) {
            arr[i][j] = 2;
          } else if (arr[i][j] == 0) {
            arr[i][j] = 3;
          }
        }
      }
    }
  }
}
