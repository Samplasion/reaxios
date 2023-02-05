// @dart=2.9
// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart' as S;
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/components/LowLevel/RestartWidget.dart';
import 'package:reaxios/components/LowLevel/md_indicator.dart';
import 'package:reaxios/components/Utilities/color_builder.dart';
import 'package:reaxios/components/Utilities/updates/config.dart' as upgrader;
import 'package:reaxios/i18n/delegate.dart';
import 'package:reaxios/services/android.dart' as android_service;
import 'package:reaxios/screens/Index.dart';
import 'package:reaxios/screens/Loading.dart';
import 'package:reaxios/screens/Login.dart';
import 'package:reaxios/screens/NoInternet.dart';
import 'package:reaxios/screens/Settings.dart';
import 'package:reaxios/services/notifications.dart';
import 'package:reaxios/system/AppInfoStore.dart';
import 'package:reaxios/system/intents.dart';
import 'change_notifier_provider.dart';
import 'cubit/app_cubit.dart';
import 'osversion.dart';
import 'timetable/structures/Settings.dart' as timetable;
import 'timetable/structures/Store.dart' as timetable;
import 'storage.dart' as s;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await fetchDeviceInfo();

  final timetable.Settings settings = timetable.Settings();
  await settings.init();

  final s.Storage applicationStorage = s.Storage();
  await applicationStorage.init();

  HttpOverrides.global = MyHttpOverrides();
  await S.Settings.init();

  final storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );
  HydratedBlocOverrides.runZoned(
    () => runApp(RestartWidget(
      child: BlocProvider(
        create: (context) => AppCubit(),
        child: MultiProvider(
          child: RegistroElettronicoApp(),
          providers: [
            Provider(
                create: (_) => AppInfoStore()..getPackageInfo(), lazy: false),
            ChangeNotifierProvider(create: (_) => timetable.Store()),
            UndisposingChangeNotifierProvider<timetable.Settings>(
              create: (_) => settings,
            ),
            UndisposingChangeNotifierProvider<s.Storage>(
              create: (_) => applicationStorage,
            ),
          ],
        ),
      ),
    )),
    storage: storage,
  );

  if (Platform.isAndroid) {
    android_service
        .initializeNotifications((pload) => notificationsSubject.add(pload))
        .then((_) => android_service.startNotificationServices());
  }

  upgrader.initConfig();
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
    final settings = Provider.of<timetable.Settings>(context);
    final themeMode = settings.getThemeMode();
    return ColorBuilder(
      builder: (light, dark) {
        final useMaterial3 = true;
        final primary = dark.primary, accent = dark.secondary;

        ThemeData getThemeData(ColorScheme scheme) {
          final cardTheme = CardTheme(
            color: scheme.surface,
            surfaceTintColor: scheme.surfaceTint,
            shadowColor: Colors.transparent,
            elevation: 4,
          );
          return ThemeData(
            colorScheme: scheme,
            useMaterial3: useMaterial3,
            primaryColor: primary,
            accentColor: accent,
            tabBarTheme: TabBarTheme(
              indicatorSize: TabBarIndicatorSize.label,
              indicator: MaterialDesignIndicator(
                indicatorHeight: 4,
                indicatorColor: scheme.onSurface,
              ),
              labelColor: scheme.onSurface,
            ),
            scaffoldBackgroundColor: scheme.background,
            canvasColor: scheme.background,
            cardTheme: cardTheme,
            cardColor: cardTheme.color,
            dividerColor: scheme.outlineVariant,
            dividerTheme: DividerThemeData(
              color: scheme.outlineVariant,
            ),
            dialogBackgroundColor: ElevationOverlay.applySurfaceTint(
              scheme.surface,
              scheme.surfaceTint,
              6,
            ),
            popupMenuTheme: PopupMenuThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          );
        }

        return Shortcuts(
          shortcuts: shortcuts,
          child: AnimatedBuilder(
            animation: settings,
            builder: (context, _) {
              return MaterialApp(
                title: 'Registro Axios',
                theme: getThemeData(light),
                darkTheme: getThemeData(dark),
                themeMode: getThemeMode(themeMode),
                // home: MyHomePage(title: 'Flutter Demo Home Page'),
                initialRoute: "loading",
                debugShowCheckedModeBanner: false,
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                supportedLocales: [
                  const Locale('en'),
                  const Locale('it'),
                ],
                routes: {
                  "/": (_) => HomeScreen(),
                  "login": (_) => LoginScreen(),
                  "loading": (_) => LoadingScreen(),
                  "settings": (_) => SettingsScreen(),
                  "nointernet": (_) => NoInternetScreen(),
                },
              );
            },
          ),
        );
      },
    );
  }
}
