import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';

class NoInternetScreen extends StatefulWidget {
  NoInternetScreen({Key? key}) : super(key: key);

  @override
  _NoInternetScreenState createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  @override
  void initState() {
    super.initState();

    _checkConnection(5000)();
  }

  FutureOr<dynamic> Function() _checkConnection(int delay) {
    return () async {
      if (!mounted) return;

      print("[NOI] Checking...");

      try {
        await Dio().get("https://1.1.1.1");
      } catch (e) {
        print(e);
        print(!e.toString().contains("XMLHttpRequest error"));
        if (e is! Error && (!e.toString().contains("XMLHttpRequest error"))) {
          // print(e.stackTrace);
          print("[NOI] Still no Internet.");
          return Future.delayed(
              Duration(milliseconds: delay), _checkConnection(delay));
        }
      }

      print("[NOI] Internet found!");
      if (mounted) RestartWidget.restartApp(context);
    };
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Registro"),
        ),
        body: EmptyUI(
          icon: Icons.wifi_off,
          text: "Assicurati di avere una connessione disponibile.",
        ),
      ),
      onWillPop: () => Future.value(false),
    );
  }
}
