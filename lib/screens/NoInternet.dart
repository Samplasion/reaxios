import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
import 'package:reaxios/screens/nav/Timetable.dart';
import 'package:reaxios/utils.dart';

import '../components/LowLevel/MaybeMasterDetail.dart';
import '../components/LowLevel/m3_drawer.dart';

class NoInternetScreen extends StatefulWidget {
  NoInternetScreen({Key? key}) : super(key: key);

  @override
  _NoInternetScreenState createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool loading = false;
  int _selectedItem = 0;

  Future<dynamic> _checkConnection() async {
    // If we're connected through Web, then it's basically
    // guaranteed that we're online
    // FIXME: that's blatantly false
    if (kIsWeb)
      SchedulerBinding.instance.addPostFrameCallback((_) {
        RestartWidget.restartApp(context);
      });

    if (!mounted) return;

    print("[NOI] Checking...");

    try {
      await Dio().get("https://1.1.1.1");
    } catch (e) {
      print(e);
      print(!e.toString().contains("XMLHttpRequest error"));
      if (e is! Error && (!e.toString().contains("XMLHttpRequest error"))) {
        context.showSnackbar(
          context.locale.noInternet.stillNoWifi,
          backgroundColor: Colors.red,
          style: TextStyle(
            color: Colors.red.contrastText,
          ),
        );
        // print(e.stackTrace);
        print("[NOI] Still no Internet.");
        // return Future.delayed(
        //     Duration(milliseconds: delay), _checkConnection(delay));
      }
    }

    print("[NOI] Internet found!");
    if (mounted) RestartWidget.restartApp(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaybeMasterDetail(
        master: () {
          // if (isLoading) return null;

          final drawer = getDrawer(context);
          // if (drawer == null) return null;

          final child = drawer.child;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                context.locale.about.appName,
              ),
            ),
            extendBodyBehindAppBar: true,
            body: child,
          );
        }(),
        detail: Scaffold(
          appBar: _selectedItem == 1
              ? null
              : AppBar(
                  title: Text("Registro"),
                  leading: Builder(builder: (context) {
                    return MaybeMasterDetail.of(context)!.isShowingMaster
                        ? Container()
                        : Builder(builder: (context) {
                            return IconButton(
                              tooltip: MaterialLocalizations.of(context)
                                  .openAppDrawerTooltip,
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                              icon: Icon(Icons.menu),
                            );
                          });
                  }),
                ),
          drawer: getDrawer(context),
          body: _selectedItem == 1
              ? Builder(
                  builder: (context) => TimetablePane(
                    openMainDrawer: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      EmptyUI(
                        icon: Icons.wifi_off,
                        text: context.locale.noInternet.body,
                      ),
                      SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: loading
                            ? null
                            : () {
                                setState(() {
                                  loading = true;
                                });
                                context
                                    .showSnackbar(context.locale.main.loading);
                                _checkConnection().then((_) {
                                  setState(() {
                                    loading = true;
                                  });
                                });
                              },
                        child: Text(context.locale.noInternet.cta),
                      ),
                    ],
                  ),
                ),
        ),
      ),
      onWillPop: () => Future.value(false),
    );
  }

  Drawer getDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          SizedBox(height: 16),
          M3DrawerListTile(
            title: Text(context.locale.noInternet.title),
            leading: Icon(Icons.wifi_off),
            selected: _selectedItem == 0,
            onTap: () {
              setState(() {
                _selectedItem = 0;
              });
              if (!MaybeMasterDetail.shouldBeShowingMaster(context))
                Navigator.pop(context);
            },
          ),
          M3DrawerListTile(
            title: Text(context.locale.drawer.timetable),
            leading: Icon(Icons.access_time),
            selected: _selectedItem == 1,
            onTap: () {
              setState(() {
                _selectedItem = 1;
              });
              if (!MaybeMasterDetail.shouldBeShowingMaster(context))
                Navigator.pop(context);
            },
          ),
          ...showEndOfDrawerItems(context),
        ],
      ),
    );
  }
}
