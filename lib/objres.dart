class ObjRes {
  bool success;
  int code;
  String message;
  Object data;

  ObjRes({this.success, this.code, this.message, this.data});

  factory ObjRes.fromJson(Map<String, dynamic> json) {
    return ObjRes(
        success: json['success'],
        code: json['code'],
        message: json['message'],
        data: json['data']);
  }
}

class ObjLogin {
  String token;
  String refreshToken;
  int expire;

  ObjLogin({this.token, this.refreshToken, this.expire});

  factory ObjLogin.fromJson(Map<String, dynamic> json) {
    return ObjLogin(
        token: json['token'],
        refreshToken: json['refreshToken'],
        expire: json['expire']);
  }
}

class ObjGetInfo {
  String username;
  String displayName;
  String linkAvatar;
  String email;
  String phoneNumber;
  int changeDisplayName;
  int status;
  String lastLogin;
  String createdAt;
  String countryCode;
  int totalMatch;
  int totalMatchRank;
  int totalWin;
  int totalWinRank;
  int currentScore;
  int points;
  ObjGetInfo(
      {this.username,
      this.displayName,
      this.linkAvatar,
      this.email,
      this.phoneNumber,
      this.changeDisplayName,
      this.status,
      this.lastLogin,
      this.createdAt,
      this.countryCode,
      this.totalMatch,
      this.totalMatchRank,
      this.totalWin,
      this.totalWinRank,
      this.currentScore,
      this.points});
  factory ObjGetInfo.fromJson(Map<String, dynamic> json) {
    return ObjGetInfo(
        username: json['username'],
        displayName: json['display_name'],
        linkAvatar: json['link_avatar'],
        email: json['email'],
        phoneNumber: json['phonenumber'],
        changeDisplayName: json['change_display_name'],
        status: json['status'],
        lastLogin: json['last_login'],
        createdAt: json['created_at'],
        countryCode: json['country_code'],
        totalMatch: json['total_match'],
        totalMatchRank: json['total_match_rank'],
        totalWin: json['total_win'],
        totalWinRank: json['total_win_rank'],
        currentScore: json['current_score'],
        points: json['points']);
  }
}

class ObjVersion {
  int version;
  String versionString;
  int forcedUpdate;
  int minVersion;
  String iosId;
  String androidId;
  ObjVersion(
      {this.version,
      this.versionString,
      this.forcedUpdate,
      this.minVersion,
      this.iosId,
      this.androidId});
  factory ObjVersion.fromJson(Map<String, dynamic> json) {
    return ObjVersion(
        version: json['version'],
        versionString: json['version_string'],
        forcedUpdate: json['forced_update'],
        minVersion: json['min_version'],
        iosId: json['ios_id'],
        androidId: json['android_id']);
  }
}
