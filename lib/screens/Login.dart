import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/School/School.dart';
import 'package:reaxios/api/utils/Encrypter.dart';
import 'package:reaxios/components/ListItems/SchoolListItem.dart';
import 'package:reaxios/components/LowLevel/GradientAppBar.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../consts.dart';
import '../format.dart';

final useScreens = (RegistroStore store, onPrev, onNext, onDone) => [
      _LoginScreenPage1(
        store: store,
        onNext: onNext,
      ),
      _LoginScreenPage2(
        store: store,
        onPrev: onPrev,
        onDone: onDone,
      )
    ];

class _LoginScreenPage1 extends StatefulWidget {
  _LoginScreenPage1({Key? key, required this.onNext, required this.store})
      : super(key: key);

  final void Function() onNext;
  final RegistroStore store;

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
                      context.locale.login.selectSchool,
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
                                    labelText: context
                                        .locale.login.searchBarPlaceholder,
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
                          widget.store.school = _schools[_selectedIndex];
                          widget.onNext();
                        }
                      : null,
                  child: Text(context.locale.login.next),
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
    final schools = await Axios.searchSchools(_query.text);
    setState(() {
      _schools = schools;
      loading = false;
      _selectedIndex = -1;
    });
  }
}

class _LoginScreenPage2 extends StatefulWidget {
  _LoginScreenPage2(
      {Key? key,
      required this.onDone,
      required this.onPrev,
      required this.store})
      : super(key: key);

  final void Function() onPrev;
  final void Function() onDone;
  final RegistroStore store;

  @override
  __LoginScreenPage2State createState() => __LoginScreenPage2State();
}

class __LoginScreenPage2State extends State<_LoginScreenPage2> {
  get height => MediaQuery.of(context).size.height;

  final FocusNode _passFocus = FocusNode();

  String name = "";
  String pass = "";

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
                        child: Icon(Icons.lock),
                      ),
                      padding: EdgeInsets.only(bottom: 8),
                    ),
                    Text(
                      formatString(context.locale.login.loginPhaseTwoTitle, [
                        widget.store.school?.title ?? "",
                        widget.store.school?.name ?? ""
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
                                  labelText:
                                      context.locale.login.userIDPlaceholder,
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
                                  labelText:
                                      context.locale.login.passwordPlaceholder,
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
                      child: Text(context.locale.login.back),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: ElevatedButton(
                        onPressed: _inputValid() ? _login : null,
                        child: Text(context.locale.login.loginButtonText),
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

  _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("user", name);
    prefs.setString("pass", Encrypter.encrypt(pass));
    widget.onDone();
  }

  bool _inputValid() {
    return name.trim().length > 0 && pass.trim().length > 0;
  }
}

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key, required this.store}) : super(key: key);

  final RegistroStore store;

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
    screens = useScreens(widget.store, _onPrev, _onNext, _onDone);
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(context.locale.login.title),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: Icon(Icons.science),
              onPressed: () {
                Provider.of<RegistroStore>(context, listen: false).testMode =
                    true;
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
