import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Authorization/Authorization.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/components/ListItems/AuthorizationListItem.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/utils/utils.dart';
import "package:styled_widget/styled_widget.dart";

class AuthorizationsPane extends StatefulWidget {
  AuthorizationsPane({
    Key? key,
    required this.session,
  }) : super(key: key);

  final Axios session;

  @override
  _AuthorizationsPaneState createState() => _AuthorizationsPaneState();
}

class _AuthorizationsPaneState extends State<AuthorizationsPane> {
  final ScrollController controller = ScrollController();
  Key key = UniqueKey();

  Map<String, List<Authorization>> splitAuthorizations(
      List<Authorization> authorizations) {
    authorizations.sort((a1, a2) => a2.startDate.compareTo(a1.startDate));
    return authorizations.fold(new Map(), (map, note) {
      final date = note.period;
      if (!map.containsKey(date))
        map[date] = [note];
      else
        map[date]!.add(note);

      return map;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session.student?.securityBits[SecurityBits.hideAuthorizations] ==
        "1") {
      return EmptyUI(
        text: context.loc.translate("main.noPermission"),
        icon: Icons.lock,
      ).padding(horizontal: 16);
    }

    return BlocBuilder<AppCubit, AppState>(
      builder: (BuildContext context, state) {
        return buildOk(context, (state.authorizations ?? []).reversed.toList());
      },
    );
  }

  void rebuild() => setState(() {
        key = UniqueKey();
      });

  Widget buildOk(BuildContext context, List<Authorization> authorizations) {
    if (authorizations.isEmpty) {
      return EmptyUI(
        icon: Icons.no_accounts_outlined,
        text: context.loc.translate("authorizations.empty"),
      );
    }

    final map = splitAuthorizations(authorizations);
    final entries = map.entries;

    final slivers = <Widget>[
      for (final MapEntry<String, List<Authorization>> entry in entries) ...[
        SliverStickyHeader(
          header: Container(
            height: 50.0,
            color: Theme.of(context).canvasColor,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.centerLeft,
            child: Center(
              child: MaxWidthContainer(
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ),
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Hero(
                tag: entry.value[i].toString(),
                child: Center(
                  child: MaxWidthContainer(
                    child: AuthorizationListItem(
                      authorization: entry.value[i],
                      session: widget.session,
                    ),
                  ),
                ),
              ).paddingDirectional(horizontal: 16),
              childCount: entry.value.length,
            ),
          ),
        )
      ],
    ];

    return KeyedSubtree(
      key: key,
      child: RefreshIndicator(
        onRefresh: () async {
          await context.read<AppCubit>().loadAuthorizations(force: true);
        },
        child: CustomScrollView(
          controller: controller,
          slivers: slivers,
        ),
      ),
    );
  }
}
