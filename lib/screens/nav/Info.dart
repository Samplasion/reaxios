import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:axios_api/entities/Login/Login.dart';
import 'package:axios_api/utils/Encrypter.dart';
import 'package:reaxios/components/Utilities/settings.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils/utils.dart';

import 'package:axios_api/client.dart';
import 'package:axios_api/enums/Gender.dart';
import '../../components/LowLevel/Loading.dart';
import '../../cubit/app_cubit.dart';

class InfoPane extends StatefulWidget {
  final Login login;

  const InfoPane({super.key, required this.login});

  @override
  State<InfoPane> createState() => _InfoPaneState();
}

class _InfoPaneState extends State<InfoPane> {
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

  Map<String, bool> _sensitiveShown = {};

  Widget buildOk(BuildContext context, Axios session) {
    final groups = [
      InfoGroup(
        context.loc.translate("infoPane.schoolInfo"),
        entries: [
          InfoEntry(
            context.loc.translate("infoPane.schoolName"),
            "${widget.login.schoolTitle} ${widget.login.schoolName}",
            Icon(Icons.business),
          ),
          InfoEntry(
            context.loc.translate("infoPane.schoolFID"),
            widget.login.schoolID,
            Icon(Icons.business_center),
          ),
        ],
      ),
      InfoGroup(
        context.loc.translate("infoPane.userInfo"),
        entries: [
          InfoEntry(
            context.loc.translate("infoPane.userName"),
            "${widget.login.firstName} ${widget.login.lastName}",
            Icon(Icons.person),
          ),
          InfoEntry(
            context.loc.translate("infoPane.userBirthday"),
            context.dateToString(widget.login.birthday),
            Icon(Icons.calendar_today),
          ),
          InfoEntry(
            context.loc.translate("infoPane.userAge"),
            calculateAge(widget.login.birthday).toString(),
            Icon(Icons.numbers),
          ),
          InfoEntry(
            context.loc.translate("infoPane.userID"),
            widget.login.userID,
            Icon(Icons.code),
          ),
          InfoEntry(
            context.loc.translate("infoPane.userPassword"),
            widget.login.password.or(Encrypter.decrypt(
                context.read<Settings>().prefs.getString("pass") ?? "")),
            Icon(Icons.password),
            sensitive: true,
          ),
          InfoEntry(
            context.loc.translate("infoPane.userPIN"),
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
              context.loc.translate("infoPane.userName"),
              student.fullName,
              Icon(Icons.person),
            ),
            InfoEntry(
              context.loc.translate("infoPane.userBirthday"),
              context.dateToString(student.birthday),
              Icon(Icons.calendar_today),
            ),
            InfoEntry(
              context.loc.translate("infoPane.userAge"),
              calculateAge(student.birthday).toString(),
              Icon(Icons.numbers),
            ),
            InfoEntry(
              context.loc.translate("infoPane.gender"),
              context.loc.translate(student.gender == Gender.Male
                  ? "main.genderM"
                  : "main.genderF"),
              Icon(Icons.extension),
            ),
            InfoEntry(
              context.loc.translate("infoPane.userID"),
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
                            setState(() {
                              _sensitiveShown[info.title] = !shouldBeShown;
                            });
                          },
                          icon: Icon(Icons.remove_red_eye),
                        )
                      : null,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: info.text));
                    context.showSnackbar(context.loc.translate("main.copied"));
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
