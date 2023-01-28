import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
import 'package:reaxios/screens/nav/Timetable.dart';
import 'package:reaxios/utils.dart';

import '../components/LowLevel/MaybeMasterDetail.dart';
import '../components/LowLevel/m3_drawer.dart';
import '../system/AppInfoStore.dart';

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
          context.loc.translate("noInternet.stillNoWifi"),
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
        master: getDrawer(context, false),
        detail: Builder(builder: (context) {
          return StreamBuilder<bool>(
              stream: MaybeMasterDetail.getShowingStream(context),
              initialData: false,
              builder: (context, isShowingMasterSnapshot) {
                final isShowingMaster = isShowingMasterSnapshot.data ?? false;
                return Scaffold(
                  appBar: _selectedItem == 1
                      ? null
                      : AppBar(
                          title: Text("Registro"),
                          leading: isShowingMaster
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
                                }),
                        ),
                  drawer: isShowingMaster ? null : getDrawer(context, true),
                  body: _selectedItem == 1
                      ? Builder(
                          builder: (context) => TimetablePane(
                            openMainDrawer: () =>
                                Scaffold.of(context).openDrawer(),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              EmptyUI(
                                icon: Icons.wifi_off,
                                text: context.loc.translate("noInternet.body"),
                              ),
                              SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: loading
                                    ? null
                                    : () {
                                        setState(() {
                                          loading = true;
                                        });
                                        context.showSnackbar(context.loc
                                            .translate("main.loading"));
                                        _checkConnection().then((_) {
                                          setState(() {
                                            loading = true;
                                          });
                                        });
                                      },
                                child: Text(
                                    context.loc.translate("noInternet.cta")),
                              ),
                            ],
                          ),
                        ),
                );
              });
        }),
      ),
      onWillPop: () => Future.value(false),
    );
  }

  Drawer getDrawer(BuildContext context, bool scrim) {
    final appInfo = context.watch<AppInfoStore>();
    final app = appInfo.packageInfo;

    return Drawer(
      elevation: scrim ? null : 0,
      shape: scrim
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
            )
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: scrim
              ? BorderRadius.horizontal(right: Radius.circular(16))
              : BorderRadius.circular(0),
        ),
        clipBehavior: scrim ? Clip.hardEdge : Clip.none,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView(
            children: [
              SizedBox(height: 16),
              M3DrawerHeading(kIsWeb
                  ? context.loc.translate("about.appName")
                  : app.appName),
              SizedBox(height: 16),
              M3DrawerListTile(
                title: Text(context.loc.translate("noInternet.title")),
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
                title: Text(context.loc.translate("drawer.timetable")),
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
        ),
      ),
    );
  }
}
