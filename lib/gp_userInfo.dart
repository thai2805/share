import 'objres.dart';
import 'package:flutter/material.dart';
import 'globals.dart' as globals;

class GamePart {
  // link resource for rank
  String RANK_BRONZE = "assets/rank_dong.png";
  String RANK_SILVER = "assets/rank_bac.png";
  String RANK_GOLD = "assets/rank_vang.png";
  String RANK_PLATINUM = "assets/rank_bachkim.png";
  String RANK_DIAMOND = "assets/rank_kimcuong.png";
  String RANK_VETERAN = "assets/rank_tinhanh.png";
  String RANK_MASTER = "assets/rank_caothu.png";
  String STAR = "assets/star.png";
  String STAR_BLACK = "assets/star_den.png";
  int STAR_RANK_BRONZE = 3;
  int STAR_RANK_SILVER = 4;
  int STAR_RANK_GOLD = 4;
  int STAR_RANK_PLATINUM = 5;
  int STAR_RANK_DIAMOND = 5;
  int STAR_RANK_VETERAN = 5;
  int LEVEL_RANK_BRONZE = 3;
  int LEVEL_RANK_SILVER = 3;
  int LEVEL_RANK_GOLD = 4;
  int LEVEL_RANK_PLATINUM = 5;
  int LEVEL_RANK_DIAMOND = 5;
  int LEVEL_RANK_VETERAN = 5;
  int TOTAL_STAR_UP_RANK_BRONZE = 10;
  int TOTAL_STAR_UP_RANK_SILVER = 22;
  int TOTAL_STAR_UP_RANK_GOLD = 38;
  int TOTAL_STAR_UP_RANK_PLATINUM = 63;
  int TOTAL_STAR_UP_RANK_DIAMOND = 88;
  int TOTAL_STAR_UP_RANK_VETERAN = 113;

  TextStyle textStyleForNameGamer =
      TextStyle(color: Colors.white, fontSize: 15.0);
  TextStyle textStyleForRank =
      TextStyle(color: Colors.white, fontSize: 17.0);


  List<Widget> getMyInfo(double HEIGHT_USER_INFO, {int showChatId = 0}) {
    List<Widget> lst = new List<Widget>();
    lst.add(new Container(
      height: HEIGHT_USER_INFO * 0.45,
      width: HEIGHT_USER_INFO * 0.45,
      decoration: BoxDecoration(
//        border: Border.all(color: Colors.blueGrey[100]),
//        color: Colors.white,
          ),
      child: (showChatId <= 0)
          ? Image.asset('assets/${globals.linkAvatar}')
          : Container(),
    ));
    lst.add(new SizedBox(
        width: HEIGHT_USER_INFO * 0.45,
        child: Text(
          globals.displayName,
          textAlign: TextAlign.center,
          style: textStyleForNameGamer
        )));
    return lst;
  }

  List<Widget> getOpponentInfo(double HEIGHT_USER_INFO, {int showChatId = 0}) {
    List<Widget> lst = List<Widget>();
    lst.add(new SizedBox(
      width: HEIGHT_USER_INFO * 0.45,
      child: Text(
        globals.displayNameOpponent,
        textAlign: TextAlign.center,
        style: textStyleForNameGamer
      ),
    ));
    lst.add(new Container(
      height: HEIGHT_USER_INFO * 0.45,
      width: HEIGHT_USER_INFO * 0.45,
      decoration: BoxDecoration(
//        border: Border.all(color: Colors.blueGrey[100]),
//        color: Colors.white,
          ),
      child: (showChatId <= 0)
          ? Image.asset(
              'assets/${globals.linkAvatarOpponent ?? "img_avatar_2.png"}')
          : Container(),
    ));
    return lst;
  }

