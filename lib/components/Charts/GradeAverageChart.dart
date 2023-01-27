import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/utils/utils.dart' hide gradeAverage;
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/LowLevel/Loading.dart';
import 'package:reaxios/components/Utilities/NiceHeader.dart';
import 'package:reaxios/cubit/app_cubit.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils.dart';
import 'package:fl_chart/fl_chart.dart';

class _GradeChartEntry {
  _GradeChartEntry(this.name, this.avg);

  final String name;
  final double avg;

  Color getColor(BuildContext context) {
    return getGradeColor(context, avg);
  }
}

class GradeAverageChart extends StatefulWidget {
  const GradeAverageChart({
    Key? key,
    this.period,
  }) : super(key: key);

  final Period? period;

  @override
  _GradeAverageChartState createState() => _GradeAverageChartState();
}

class _GradeAverageChartState extends State<GradeAverageChart> {
  bool _showAllYear = false;
  Period? getPeriod(List<Grade> grades) {
    if (grades.where((g) => g.period == widget.period?.desc).isEmpty) {
      return null;
    }

    if (_showAllYear) {
      return null;
    }

    return widget.period;
  }

  List<_GradeChartEntry> _getEntries(List<Grade> grades) {
    final period = getPeriod(grades);
    grades =
        grades.where((g) => period == null || g.period == period.desc).toList();
    final names = grades.map((g) => g.subject).toSet().toList();
    return names
        .map<_GradeChartEntry>(
          (name) => _GradeChartEntry(
            name,
            gradeAverage(
                Provider.of<Settings>(context, listen: false).getAverageMode(),
                grades.where((g) => g.subject == name).toList()),
          ),
        )
        .toList()
      ..sort((a, b) => a.avg.compareTo(b.avg));
  }

  List<int> range(int max, [int min = 0]) =>
      List<int>.generate(max - min, (i) => i + min);

  @override
  void initState() {
    super.initState();

    // widget.store.fetchGrades(widget.session);
    // widget.store.grades!.then((grades) {
    //   SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
    //     if (mounted) setState(() {});
    //   });
    // });
  }

  Widget _buildChart(List<_GradeChartEntry> grades, double average) {
    final brightness = Theme.of(context).brightness;
    final tooltipColor =
        (Color color, double darkCoefficient, double lightCoefficient) =>
            brightness == Brightness.dark
                ? color.lighten(lightCoefficient)
                : color.darken(darkCoefficient);
    // final average =
    //     grades.map((g) => g.avg).reduce((a, b) => a + b) / grades.length;
    final rawPrecisionValue = 4;
    final truncatedAverage =
        (average * rawPrecisionValue).truncateToDouble() / rawPrecisionValue;
    return Container(
      constraints: BoxConstraints(minHeight: 360, maxHeight: 360),
      padding: const EdgeInsets.only(top: 6),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 11,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor:
                  tooltipColor(Theme.of(context).cardTheme.color!, 0.1, 0.1)
                      .withAlpha((0.65 * 255).round()),
              tooltipPadding: const EdgeInsets.all(8),
              // tooltipBottomMargin: 8,
              getTooltipItem: (
                BarChartGroupData group,
                int groupIndex,
                BarChartRodData rod,
                int rodIndex,
              ) {
                return BarTooltipItem(
                  '${grades[groupIndex].name}: ${context.gradeToString(grades[groupIndex].avg, showAsNumber: true, round: false)}',
                  TextStyle(
                    color: tooltipColor(rod.gradient!.colors[1], 0.2, -0.1),
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                // margin: 10,
                reservedSize: 30,
                getTitlesWidget: (double value, _) {
                  if (value < 0 || value >= grades.length) return Text("");
                  return Text(Utils.generateAbbreviation(
                      3, grades[value.toInt()].name.toTitleCase()));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, _) {
                  if (value < 1 || value > 10) return Text("");
                  return Text(value.toInt().toString());
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: grades.map((g) {
            return BarChartGroupData(
              x: grades.indexOf(g),
              barRods: [
                BarChartRodData(
                  toY: g.avg,
                  width: 16,
                  gradient: LinearGradient(
                    colors:
                        getGradient(context, g.getColor(context), strength: 2),
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  // isRound: true,
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            horizontalInterval: 1 / rawPrecisionValue,
            getDrawingHorizontalLine: (value) {
              value = (value * rawPrecisionValue).truncateToDouble() /
                  rawPrecisionValue;
              // print(truncatedAverage);
              if (value > 10) {
                return FlLine(
                  color: Colors.transparent,
                );
              }
              if (value == 6) {
                return FlLine(color: Colors.green);
              }
              return value == truncatedAverage
                  ? FlLine(
                      color: Colors.orange,
                      dashArray: [8],
                    )
                  : FlLine(
                      color: value % 1 == 0 || value % 1 == 0.5
                          ? Theme.of(context).dividerColor
                          : Colors.transparent,
                      strokeWidth: 1,
                      dashArray: value % 1 == 0.5 ? [5] : null,
                    );
            },
          ),
        ),
      ),
    ); //.padding(top: 6).height(360);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      bloc: context.watch<AppCubit>(),
      builder: (BuildContext context, state) {
        final grades = _getEntries(state.grades ?? []);
        final period = getPeriod(state.grades ?? []);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            margin: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: PageTransitionSwitcher(
                transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_showAllYear),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.grades != null) ...[
                          GestureDetector(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: NiceHeader(
                                  title:
                                      context.loc.translate("charts.averages"),
                                  subtitle: period == null
                                      ? context.loc
                                          .translate("charts.scopeAllYear")
                                      : period.desc,
                                  leading: Icon(Icons.av_timer),
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _showAllYear = !_showAllYear;
                              });
                            },
                          ),
                          if (grades.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 24,
                                left: 8,
                                right: 8,
                              ),
                              child: EmptyUI(
                                icon: Icons.error_outline,
                                text: context.loc
                                    .translate("main.noDataForPeriod"),
                              ),
                            )
                          else
                            AnimatedBuilder(
                              animation: Provider.of<Settings>(context),
                              builder: (context, _) {
                                return _buildChart(
                                  grades,
                                  gradeAverage(
                                    Provider.of<Settings>(context)
                                        .getAverageMode(),
                                    state.grades!,
                                  ),
                                );
                              },
                            )
                        ] else
                          Container(
                            padding: const EdgeInsets.only(top: 10),
                            color: Colors.transparent,
                            child: LoadingUI(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        // .padding(horizontal: 16, bottom: 16)
        // .borderRadius(all: 15)
        // .backgroundColor(Theme.of(context).cardTheme.color!, animate: true)
        // .clipRRect(all: 15) // clip ripple
        // .borderRadius(all: 15, animate: true)
        // .elevation(
        //   Theme.of(context).cardTheme.elevation ?? 8,
        //   borderRadius: BorderRadius.circular(15),
        //   shadowColor: Theme.of(context).shadowColor,
        // )
        // .padding(bottom: 16)
        // .animate(Duration(milliseconds: 150), Curves.easeOut);
      },
    );
  }
}
