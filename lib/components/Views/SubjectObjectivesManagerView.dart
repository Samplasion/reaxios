import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/format.dart';
import 'package:reaxios/screens/settings/base.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils.dart';

class SubjectObjectivesManagerView extends StatefulWidget {
  SubjectObjectivesManagerView({Key? key}) : super(key: key);

  @override
  State<SubjectObjectivesManagerView> createState() =>
      _SubjectObjectivesManagerViewState();
}

class _SubjectObjectivesManagerViewState
    extends State<SubjectObjectivesManagerView> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context);
    final objectives = settings.getSubjectObjectives();
    final keys = objectives.keys.toList()
      ..sort((k1, k2) {
        final item1 = objectives[k1]!;
        final item2 = objectives[k2]!;
        int sort = item1.year.compareTo(item2.year);
        if (sort == 0) {
          sort = item1.subjectName.compareTo(item2.subjectName);
        }
        if (sort == 0) {
          sort = item1.objective.compareTo(item2.objective);
        }
        return sort;
      });
    return Scaffold(
      appBar: AppBar(
        title: Text(context.locale.objectives.managerTitle),
      ),
      body: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverToBoxAdapter(
            child: SettingsHeader(
              title: context.locale.objectives.managerHeading,
              subtitle: context.locale.objectives.managerSubheading,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = objectives[keys[index]]!;
                return Dismissible(
                  key: ValueKey(item.subjectID),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onDismissed: (direction) {
                    settings.setSubjectObjectives(
                      {...objectives}..remove(item.subjectID)!,
                    );
                  },
                  child: ListTile(
                    title: Text(item.subjectName),
                    subtitle: Text.rich(
                      TextSpan(
                        children: context
                            .locale.objectives.managerItemDescription
                            .mapFormatToSpans({
                          "year": TextSpan(text: item.year.toString()),
                          "objective": TextSpan(
                            text: item.objective.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        }),
                      ),
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            color: Theme.of(context).textTheme.caption!.color,
                          ),
                    ),
                  ),
                );
              },
              childCount: keys.length,
            ),
          ),
        ],
      ),
    );
  }
}
