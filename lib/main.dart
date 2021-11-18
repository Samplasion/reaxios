// @dart=2.9
// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart' as S;
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:reaxios/api/utils/ColorSerializer.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
import 'package:reaxios/services/android.dart' as android_service;
import 'package:reaxios/screens/Index.dart';
import 'package:reaxios/screens/Loading.dart';
import 'package:reaxios/screens/Login.dart';
import 'package:reaxios/screens/NoInternet.dart';
import 'package:reaxios/screens/Settings.dart';
import 'package:reaxios/system/AxiosLocalizationDelegate.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/system/AppInfoStore.dart';
import 'package:reaxios/system/intents.dart';
import 'package:reaxios/utils.dart';

import 'enums/GradeDisplay.dart';

const kTabBreakpoint = 680.0;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  RegistroStore registroStore = RegistroStore();

  HttpOverrides.global = MyHttpOverrides();
  await S.Settings.init();
  runApp(RestartWidget(
    child: MultiProvider(
      child: RegistroElettronicoApp(),
      providers: [
        Provider(create: (_) => registroStore),
        Provider(create: (_) => AppInfoStore()..getPackageInfo(), lazy: false),
      ],
    ),
  ));

  android_service
      .initializeNotifications(
          (payload) => registroStore.notificationPayloadAction(payload))
      .then((_) => android_service.startNotificationServices());
}

ThemeMode getThemeMode(String tm) {
  switch (tm) {
    case "light":
      return ThemeMode.light;
    case "dark":
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

class RegistroElettronicoApp extends StatefulWidget {
  RegistroElettronicoApp({Key key}) : super(key: key);

  @override
  _RegistroElettronicoAppState createState() => _RegistroElettronicoAppState();
}

class _RegistroElettronicoAppState extends State<RegistroElettronicoApp> {
  final shortcuts = <LogicalKeySet, Intent>{
    LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
    LogicalKeySet(LogicalKeyboardKey.contextMenu): MenuIntent(),
    LogicalKeySet(LogicalKeyboardKey.keyM): MenuIntent(),
    LogicalKeySet(LogicalKeyboardKey.tvContentsMenu): MenuIntent(),
  };

  @override
  Widget build(BuildContext context) {
    const cs = const ColorSerializer();
    final themeMode = S.Settings.getValue("theme-mode", "dynamic");

    var store = Provider.of<RegistroStore>(context);

    store.gradeDisplay = deserializeGradeDisplay(
        S.Settings.getValue("grade-display", "decimal"));

    final primary = cs.fromJson(
      S.Settings.getValue("primary-color", cs.toJson(Colors.orange[400])),
    );
    final accent = cs.fromJson(
      S.Settings.getValue("accent-color", cs.toJson(Colors.purple[400])),
    );

    AppBarTheme appBarTheme = AppBarTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(15),
        ),
      ),
    );

    return Shortcuts(
      shortcuts: shortcuts,
      child: MaterialApp(
        title: 'Registro Axios',
        theme: ThemeData(
          primaryColor: primary,
          accentColor: accent,
          colorScheme: ColorScheme.light(
            primary: primary,
            onPrimary: primary.contrastText,
            secondary: accent,
            onSecondary: accent.contrastText,
          ),
          appBarTheme: appBarTheme,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: primary,
          accentColor: accent,
          colorScheme: ColorScheme.dark(
            primary: primary,
            onPrimary: primary.contrastText,
            secondary: accent,
            onSecondary: accent.contrastText,
          ),
          appBarTheme: appBarTheme,
        ),
        themeMode: getThemeMode(themeMode),
        // home: MyHomePage(title: 'Flutter Demo Home Page'),
        initialRoute: "loading",
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          AxiosLocalizationDelegate(),
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'),
          const Locale('it'),
        ],
        routes: {
          "/": (_) => Builder(
                builder: (context) => RefreshConfiguration(
                  headerBuilder: () => ClassicHeader(
                    idleText: context.locale.main.idleText,
                    completeText: context.locale.main.completeText,
                    releaseText: context.locale.main.releaseText,
                    refreshingText: context.locale.main.refreshingText,
                    failedText: context.locale.main.failedText,
                  ),
                  child: HomeScreen(store: store),
                ),
              ),
          "login": (_) => LoginScreen(store: store),
          "loading": (_) => LoadingScreen(),
          "settings": (_) => SettingsScreen(),
          "nointernet": (_) => NoInternetScreen(),
        },
      ),
    );
  }
}
