import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Bulletin/Bulletin.dart';
import 'package:reaxios/api/entities/Student/Student.dart';
import 'package:reaxios/components/ListItems/BulletinListItem.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/LowLevel/ReloadableState.dart';
import 'package:reaxios/system/Store.dart';
import "package:styled_widget/styled_widget.dart";

class BulletinsPane extends StatefulWidget {
  BulletinsPane({
    Key? key,
    required this.session,
    required this.store,
  }) : super(key: key);

  final Axios session;
  final RegistroStore store;

  @override
  _BulletinsPaneState createState() => _BulletinsPaneState();
}

class _BulletinsPaneState extends ReloadableState<BulletinsPane> {
  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: Observer(
        builder: (context) => FutureBuilder<List<Bulletin>>(
          future: widget.store.bulletins,
          initialData: [],
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) return Text("${snapshot.error}");
            if (snapshot.hasData && snapshot.data!.isNotEmpty)
              return buildOk(context, snapshot.data!.reversed.toList());

            return LoadingUI();
          },
        ),
      ),
    );
  }

  Widget buildOk(BuildContext context, List<Bulletin> bulletins) {
    final entries = bulletins; // map.entries.toList();

    print("build");

    return Container(
      child: ListView.builder(
        // shrinkWrap: true,
        // separatorBuilder: (_a, _b) => Divider(),
        controller: controller,
        itemBuilder: (context, i) {
          return Padding(
            padding: i == entries.length - 1
                ? EdgeInsets.only(bottom: 8)
                : i == 0
                    ? EdgeInsets.only(top: 8)
                    : EdgeInsets.zero,
            child: Hero(
              tag: entries[i].toString(),
              child: BulletinListItem(
                bulletin: entries[i],
                session: widget.session,
                store: widget.store,
                reload: rebuild,
              ),
            ),
          ).paddingDirectional(horizontal: 16);
        },
        itemCount: entries.length,
      ),
    );
  }
}