  getImgRank(int score) {
    if (score < 0) {
      return "";
    } else if (score >= 0 && score < TOTAL_STAR_UP_RANK_BRONZE) {
      return RANK_BRONZE;
    } else if (score >= TOTAL_STAR_UP_RANK_BRONZE &&
        score < TOTAL_STAR_UP_RANK_SILVER) {
      return RANK_SILVER;
    } else if (score >= TOTAL_STAR_UP_RANK_SILVER &&
        score < TOTAL_STAR_UP_RANK_GOLD) {
      return RANK_GOLD;
    } else if (score >= TOTAL_STAR_UP_RANK_GOLD &&
        score < TOTAL_STAR_UP_RANK_PLATINUM) {
      return RANK_PLATINUM;
    } else if (score >= TOTAL_STAR_UP_RANK_PLATINUM &&
        score < TOTAL_STAR_UP_RANK_DIAMOND) {
      return RANK_DIAMOND;
    } else if (score >= TOTAL_STAR_UP_RANK_DIAMOND &&
        score < TOTAL_STAR_UP_RANK_VETERAN) {
      return RANK_VETERAN;
    } else if (score >= TOTAL_STAR_UP_RANK_VETERAN) {
      return RANK_MASTER;
    }
    return "";
  }

  getAltImgRank(int score) {
    if (score < 0) {
      return "";
    } else if (score >= 0 && score < TOTAL_STAR_UP_RANK_BRONZE) {
      return globals.getLocalization("global_rank_bronze");
    } else if (score >= TOTAL_STAR_UP_RANK_BRONZE &&
        score < TOTAL_STAR_UP_RANK_SILVER) {
      return globals.getLocalization("global_rank_silver");
    } else if (score >= TOTAL_STAR_UP_RANK_SILVER &&
        score < TOTAL_STAR_UP_RANK_GOLD) {
      return globals.getLocalization("global_rank_gold");
    } else if (score >= TOTAL_STAR_UP_RANK_GOLD &&
        score < TOTAL_STAR_UP_RANK_PLATINUM) {
      return globals.getLocalization("global_rank_platinum");
    } else if (score >= TOTAL_STAR_UP_RANK_PLATINUM &&
        score < TOTAL_STAR_UP_RANK_DIAMOND) {
      return globals.getLocalization("global_rank_diamond");
    } else if (score >= TOTAL_STAR_UP_RANK_DIAMOND &&
        score < TOTAL_STAR_UP_RANK_VETERAN) {
      return globals.getLocalization("global_rank_veteran");
    } else if (score >= TOTAL_STAR_UP_RANK_VETERAN) {
      return globals.getLocalization("global_rank_master");
    }
    return "";
  }

  List<Widget> getRankLevel(int score) {
    List<Widget> resRankStar = new List<Widget>();
    if (score < 0) {
      return resRankStar;
    } else if (score == 0) {
      resRankStar = getRankStar(score, 3, 1, 3);
    } else if (1 <= score && score <= 3) {
      resRankStar = getRankStar(score, 3, 1, 3);
    } else if (4 <= score && score <= 6) {
      resRankStar = getRankStar(score, 2, 4, 6);
    } else if (7 <= score && score <= 9) {
      resRankStar = getRankStar(score, 1, 7, 9);
    } else if (10 <= score && score <= 13) {
      resRankStar = getRankStar(score, 3, 10, 13);
    } else if (14 <= score && score <= 17) {
      resRankStar = getRankStar(score, 2, 14, 17);
    } else if (18 <= score && score <= 21) {
      resRankStar = getRankStar(score, 1, 18, 21);
    } else if (22 <= score && score <= 25) {
      resRankStar = getRankStar(score, 4, 22, 25);
    } else if (26 <= score && score <= 29) {
      resRankStar = getRankStar(score, 3, 26, 29);
    } else if (30 <= score && score <= 33) {
      resRankStar = getRankStar(score, 2, 30, 33);
    } else if (34 <= score && score <= 37) {
      resRankStar = getRankStar(score, 1, 34, 37);
    } else if (38 <= score && score <= 42) {
      resRankStar = getRankStar(score, 5, 38, 42);
    } else if (43 <= score && score <= 47) {
      resRankStar = getRankStar(score, 4, 43, 47);
    } else if (48 <= score && score <= 52) {
      resRankStar = getRankStar(score, 3, 48, 52);
    } else if (53 <= score && score <= 57) {
      resRankStar = getRankStar(score, 2, 53, 57);
    } else if (58 <= score && score <= 62) {
      resRankStar = getRankStar(score, 1, 58, 62);
    } else if (63 <= score && score <= 67) {
      resRankStar = getRankStar(score, 5, 63, 67);
    } else if (68 <= score && score <= 72) {
      resRankStar = getRankStar(score, 4, 68, 72);
    } else if (73 <= score && score <= 77) {
      resRankStar = getRankStar(score, 3, 73, 77);
    } else if (78 <= score && score <= 82) {
      resRankStar = getRankStar(score, 2, 78, 82);
    } else if (83 <= score && score <= 87) {
      resRankStar = getRankStar(score, 1, 83, 87);
    } else if (88 <= score && score <= 92) {
      resRankStar = getRankStar(score, 5, 88, 92);
    } else if (93 <= score && score <= 97) {
      resRankStar = getRankStar(score, 4, 93, 97);
    } else if (98 <= score && score <= 102) {
      resRankStar = getRankStar(score, 3, 98, 102);
    } else if (103 <= score && score <= 107) {
      resRankStar = getRankStar(score, 2, 103, 107);
    } else if (108 <= score && score <= 112) {
      resRankStar = getRankStar(score, 1, 108, 112);
    } else if (113 <= score) {
      resRankStar = getRankStar(score, 1, 113, 113);
    }
    return resRankStar;
  }

