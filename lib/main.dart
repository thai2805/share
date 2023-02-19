import 'screen_login.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(Caro());
}

class Caro extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CARO-Rank",
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}
