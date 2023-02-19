library carorank.globals;

import 'objres.dart';

const int currentVersion = 105;

Map<String, dynamic> languageValue;
String language = "VI"; // VI / EN
String linksso = "http://rankvn.com:3000/sso";
String serverApps = "rankvn.com";
//String serverApps = "192.168.23.102";
int portApps = 9998;
bool isSound = true;
bool isVibrate = true;
String iosId = "";
String androidId = "";

// info user
String token = "";
String username = "";
String displayName = "";
String linkAvatar = "";
int score = 0;
int points = 0;
int totalMatch = 0;
int totalWin = 0;
int totalWinRank = 0;
int totalMatchRank = 0;
String email = "";
String phonenumber = "";
int changeDisplayName = 0;

// info oppenent
String usernameOpponent = "Đối thủ";
String displayNameOpponent = "Đối thủ";
String linkAvatarOpponent = "img_avatar_2.png";
int scoreOpponent = 0;
int totalMatchOpponent = 0;
int totalWinOpponent = 0;
int totalWinRankOpponent = 0;
int totalMatchRankOpponent = 0;

// variable for show full information
bool isShowFullMyInfo = false;
bool isShowFullOpponentInfo = false;
bool isShowFullInfoInRanking = false;
ObjGetInfo info;

String getLocalization(String name) {
  if (languageValue == null || language == null) {
    return "";
  } else {
    return (languageValue[language ?? "EN"][name] ?? "");
  }
}
