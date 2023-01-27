import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Account.dart';
import 'package:reaxios/api/entities/School/School.dart';
import 'package:reaxios/api/utils/Encrypter.dart';
import 'package:reaxios/components/ListItems/SchoolListItem.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../consts.dart';
import '../format.dart';

final useScreens = (onPrev, onNext, onDone) => [
      _LoginScreenPage1(
        onNext: onNext,
      ),
      _LoginScreenPage2(
        onPrev: onPrev,
        onDone: onDone,
      )
    ];

class _LoginScreenPage1 extends StatefulWidget {
  _LoginScreenPage1({Key? key, required this.onNext}) : super(key: key);

  final void Function() onNext;

  @override
  __LoginScreenPage1State createState() => __LoginScreenPage1State();
}

class __LoginScreenPage1State extends State<_LoginScreenPage1> {
  get isPortrait => MediaQuery.of(context).orientation == Orientation.portrait;
  get height => MediaQuery.of(context).size.height;

  final _query = TextEditingController();
  bool loading = false;
  List<School> _schools = [];
  int _selectedIndex = -1;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Padding(
                      child: GradientCircleAvatar(
                        color: Theme.of(context).colorScheme.secondary,
                        child: Icon(Icons.school),
                      ),
                      padding: EdgeInsets.only(bottom: 8),
                    ),
                    Text(
                      context.loc.translate("login.selectSchool"),
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  // constraints: BoxConstraints(maxHeight: height / 1.5),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            children: [
                              new Flexible(
                                child: TextField(
                                  controller: _query,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: context.loc.translate(
                                        "login.searchBarPlaceholder"),
                                  ),
                                  onSubmitted: (q) async {
                                    FocusScope.of(context).unfocus();
                                    if (!loading) {
                                      await _search();
                                    }
                                  },
                                  textInputAction: TextInputAction.search,
                                ),
                              ),
                              IconButton(
                                onPressed: !loading ? _search : null,
                                icon: Icon(Icons.search),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Container(
                              constraints: BoxConstraints(minHeight: 250),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemBuilder: (context, index) => SchoolListItem(
                                  school: _schools[index % _schools.length],
                                  selected: index == _selectedIndex,
                                  onClick: () {
                                    setState(() {
                                      _selectedIndex = index % _schools.length;
                                    });
                                  },
                                ),
                                scrollDirection: Axis.vertical,
                                itemCount: _schools.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: _selectedIndex != -1
                      ? () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString(
                              "school", _schools[_selectedIndex].id);
                          // widget.store.school = _schools[_selectedIndex];
                          final cubit = context.read<AppCubit>();
                          cubit.setSchool(_schools[_selectedIndex]);
                          widget.onNext();
                        }
                      : null,
                  child: Text(context.loc.translate("login.next")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _search() async {
    setState(() {
      loading = true;
    });
    try {
      final schools = await Axios.searchSchools(_query.text);
      setState(() {
        _schools = schools;
        _selectedIndex = -1;
      });
    } catch (e) {
      print(e);
      context.showSnackbar(
        context.loc.translate("errors.request"),
        style: TextStyle(color: Colors.white),
        backgroundColor: Colors.red,
      );
    }
    setState(() {
      loading = false;
    });
  }
}

class _LoginScreenPage2 extends StatefulWidget {
  _LoginScreenPage2({
    Key? key,
    required this.onDone,
    required this.onPrev,
  }) : super(key: key);

  final void Function() onPrev;
  final void Function() onDone;

  @override
  __LoginScreenPage2State createState() => __LoginScreenPage2State();
}

class __LoginScreenPage2State extends State<_LoginScreenPage2> {
  get height =>
      MediaQuery.of(context).size.height -
      MediaQuery.of(context).padding.top -
      MediaQuery.of(context).padding.bottom;
  bool loading = false;

  final FocusNode _passFocus = FocusNode();

  String name = "";
  String pass = "";

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AppCubit>();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Padding(
                      child: GradientCircleAvatar(
                        color: Theme.of(context).colorScheme.secondary,
                        child: Icon(Icons.lock),
                      ),
                      padding: EdgeInsets.only(bottom: 8),
                    ),
                    Text(
                      formatString(
                          context.loc.translate("login.loginPhaseTwoTitle"), [
                        cubit.school?.title ?? "",
                        cubit.school?.name ?? ""
                      ]),
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: AutofillGroup(
                  child: Container(
                    constraints: BoxConstraints(maxHeight: height / 1.5),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              child: TextField(
                                onChanged: (newName) => setState(() {
                                  name = newName;
                                }),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: context.loc
                                      .translate("login.userIDPlaceholder"),
                                ),
                                autofillHints: [AutofillHints.username],
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: TextField(
                                focusNode: _passFocus,
                                obscureText: true,
                                onChanged: (newPass) => setState(() {
                                  pass = newPass;
                                }),
                                onSubmitted: (_) async {
                                  if (_inputValid()) {
                                    await _login();
                                  }
                                },
                                autofillHints: [AutofillHints.password],
                                onEditingComplete: () =>
                                    TextInput.finishAutofillContext(),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: context.loc
                                      .translate("login.passwordPlaceholder"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        widget.onPrev();
                      },
                      child: Text(context.loc.translate("login.back")),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: ElevatedButton(
                        onPressed: _inputValid() && !loading ? _login : null,
                        child: Text(
                            context.loc.translate("login.loginButtonText")),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _checkIfCredentialsAreValid() async {
    final cubit = context.read<AppCubit>();

    // try {
    final account = AxiosAccount(
      cubit.school!.id,
      name,
      pass,
    );
    //   final session = Axios(account);
    //   await session.login();
    //   return true;
    // } catch (e) {
    final e = await cubit.login(account);
    if (e != null) {
      print(e);
      if (e.toString().toLowerCase().contains("controllare codice utente")) {
        context.showSnackbar(
          context.loc.translate("errors.authentication"),
          style: TextStyle(color: Colors.white),
          backgroundColor: Colors.red,
        );
      } else {
        context.showSnackbar(
          context.loc.translate("errors.request"),
          style: TextStyle(color: Colors.white),
          backgroundColor: Colors.red,
        );
      }
      return false;
    }

    return true;
  }

  _login() async {
    setState(() {
      loading = true;
    });
    try {
      if (await _checkIfCredentialsAreValid()) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("user", name);
        prefs.setString("pass", Encrypter.encrypt(pass));
        widget.onDone();
      }
    } catch (e) {
      print(e);
      context.showSnackbar(
        context.loc.translate("errors.request"),
        style: TextStyle(color: Colors.white),
        backgroundColor: Colors.red,
      );
    }
    setState(() {
      loading = false;
    });
  }

  bool _inputValid() {
    return name.trim().length > 0 && pass.trim().length > 0;
  }
}

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _index = 0;
  List<Widget> screens = [];

  _onPrev() {
    setState(() {
      _index--;
    });
  }

  _onNext() {
    setState(() {
      _index++;
    });
  }

  _onDone() async {
    Navigator.of(context).pushReplacementNamed("/");
  }

  @override
  Widget build(BuildContext context) {
    screens = useScreens(_onPrev, _onNext, _onDone);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.translate("login.title")),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: Icon(Icons.science),
              onPressed: () {
                context.read<AppCubit>().setTestMode(true);
                _onDone();
              },
            ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: kTabBreakpoint),
          child: screens[_index],
        ),
      ),
    );
  }
}
