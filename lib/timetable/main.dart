import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/essential/RestartWidget.dart';
import 'components/views/EventController.dart';
import 'structures/Settings.dart';
import 'structures/Store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Settings settings = Settings();
  await settings.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => Store()),
      ChangeNotifierProvider<Settings>(create: (_) => settings),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.green,
        colorScheme: ColorScheme.dark(
          primary: Colors.green,
          secondary: Colors.green,
        ),
      ),
      home: RestartWidget(child: EventController()),
      debugShowCheckedModeBanner: false,
    );
  }
}
