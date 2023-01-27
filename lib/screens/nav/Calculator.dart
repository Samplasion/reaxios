import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/average.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/enums/AverageMode.dart';
import 'package:reaxios/showDialogSuper.dart';
import 'package:reaxios/timetable/structures/Settings.dart';

import '../../api/Axios.dart';
import '../../api/entities/Grade/Grade.dart';
import '../../api/entities/Structural/Structural.dart';
import '../../components/LowLevel/Empty.dart';
import '../../components/LowLevel/Loading.dart';
import '../../components/LowLevel/MaybeMasterDetail.dart';
import '../../components/Utilities/AlertBottomSheet.dart';
import '../../components/Utilities/BoldText.dart';
import '../../components/Utilities/GradeAvatar.dart';
import '../../components/Utilities/GradeText.dart';

import '../../utils.dart';

class CalculatorPane extends StatefulWidget {
  final Period? period;
  final Axios session;
  final Function() openMainDrawer;

  const CalculatorPane({
    required this.period,
    required this.session,
    required this.openMainDrawer,
    Key? key,
  }) : super(key: key);

  @override
  _CalculatorPaneState createState() => _CalculatorPaneState();
}

class _CalculatorPaneState extends State<CalculatorPane>
    with SingleTickerProviderStateMixin {
  final List<Grade> _grades = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = BottomSheet.createAnimationController(this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    return BlocBuilder<AppCubit, AppState>(
      bloc: cubit,
      builder: (BuildContext context, AppState state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.loc.translate("drawer.calculator")),
            leading: MaybeMasterDetail.of(context)!.isShowingMaster
                ? null
                : Builder(builder: (context) {
                    return IconButton(
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
                      onPressed: widget.openMainDrawer,
                      icon: Icon(Icons.menu),
                    );
                  }),
          ),
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: _buildBody(),
          bottomNavigationBar: _buildBottomBar(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton: GestureDetector(
            onLongPress: () {
              setState(() {
                _grades.clear();
              });
            },
            behavior: HitTestBehavior.opaque,
            child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              onPressed: () => _showFabDialog(
                  cubit.subjects, context.read<AppCubit>().currentPeriod),
              child: Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  void _showFabDialog(List<String> subjects, Period? period) async {
    final cubit = context.read<AppCubit>();
    final grades = cubit.grades;
    await showModalBottomSheet(
      context: context,
      enableDrag: true,
      isDismissible: true,
      builder: (context) {
        return AlertBottomSheet(
          enableDrag: true,
          animationController: _animationController,
          scrollable: true,
          title: Text(context.loc.translate("calculator.addGrade")),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (subjects.isNotEmpty)
                  ListTile(
                    title: Text(
                        context.loc.translate("calculator.addFromSubject")),
                    onTap: () async {
                      Navigator.pop(context);
                      await _showSubjectDialog(grades, subjects);
                    },
                  ),
                ListTile(
                  title:
                      Text(context.loc.translate("calculator.addFromScratch")),
                  onTap: _showNewGradeDialog,
                ),
                ListTile(
                  title: Text(context.loc.translate("calculator.addAllGrades")),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _grades.addAll(
                        grades.where((element) => element.weight > 0),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(context.materialLocale.closeButtonLabel),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
          onClosing: () {
            setState(() {});
          },
        );
      },
    );
    // setState(() {
    //   _grades.add(Grade.fakeFromDouble((Random().nextDouble() * 8) + 2));
    // });
  }

  Widget _buildBody() {
    if (_grades.isEmpty) {
      return EmptyUI(
        icon: Icons.info_outline,
        text: context.loc.translate("calculator.infoTitle"),
        subtitle: context.loc.translate("calculator.infoMessage"),
      );
    }
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 6 / 8,
      ),
      itemCount: _grades.length,
      itemBuilder: (context, index) {
        final grade = _grades[index];

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.hardEdge,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onLongPress: () {
                setState(() {
                  _grades.removeAt(index);
                });
              },
              onTap: () async {
                final double? grade = await showDialogSuper(
                  context: context,
                  builder: (context) {
                    return NewGradeDialog(edit: true);
                  },
                );

                if (grade != null) {
                  setState(() {
                    _grades.insert(
                      index,
                      _grades[index].copyWith(grade: grade),
                    );
                    _grades.removeAt(index + 1);
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    GradeAvatar(grade: grade, radius: 36),
                    Spacer(),
                    if (grade.subject.isNotEmpty)
                      BoldText(text: grade.subject).asText(
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      BoldText(
                        text:
                            context.loc.translate("calculator.unknownSubject"),
                      ).asText(
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (grade.period.isNotEmpty)
                      Text(
                        grade.period,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        context.loc.translate("calculator.unknownPeriod"),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> _showSubjectDialog(
    List<Grade> grades,
    List<String> subjects,
  ) async {
    final List<Grade>? selected = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return SubjectSelectorBottomSheet(subjects: subjects, grades: grades);
      },
    );

    setState(() {
      _grades.addAll(selected ?? []);
    });
  }

  Future<dynamic> _showNewGradeDialog() async {
    final double? grade = await showDialogSuper(
      context: context,
      builder: (context) {
        return NewGradeDialog();
      },
    );

    if (grade != null) {
      setState(() {
        _grades.add(Grade.fakeFromDouble(grade));
      });
    }
  }

  int _steps = 1;
  final List<int> _possibleSteps = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  double _targetAverage = 6;
  final List<double> _possibleTargets = [
    6,
    6.25,
    6.5,
    6.75,
    7,
    7.25,
    7.5,
    7.75,
    8,
    8.25,
    8.5,
    8.75,
    9,
    9.25,
    9.5,
    9.75,
    10
  ];

  Widget _buildBottomBar() {
    final average = _grades.isEmpty
        ? 0.0
        : gradeAverage(AverageMode.allGradesAverage, _grades).toDouble();
    final viableTargets = _possibleTargets.where((target) => target > average);

    final widgets = <Widget>[
      DropdownButton(
        isDense: true,
        items: _possibleSteps.map((n) {
          return DropdownMenuItem(
            child: Text("$n"),
            value: n,
          );
        }).toList(),
        onChanged: (n) => setState(() {
          if (n == null || n is! int) return;
          _steps = n;
        }),
        value: _steps,
      ),
      RichText(
        text: GradeText(
          context,
          grade: toReachAverage(
            _grades.map((g) => [g.grade, g.weight]).toList(),
            viableTargets.contains(_targetAverage)
                ? _targetAverage
                : viableTargets.first,
            _steps,
          ).toDouble(),
        ),
      ),
      DropdownButton(
        isDense: true,
        items: viableTargets.map((n) {
          return DropdownMenuItem(
            child: Text.rich(GradeText(context, grade: n)),
            value: n,
          );
        }).toList(),
        onChanged: (n) => setState(() {
          if (n == null || n is! num) return;
          _targetAverage = n.toDouble();
        }),
        value: viableTargets.contains(_targetAverage)
            ? _targetAverage
            : viableTargets.first,
      ),
    ];

    final bottomText =
        context.loc.translate("calculator.gradeCalculatorBottom");
    final withIndices = bottomText.split(RegExp(r'[{}]'));
    final withIndicesAndWidgets = withIndices.map((text) {
      final num = int.tryParse(text);
      if (num != null && num >= 0 && num < widgets.length) {
        return WidgetSpan(child: widgets[int.parse(text)]);
      } else {
        return TextSpan(text: text);
      }
    }).toList();

    return BottomAppBar(
      color: Theme.of(context).cardTheme.color!.withOpacity(0.7),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16,
            sigmaY: 16,
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 1.5 * kToolbarHeight,
              padding: EdgeInsets.only(
                  bottom: 8 + (_grades.length >= 2 ? 8 : 0), top: 16),
              child: Row(
                children: [
                  if (_grades.length < 1) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        context.loc.translate("calculator.selectAtLeast1"),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ] else ...[
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_grades.length >= 2)
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: context.loc
                                            .translate("calculator.average"),
                                        style:
                                            Theme.of(context).textTheme.caption,
                                      ),
                                      GradeText(context, grade: average),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (viableTargets.isNotEmpty)
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text.rich(
                                      TextSpan(children: withIndicesAndWidgets),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get periodsBeforeOrNow {
    return false;
  }
}

class SubjectSelectorBottomSheet extends StatefulWidget {
  final List<String> subjects;
  final List<Grade> grades;
  SubjectSelectorBottomSheet({
    required this.subjects,
    required this.grades,
    Key? key,
  })  : assert(subjects.isNotEmpty),
        super(key: key);

  @override
  _SubjectSelectorBottomSheetState createState() =>
      _SubjectSelectorBottomSheetState();
}

class _SubjectSelectorBottomSheetState
    extends State<SubjectSelectorBottomSheet> {
  late String _selectedSubject;
  final List<Grade> _grades = [];

  @override
  void initState() {
    super.initState();
    _selectedSubject = (widget.subjects..sort((a, b) => a.compareTo(b))).first;
  }

  @override
  Widget build(BuildContext context) {
    final subjectGrades = widget.grades
        .where((element) =>
            element.subject == _selectedSubject &&
            element.grade.isFinite &&
            element.weight > 0)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return AlertBottomSheet(
      title: Text(context.loc.translate("calculator.addFromSubject")),
      enableDrag: false,
      onClosing: () {},
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton(
            items: widget.subjects
                .map((s) => DropdownMenuItem(
                      child: Text(s),
                      value: s,
                    ))
                .toList()
              ..sort((a, b) => a.value!.compareTo(b.value!)),
            value: _selectedSubject,
            onChanged: (s) {
              final subj = (s as String?);
              if (subj != null) {
                setState(() {
                  _selectedSubject = subj;
                  _grades.clear();
                });
              }
            },
          ),
          if (subjectGrades.isNotEmpty)
            ...subjectGrades.map((grade) {
              return CheckboxListTile(
                secondary: GradeAvatar(
                  grade: grade,
                ),
                title: Text(grade.teacher),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (grade.period.isNotEmpty) Text(grade.period),
                    const SizedBox(height: 4),
                    Text(
                      context.dateToString(grade.date),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
                isThreeLine: true,
                value: _grades.contains(grade),
                onChanged: (isChecked) {
                  setState(() {
                    if (isChecked == true) {
                      _grades.add(grade);
                    } else {
                      _grades.remove(grade);
                    }
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
                checkColor: Theme.of(context).colorScheme.onPrimary,
              );
            })
          else ...[
            Text(
              context.loc.translate("calculator.noGrades"),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          child: Text(context.materialLocale.cancelButtonLabel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(context.materialLocale.okButtonLabel),
          onPressed: () {
            Navigator.pop(context, _grades);
          },
        ),
      ],
    );
  }
}

class NewGradeDialog extends StatefulWidget {
  final bool edit;
  NewGradeDialog({this.edit = false, Key? key}) : super(key: key);

  @override
  _NewGradeDialogState createState() => _NewGradeDialogState();
}

class _NewGradeDialogState extends State<NewGradeDialog> {
  final TextEditingController _gradeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.edit
          ? context.loc.translate("calculator.editGrade")
          : context.loc.translate("calculator.addGrade")),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _gradeController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: widget.edit
                    ? context.loc.translate("calculator.editGrade")
                    : context.loc.translate("calculator.addGrade"),
                border: OutlineInputBorder(),
                errorMaxLines: 2,
              ),
              onChanged: (s) {
                setState(() {});
              },
              onFieldSubmitted: (value) {
                if (isValid && double.tryParse(value) != null) {
                  Navigator.pop(context, double.parse(_gradeController.text));
                }
              },
              validator: (s) {
                if (s == null || s.isEmpty) {
                  return context.loc.translate("calculator.gradeOutOfRange");
                }
                final grade = double.tryParse(s);
                if (grade == null || grade.isNaN) {
                  return context.loc.translate("calculator.gradeOutOfRange");
                }
                if (grade < 1 || grade > 10) {
                  return context.loc.translate("calculator.gradeOutOfRange");
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(context.materialLocale.cancelButtonLabel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(context.materialLocale.okButtonLabel),
          onPressed: isValid
              ? () {
                  Navigator.pop(context, double.parse(_gradeController.text));
                }
              : null,
        ),
      ],
    );
  }

  bool get isValid =>
      _formKey.currentState != null && _formKey.currentState!.validate();
}
