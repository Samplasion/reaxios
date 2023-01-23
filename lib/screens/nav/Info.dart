import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:reaxios/api/entities/Login/Login.dart';
import 'package:reaxios/api/utils/Encrypter.dart';
import 'package:reaxios/components/Utilities/settings.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils.dart';

import '../../api/Axios.dart';
import '../../api/enums/Gender.dart';
import '../../components/LowLevel/Loading.dart';
import '../../cubit/app_cubit.dart';

class InfoPane extends StatefulWidget {
  final Login login;

  const InfoPane({super.key, required this.login});

  @override
  State<InfoPane> createState() => _InfoPaneState();
}

class _InfoPaneState extends State<InfoPane> {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (BuildContext context, state) {
        // if (state.notes != null)
        return buildOk(context, state.axios!);

        return LoadingUI();
      },
    );
  }

  Widget _wrap(Widget icon) {
    return CircleAvatar(
      child: icon,
    );
  }

  Future<bool> _authenticate() async {
    if (kIsWeb) return true;
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        return true;
      }

      final List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        return true;
      }

      try {
        final bool didAuthenticate = await auth.authenticate(
            localizedReason: context.locale.infoPane.authReason);
        return didAuthenticate;
      } on PlatformException {
        return true;
      }
    } on MissingPluginException {
      // The system does not support local authentication
      return true;
    }
  }

  Map<String, bool> _sensitiveShown = {};

  Widget buildOk(BuildContext context, Axios session) {
    final groups = [
      InfoGroup(
        context.locale.infoPane.schoolInfo,
        entries: [
          InfoEntry(
            context.locale.infoPane.schoolName,
            "${widget.login.schoolTitle} ${widget.login.schoolName}",
            Icon(Icons.business),
          ),
          InfoEntry(
            context.locale.infoPane.schoolFID,
            widget.login.schoolID,
            Icon(Icons.business_center),
          ),
        ],
      ),
      InfoGroup(
        context.locale.infoPane.userInfo,
        entries: [
          InfoEntry(
            context.locale.infoPane.userName,
            "${widget.login.firstName} ${widget.login.lastName}",
            Icon(Icons.person),
          ),
          InfoEntry(
            context.locale.infoPane.userBirthday,
            context.dateToString(widget.login.birthday),
            Icon(Icons.calendar_today),
          ),
          InfoEntry(
            context.locale.infoPane.userAge,
            calculateAge(widget.login.birthday).toString(),
            Icon(Icons.numbers),
          ),
          InfoEntry(
            context.locale.infoPane.userID,
            widget.login.userID,
            Icon(Icons.code),
          ),
          InfoEntry(
            context.locale.infoPane.userPassword,
            widget.login.password.or(Encrypter.decrypt(
                context.read<Settings>().prefs.getString("pass") ?? "")),
            Icon(Icons.password),
            sensitive: true,
          ),
          InfoEntry(
            context.locale.infoPane.userPIN,
            widget.login.pin,
            Icon(Icons.pin),
            sensitive: true,
          ),
        ],
      ),
      for (final student in session.students) ...[
        InfoGroup(
          student.fullName,
          entries: [
            InfoEntry(
              context.locale.infoPane.userName,
              student.fullName,
              Icon(Icons.person),
            ),
            InfoEntry(
              context.locale.infoPane.userBirthday,
              context.dateToString(student.birthday),
              Icon(Icons.calendar_today),
            ),
            InfoEntry(
              context.locale.infoPane.userAge,
              calculateAge(student.birthday).toString(),
              Icon(Icons.numbers),
            ),
            InfoEntry(
              context.locale.infoPane.gender,
              context.locale.main.getByKey(
                  student.gender == Gender.Male ? "genderM" : "genderF"),
              Icon(Icons.extension),
            ),
            InfoEntry(
              context.locale.infoPane.userID,
              student.studentUUID,
              Icon(Icons.code),
            ),
          ],
        ),
      ],
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          for (final group in groups) ...[
            SettingsHeader(title: group.title),
            for (final info in group.entries) ...[
              () {
                final shouldBeShown = _sensitiveShown[info.title] == true;
                return ListTile(
                  leading: _wrap(info.icon),
                  title: Text(info.title),
                  subtitle: Text(
                    info.sensitive && !shouldBeShown
                        ? "*".repeat(info.text.characters.length)
                        : info.text,
                  ),
                  trailing: info.sensitive
                      ? IconButton(
                          onPressed: () {
                            (info.sensitive && !shouldBeShown
                                    ? _authenticate()
                                    : Future.value(true))
                                .then((v) {
                              if (v) {
                                setState(() {
                                  _sensitiveShown[info.title] = !shouldBeShown;
                                });
                              }
                            });
                          },
                          icon: Icon(Icons.remove_red_eye),
                        )
                      : null,
                  onTap: () {
                    (info.sensitive ? _authenticate() : Future.value(true))
                        .then((v) {
                      print(v);
                      if (v) {
                        Clipboard.setData(ClipboardData(text: info.text));
                        context.showSnackbar(context.locale.main.copied);
                      }
                    });
                  },
                );
              }()
            ],
          ],
        ],
      ),
    );
  }
}

class InfoEntry {
  final String title, text;
  final Widget icon;
  final bool sensitive;

  InfoEntry(this.title, this.text, this.icon, {this.sensitive = false});
}

class InfoGroup {
  final String title;
  final List<InfoEntry> entries;

  InfoGroup(this.title, {required this.entries});
}
