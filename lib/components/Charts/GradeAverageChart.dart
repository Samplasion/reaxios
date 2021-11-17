// import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:reaxios/api/Axios.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/system/Store.dart';
import 'package:reaxios/utils.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:fl_chart/fl_chart.dart';

class _GradeChartEntry {
  _GradeChartEntry(this.name, this.avg);

  final String name;
  final double avg;

  Color get color {
    return getGradeColor(avg);
  }
}

class GradeAverageChart extends StatefulWidget {
  const GradeAverageChart({
    Key? key,
    required this.store,
    required this.session,
    this.period,
  }) : super(key: key);

  final RegistroStore store;
  final Axios session;
  final Period? period;

  @override
  _GradeAverageChartState createState() => _GradeAverageChartState();
}

class _GradeAverageChartState extends State<GradeAverageChart> {
  List<_GradeChartEntry> _getEntries(List<Grade> grades) {
    final names = grades.map((g) => g.subject).toSet().toList();
    return names
        .map<_GradeChartEntry>((name) => _GradeChartEntry(name,
            gradeAverage(grades.where((g) => g.subject == name).toList())))
        .toList()
      ..sort((a, b) => a.avg.compareTo(b.avg));
  }

  List<int> range(int max, [int min = 0]) =>
      List<int>.generate(max - min, (i) => i + min);

  @override
  void initState() {
    super.initState();

    widget.store.fetchGrades(widget.session);
    widget.store.grades!.then((grades) {
      SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
        if (mounted) setState(() {});
      });
    });
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
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 11,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: tooltipColor(Theme.of(context).cardColor, 0.1, 0.1)
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
                  color: tooltipColor(rod.colors[1], 0.2, -0.1),
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            margin: 10,
            reservedSize: 30,
            getTitles: (double value) {
              if (value < 0 || value >= grades.length) return "";
              return Utils.generateAbbreviation(
                  3, grades[value.toInt()].name.toTitleCase());
            },
          ),
          leftTitles: SideTitles(
            showTitles: true,
            getTitles: (double value) {
              if (value < 1 || value > 10) return "";
              return value.toInt().toString();
            },
          ),
          rightTitles: SideTitles(
            showTitles: false,
          ),
          topTitles: SideTitles(
            showTitles: false,
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
                y: g.avg,
                width: 16,
                colors: [g.color.darken(0.22), g.color, g.color.lighten(0.15)],
                // isRound: true,
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
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
    ).padding(top: 6).height(360);
  }

  @override
  Widget build(BuildContext context) {
    return <Widget>[
      [
        Icon(Icons.auto_graph)
            .iconSize(50)
            // .iconColor(fg)
            // .decorated(
            //   color: bg(context),
            //   borderRadius: BorderRadius.circular(30),
            // )
            .constrained(height: 50, width: 50)
            .padding(right: 10),
        <Widget>[
          Text(
            context.locale.charts.averages,
            style: TextStyle(
              // color: fg,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ).padding(bottom: 5),
          Text(
            widget.period == null
                ? context.locale.charts.scopeAllYear
                : widget.period!.desc,
            style: TextStyle(
              color: Theme.of(context).cardTheme.color?.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
      ].toRow().padding(top: 24, horizontal: 8),
      // if (chart == null) Center(child: CircularProgressIndicator()) else chart!,
      FutureBuilder<List<Grade>>(
        future: widget.store.grades,
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasError && snapshot.hasData) {
            final grades = _getEntries(snapshot.data!);

            if (grades.isEmpty)
              return EmptyUI(
                icon: Icons.error_outline,
                text: context.locale.main.noDataForPeriod,
              ).padding(top: 24, horizontal: 8);

            // print("Chart rebuilt");

            // return
            return _buildChart(grades, gradeAverage(snapshot.data!));
          }
          if (snapshot.hasError) return Text("${snapshot.error}");
          return Center(child: CircularProgressIndicator());
        },
      ),
    ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
        .padding(horizontal: 16, bottom: 16)
        .borderRadius(all: 15)
        .backgroundColor(Theme.of(context).cardColor, animate: true)
        .clipRRect(all: 15) // clip ripple
        .borderRadius(all: 15, animate: true)
        .elevation(
          Theme.of(context).cardTheme.elevation ?? 8,
          borderRadius: BorderRadius.circular(15),
          shadowColor: Theme.of(context).shadowColor,
        )
        .padding(bottom: 16)
        .animate(Duration(milliseconds: 150), Curves.easeOut);
  }
}
