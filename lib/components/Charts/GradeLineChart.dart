// import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/utils/utils.dart' hide gradeAverage;
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/components/Utilities/NiceHeader.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils.dart';
import 'package:styled_widget/styled_widget.dart';

class GradeLineChart extends StatefulWidget {
  // final List<charts.Series> seriesList;
  final bool animate = true;
  final List<Grade> grades;
  final String? period;

  GradeLineChart(this.grades, {this.period});

  // /// Creates a [TimeSeriesChart] with sample data and no transition.
  // factory SimpleTimeSeriesChart.withSampleData() {
  //   return new SimpleTimeSeriesChart(
  //     _createSampleData(),
  //     // Disable animations for image tests.
  //     animate: false,
  //   );
  // }

  @override
  _GradeLineChartState createState() => _GradeLineChartState();
}

class _GradeLineChartState extends State<GradeLineChart> {
  bool get animate => widget.animate;
  List<Grade> get grades => widget.grades;

  String text = "";

  Widget _getHeader() {
    return NiceHeader(
      leading: Icon(Icons.auto_graph),
      title: context.locale.charts.trend,
      subtitle: widget.period == null
          ? context.locale.charts.scopeAllYear
          : widget.period!,
    );
  }

  @override
  Widget build(BuildContext context) {
    late Widget widget;
    final averageMode = Provider.of<Settings>(context).getAverageMode();
    if (usefulGrades.length < 2) {
      widget = [
        _getHeader(),
        EmptyUI(
          icon: Icons.error_outline,
          text: context.locale.charts.noData,
          subtitle: context.locale.charts.fewGradesText,
        )
      ].toColumn();
    } else {
      final brightness = Theme.of(context).brightness;
      final tooltipColor =
          (Color color, double darkCoefficient, double lightCoefficient) =>
              brightness == Brightness.dark
                  ? color.lighten(darkCoefficient)
                  : color.darken(lightCoefficient);

      final minY = max(
          0,
          ((usefulGrades.map((g) => g.grade).toList().min ?? 0) - 2)
              .ceilToDouble());
      final maxY = min(
          10,
          ((usefulGrades.map((g) => g.grade).toList().max ?? 0) + 2)
              .floorToDouble());

      widget = <Widget>[
        _getHeader(),
        LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor:
                    tooltipColor(Theme.of(context).cardColor, 0.1, 0.1)
                        .withAlpha((0.65 * 255).round()),
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    return LineTooltipItem(
                      "${context.gradeToString(touchedSpot.y)}",
                      TextStyle(
                        color: tooltipColor(
                            getGradeColor(touchedSpot.y), 0.2, 0.1),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  // margin: 8,
                  getTitlesWidget: (double value, meta) {
                    final _ = (String s) => Text(
                          s,
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(fontWeight: FontWeight.w100),
                        );
                    if (value >= usefulGrades.length ||
                        value != value.truncate()) return _("");
                    final date = usefulGrades[value.truncate()].date;

                    print(value);

                    if (value.truncate() == 0) {
                      return _(context.dateToString(date, short: true));
                    } else {
                      final previous = usefulGrades[value.truncate() - 1].date;
                      if (date.year == previous.year) {
                        if (date.month == previous.month &&
                            value.toInt() != usefulGrades.length - 1) {
                          return _(context.dateToString(
                            date,
                            short: true,
                          ));
                        } else {
                          return _(context.dateToString(
                            date,
                            short: true,
                          ));
                        }
                      } else {
                        return _(context.dateToString(date, short: true));
                      }
                    }
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (double value, _) {
                    return Text("");
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    // margin: 8,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (double value, _) {
                      return Text(
                        "   ${value.truncate().toString()}",
                        style: TextStyle(
                          color: tooltipColor(getGradeColor(value), 0.1, 0.2),
                          fontSize: 10,
                        ),
                      );
                    }),
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: gradeAverage(averageMode, usefulGrades),
                  color: tooltipColor(
                    getGradeColor(gradeAverage(averageMode, usefulGrades)),
                    0.1,
                    0.2,
                  ),
                  // strokeWidth: 2,
                ),
              ],
            ),
            minX: 0,
            maxX: usefulGrades.length - 1,
            minY: minY.toDouble(),
            maxY: maxY.toDouble(),
            lineBarsData: [
              LineChartBarData(
                spots: usefulGrades.map((Grade grade) {
                  return FlSpot(
                    usefulGrades.indexOf(grade).toDouble(),
                    grade.grade,
                  );
                }).toList(),
                isCurved: true,
                gradient: LinearGradient(
                  colors: usefulGrades.map((Grade grade) {
                    return getGradeColor(grade.grade);
                  }).toList(),
                ),
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: false,
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: usefulGrades.map((Grade grade) {
                      return getGradeColor(grade.grade).withOpacity(0.2);
                    }).toList(),
                  ),
                  spotsLine: BarAreaSpotsLine(
                    show: true,
                    flLineStyle: FlLine(
                      color: Colors.blueGrey,
                      strokeWidth: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).height((maxY - minY) * 38),
      ].toColumn(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start);
    }

    return widget
        .padding(all: 24)
        .borderRadius(all: 15)
        .backgroundColor(Theme.of(context).cardColor, animate: true)
        .clipRRect(all: 15) // clip ripple
        .borderRadius(all: 15, animate: true)
        .elevation(
          Theme.of(context).cardTheme.elevation ?? 8,
          borderRadius: BorderRadius.circular(15),
          shadowColor: Theme.of(context).shadowColor,
        )
        .padding(all: 16)
        .animate(Duration(milliseconds: 150), Curves.easeOut);
  }

  List<Grade> get usefulGrades => grades
      .where((g) {
        return !isNaN(g.grade) && g.grade != 0;
      })
      .toList()
      .reversed
      .toList();
  List<double> get usefulAverage => grades
      .map(
        (e) => gradeAverage(
          Provider.of<Settings>(context, listen: false).getAverageMode(),
          usefulGrades.take(usefulGrades.indexOf(e) + 1).toList(),
        ),
      )
      .toList();
}
