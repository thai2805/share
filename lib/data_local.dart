import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'globals.dart' as globals;

class DataLocal {
  String language;
  String token;
  String refreshToken;
  String username;
  String displayName;

  Future<File> _localFile() async {
    String dataDir = (await getApplicationDocumentsDirectory()).path;
    return File(dataDir + '/data.json');
  }

  Future storeAccount() async {
    final file = await _localFile();
    Map data = {
      'language': language,
      'token': token,
      'refreshToken': refreshToken,
      'username': username,
      'displayName': displayName
    };
    globals.token = token;
    JsonEncoder encoder = new JsonEncoder();
    String json = encoder.convert(data);
    file.writeAsStringSync(json);
  }

  Future loadAccount() async {
    final file = await _localFile();
    if (file.existsSync()) {
      print("path data local : ${file.path}");
      String json = file.readAsStringSync();
      JsonDecoder decoder = new JsonDecoder();
      Map data = decoder.convert(json);
      language = data['language'];
      globals.language = (language ?? "EN");
      print("########### " + globals.language);
      token = data['token'];
      refreshToken = data['refreshToken'];
      username = data['username'];
      displayName = data['displayName'];
    }
  }

  DataLocal({this.language, this.token, this.refreshToken, this.username, this.displayName});
}
