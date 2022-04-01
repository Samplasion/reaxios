import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Bulletin/Bulletin.dart';
import 'package:reaxios/components/ListItems/BulletinListItem.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/LowLevel/ReloadableState.dart';
import 'package:reaxios/components/Utilities/MaxWidthContainer.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import "package:styled_widget/styled_widget.dart";

class BulletinsPane extends StatefulWidget {
  BulletinsPane({
    Key? key,
    required this.session,
  }) : super(key: key);

  final Axios session;

  @override
  _BulletinsPaneState createState() => _BulletinsPaneState();
}

class _BulletinsPaneState extends ReloadableState<BulletinsPane> {
  final ScrollController controller = ScrollController();

  Future<void> _refresh() async {
    await context.read<AppCubit>().loadBulletins();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: BlocBuilder<AppCubit, AppState>(
        bloc: context.watch<AppCubit>(),
        builder: (BuildContext context, state) {
          if (state.bulletins != null)
            return buildOk(context, state.bulletins!.reversed.toList());

          return LoadingUI();
        },
      ),
    );
  }

  Widget buildOk(BuildContext context, List<Bulletin> bulletins) {
    final entries = bulletins; // map.entries.toList();

    print("build");

    return Container(
      child: RefreshIndicator(
        onRefresh: _refresh,
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
              child: Center(
                child: MaxWidthContainer(
                  child: Hero(
                    tag: entries[i].toString(),
                    child: BulletinListItem(
                      bulletin: entries[i],
                      session: widget.session,
                      reload: rebuild,
                    ),
                  ),
                ),
              ),
            ).paddingDirectional(horizontal: 16);
          },
          itemCount: entries.length,
        ),
      ),
    );
  }
}