  List<Widget> getRankLevel4Profile(int score) {
    List<Widget> resRankStar = new List<Widget>();
    if (score < 0) {
      return resRankStar;
    } else if (score == 0) {
      resRankStar = getRankStar4Profile(score, 3, 1, 3);
    } else if (1 <= score && score <= 3) {
      resRankStar = getRankStar4Profile(score, 3, 1, 3);
    } else if (4 <= score && score <= 6) {
      resRankStar = getRankStar4Profile(score, 2, 4, 6);
    } else if (7 <= score && score <= 9) {
      resRankStar = getRankStar4Profile(score, 1, 7, 9);
    } else if (10 <= score && score <= 13) {
      resRankStar = getRankStar4Profile(score, 3, 10, 13);
    } else if (14 <= score && score <= 17) {
      resRankStar = getRankStar4Profile(score, 2, 14, 17);
    } else if (18 <= score && score <= 21) {
      resRankStar = getRankStar4Profile(score, 1, 18, 21);
    } else if (22 <= score && score <= 25) {
      resRankStar = getRankStar4Profile(score, 4, 22, 25);
    } else if (26 <= score && score <= 29) {
      resRankStar = getRankStar4Profile(score, 3, 26, 29);
    } else if (30 <= score && score <= 33) {
      resRankStar = getRankStar4Profile(score, 2, 30, 33);
    } else if (34 <= score && score <= 37) {
      resRankStar = getRankStar4Profile(score, 1, 34, 37);
    } else if (38 <= score && score <= 42) {
      resRankStar = getRankStar4Profile(score, 5, 38, 42);
    } else if (43 <= score && score <= 47) {
      resRankStar = getRankStar4Profile(score, 4, 43, 47);
    } else if (48 <= score && score <= 52) {
      resRankStar = getRankStar4Profile(score, 3, 48, 52);
    } else if (53 <= score && score <= 57) {
      resRankStar = getRankStar4Profile(score, 2, 53, 57);
    } else if (58 <= score && score <= 62) {
      resRankStar = getRankStar4Profile(score, 1, 58, 62);
    } else if (63 <= score && score <= 67) {
      resRankStar = getRankStar4Profile(score, 5, 63, 67);
    } else if (68 <= score && score <= 72) {
      resRankStar = getRankStar4Profile(score, 4, 68, 72);
    } else if (73 <= score && score <= 77) {
      resRankStar = getRankStar4Profile(score, 3, 73, 77);
    } else if (78 <= score && score <= 82) {
      resRankStar = getRankStar4Profile(score, 2, 78, 82);
    } else if (83 <= score && score <= 87) {
      resRankStar = getRankStar4Profile(score, 1, 83, 87);
    } else if (88 <= score && score <= 92) {
      resRankStar = getRankStar4Profile(score, 5, 88, 92);
    } else if (93 <= score && score <= 97) {
      resRankStar = getRankStar4Profile(score, 4, 93, 97);
    } else if (98 <= score && score <= 102) {
      resRankStar = getRankStar4Profile(score, 3, 98, 102);
    } else if (103 <= score && score <= 107) {
      resRankStar = getRankStar4Profile(score, 2, 103, 107);
    } else if (108 <= score && score <= 112) {
      resRankStar = getRankStar4Profile(score, 1, 108, 112);
    } else if (113 <= score) {
      resRankStar = getRankStar4Profile(score, 1, 113, 113);
    }
    return resRankStar;
  }

