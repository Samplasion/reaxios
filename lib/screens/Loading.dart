import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:reaxios/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool checked = false;
  List<Color> colorList = [
    Color(0xffc44040),
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.amber,
    Colors.pink,
  ];
  List<Alignment> alignmentList = [
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.topRight,
    Alignment.topLeft,
  ];
  int index = 0;
  Color bottomColor = Colors.red;
  Color topColor = Colors.blue;
  Alignment begin = Alignment.bottomLeft;
  Alignment end = Alignment.topRight;

  _checkLoginDetails(BuildContext context) {
    // if (checked) return;
    // setState(() {
    //   checked = true;
    // });
    Future.delayed(Duration(milliseconds: 500), () {
      SchedulerBinding.instance!.addPostFrameCallback((_) async {
        final prefs = await SharedPreferences.getInstance();

        if (!prefs.containsKey("school") ||
            !prefs.containsKey("user") ||
            !prefs.containsKey("pass")) {
          Navigator.pushReplacementNamed(context, "login");
          return;
        }

        final school = prefs.getString("school")!;
        final user = prefs.getString("user")!;
        final pass = prefs.getString("pass")!;

        if (school.trim() == "" || user.trim() == "" || pass.trim() == "") {
          Navigator.pushReplacementNamed(context, "login");
          return;
        }

        Navigator.pushReplacementNamed(context, "/");
      });
    });
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        bottomColor = Colors.blue;
      });
    });
    _checkLoginDetails(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: Scaffold(
          body: Stack(
            children: [
              AnimatedContainer(
                duration: Duration(seconds: 2),
                onEnd: () {
                  setState(() {
                    index = index + 1;
                    // animate the color
                    bottomColor = colorList[index % colorList.length];
                    topColor = colorList[(index + 1) % colorList.length];

                    // animate the alignment
                    begin = alignmentList[index % alignmentList.length];
                    end = alignmentList[(index + 2) % alignmentList.length];
                  });
                },
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: begin,
                    end: end,
                    colors: [bottomColor, topColor],
                  ),
                ),
              ),
              Positioned.fill(
                child: SpinKitPumpingHeart(
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
      onWillPop: () {
        return Future.value(false);
      },
    );
  }
}
