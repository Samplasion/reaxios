import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/logger.dart';
import 'package:reaxios/api/entities/Account.dart';
import 'package:reaxios/api/utils/Encrypter.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cubit/app_cubit.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool checked = false;

  _checkLoginDetails(BuildContext context) {
    // if (checked) return;
    // setState(() {
    //   checked = true;
    // });
    Future.delayed(Duration(milliseconds: 0), () {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        final cubit = context.read<AppCubit>();
        final prefs = await SharedPreferences.getInstance();

        if (!prefs.containsKey("school") ||
            !prefs.containsKey("user") ||
            !prefs.containsKey("pass")) {
          Logger.d("No login details found [1]");
          Navigator.pushReplacementNamed(context, "login");
          return;
        }

        final school = prefs.getString("school")!;
        final user = prefs.getString("user")!;
        final pass = prefs.getString("pass")!;

        if (school.trim() == "" || user.trim() == "" || pass.trim() == "") {
          Logger.d("No login details found [2]");
          Navigator.pushReplacementNamed(context, "login");
          return;
        }

        if (cubit.hasAccount) {
          Logger.d("Already logged in");
          Navigator.pushReplacementNamed(context, "/");
          return;
        }

        final error = await cubit.login(AxiosAccount(
          school,
          user,
          Encrypter.decrypt(pass),
        ));

        if (error != null) {
          Logger.e("$error");
          if (error is Error) Logger.e("${error.stackTrace}");
          if (error.toString().contains("Failed host lookup")) {
            Navigator.pushReplacementNamed(context, "nointernet");
          } else {
            Navigator.pushReplacementNamed(context, "login");
          }
          return;
        }

        Navigator.pushReplacementNamed(context, "/");
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLoginDetails(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(title: Text(context.loc.translate("about.appName"))),
        body: LoadingUI(
          showHints: true,
        ),
      ),
      onWillPop: () {
        return Future.value(false);
      },
    );
  }
}