  List<Widget> getMyRankInfo(int score, double HEIGHT_USER_INFO) {
    List<Widget> resWidget = new List<Widget>();
    resWidget.add(new Container(
      height: HEIGHT_USER_INFO * 0.4,
      width: HEIGHT_USER_INFO * 0.4,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(),
      child: Image.asset(getImgRank(score)),
    ));
    resWidget.add(new Column(
      children: getRankLevel(score),
    ));
    return resWidget;
  }

  List<Widget> getOpponentRank(int score, double HEIGHT_USER_INFO) {
    List<Widget> resWidget = new List<Widget>();
    resWidget.add(new Column(
      children: getRankLevel(score),
    ));
    resWidget.add(new Container(
      height: HEIGHT_USER_INFO * 0.4,
      width: HEIGHT_USER_INFO * 0.4,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(),
      child: Image.asset(getImgRank(score)),
    ));
    return resWidget;
  }

  List<Widget> getRankStar(int score, int level, int minStar, int maxStar) {
    List<Widget> lstInfoRank = new List<Widget>();
    Widget levelInRank;
    List<Widget> starInLevel = new List<Widget>();
    if (score >= 113) {
      levelInRank = Center(
        child: Text(
          getAltImgRank(score),
          style: textStyleForRank,
        ),
      );
      starInLevel.add(Image.asset('assets/star.png'));
      starInLevel.add(Text(
        " x ${score - 112}",
        style: TextStyle(fontSize: 11.0, color: Colors.yellow, fontWeight: FontWeight.bold),
      ));
      lstInfoRank.add(levelInRank);
      lstInfoRank.add(Container(
          height: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: starInLevel,
          )));
    } else {
      switch (level) {
        case 5:
          levelInRank = Center(
            child: Text(
              getAltImgRank(score) + " V",
              style: textStyleForRank,
            ),
          );
          break;
        case 4:
          levelInRank = Center(
            child: Text(
              getAltImgRank(score) + " IV",
              style: textStyleForRank,
            ),
          );
          break;
        case 3:
          levelInRank = Center(
            child: Text(
              getAltImgRank(score) + " III",
              style: textStyleForRank,
            ),
          );
          break;
        case 2:
          levelInRank = Center(
            child: Text(
              getAltImgRank(score) + " II",
              style: textStyleForRank,
            ),
          );
          break;
        case 1:
          levelInRank = Center(
            child: Text(
              getAltImgRank(score) + " I",
              style: textStyleForRank,
            ),
          );
          break;
        default:
          break;
      }
      for (int i = minStar; i <= maxStar; i++) {
        if (i <= score) {
          starInLevel.add(Image.asset('assets/star.png'));
        } else {
          starInLevel.add(Image.asset('assets/star_den.png'));
        }
      }
      lstInfoRank.add(levelInRank);
      lstInfoRank.add(Container(
          height: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: starInLevel,
          )));
    }
    return lstInfoRank;
  }

  List<Widget> getRankStar4Profile(
      int score, int level, int minStar, int maxStar) {
    List<Widget> lstInfoRank = new List<Widget>();
    Widget levelInRank;
    List<Widget> starInLevel = new List<Widget>();
    TextStyle ts = TextStyle(
        color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 22.0);
    TextStyle ts4Star = TextStyle(fontSize: 15.0, color: Colors.amber[800]);
    double hStar = 20.0;
    if (score >= 113) {
      levelInRank = Center(
        child: Text(
          getAltImgRank(score),
          style: ts,
        ),
      );
      starInLevel.add(Image.asset('assets/star.png'));
      starInLevel.add(Text(
        " x ${score - 112}",
        style: ts4Star,
      ));
      lstInfoRank.add(levelInRank);
      lstInfoRank.add(Container(
          height: hStar,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: starInLevel,
          )));
    } else {
      switch (level) {
        case 5:
          levelInRank = Center(
            child: Text(
              getAltImgRank(score) + " V",
              style: ts,
            ),
          );
          break;
        case 4:
          levelInRank = Center(
            child: Text(
              getAltImgRank(score) + " IV",
              style: ts,
            ),
          );
          break;
        case 3:
          levelInRank = Center(
            child: Text(
              getAltImgRank(score) + " III",
              style: ts,
            ),
          );
          break;
        case 2:
          levelInRank = Center(
            child: Text(
              getAltImgRank(score) + " II",
              style: ts,
            ),
          );
          break;
        case 1:
          levelInRank = Center(
            child: Text(
              getAltImgRank(score) + " I",
              style: ts,
            ),
          );
          break;
        default:
          break;
      }
      for (int i = minStar; i <= maxStar; i++) {
        if (i <= score) {
          starInLevel.add(Image.asset('assets/star.png'));
        } else {
          starInLevel.add(Image.asset('assets/star_den.png'));
        }
      }
      lstInfoRank.add(levelInRank);
      lstInfoRank.add(Container(
          height: hStar,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: starInLevel,
          )));
    }
    return lstInfoRank;
  }

  Widget getFullInfoUser(Size _wSize) {
    if (globals.isShowFullMyInfo == false &&
        globals.isShowFullOpponentInfo == false) {
      return Container();
    } else {
      double width = _wSize.width / 2;
      double height = _wSize.width * 3 / 4;
      return new Positioned(
        top: _wSize.height / 2 - _wSize.width * 3 / 4 / 2,
        left: _wSize.width / 2 - _wSize.width / 2 / 2,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.teal),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: width * 0.8,
                    width: width * 0.8,
                    decoration: BoxDecoration(),
                    child: Image.asset(globals.isShowFullOpponentInfo
                        ? "assets/${globals.linkAvatarOpponent ?? "img_avatar_2.png"}"
                        : "assets/${globals.linkAvatar}"),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: width * 0.45,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.account_box,
                                color: Colors.teal,
                                size: 20.0,
                              ),
                              Text(globals.getLocalization("global_info_account")),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: width * 0.45,
                          child: Text("" +
                              (globals.isShowFullOpponentInfo
                                  ? globals.displayNameOpponent
                                  : globals.displayName)),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: width * 0.45,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.all_inclusive,
                                color: Colors.teal,
                                size: 20.0,
                              ),
                              Text(globals.getLocalization("global_info_total_match")),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: width * 0.45,
                          child: Text(
                              "${(globals.isShowFullOpponentInfo ? globals.totalMatchOpponent : globals.totalMatch)}"),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: width * 0.45,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.flag,
                                color: Colors.teal,
                                size: 20.0,
                              ),
                              Text(globals.getLocalization("global_info_win_rate")),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: width * 0.45,
                          child: Text(
                              "${(globals.isShowFullOpponentInfo ? (globals.totalMatchRankOpponent > 0 ? (100 * globals.totalWinRankOpponent / globals.totalMatchRankOpponent).round() : 0) : (globals.totalMatchRank > 0 ? (100 * globals.totalWinRank / globals.totalMatchRank).round() : 0))}%"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget getFullInfoUserInRanking(Size _wSize) {
    if (globals.isShowFullInfoInRanking == false && globals.info == null) {
      return Container();
    } else {
      ObjGetInfo info = globals.info;
      double width = _wSize.width / 2;
      double height = _wSize.width * 3 / 4;
      return new Positioned(
        top: _wSize.height / 2 - _wSize.width * 3 / 4 / 2 - _wSize.height * 0.2,
        left: _wSize.width / 2 - _wSize.width / 2 / 2,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.teal),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: width * 0.8,
                    width: width * 0.8,
                    decoration: BoxDecoration(),
                    child: Image.asset("assets/${info.linkAvatar}"),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: width * 0.45,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.account_box,
                                color: Colors.teal,
                                size: 20.0,
                              ),
                              Text(globals.getLocalization("global_info_account")),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: width * 0.45,
                          child: Text("${info.displayName}"),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: width * 0.45,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.all_inclusive,
                                color: Colors.teal,
                                size: 20.0,
                              ),
                              Text(globals.getLocalization("global_info_total_match")),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: width * 0.45,
                          child: Text("${info.totalMatch}"),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: width * 0.45,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.flag,
                                color: Colors.teal,
                                size: 20.0,
                              ),
                              Text(globals.getLocalization("global_info_win_rate")),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: width * 0.45,
                          child: Text(
                              "${(info.totalMatchRank > 0 ? (100 * info.totalWinRank / info.totalMatchRank).round() : 0)}%"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
