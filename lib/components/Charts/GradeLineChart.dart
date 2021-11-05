// import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/entities/Structural/Structural.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/components/LowLevel/Empty.dart';
import 'package:reaxios/utils.dart';
import 'package:styled_widget/styled_widget.dart';

class GradeLineChart extends StatefulWidget {
  // final List<charts.Series> seriesList;
  final bool animate = true;
  final List<Grade> grades;
  final Period? period;

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
    return [
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
          "Andamento",
          style: TextStyle(
            // color: fg,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ).padding(bottom: 5),
        Text(
          widget.period == null ? "Tutto l'anno" : widget.period!.desc,
          style: TextStyle(
            color: Theme.of(context).cardTheme.color?.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
    ].toRow().padding(bottom: 16, horizontal: 8);
  }

  @override
  Widget build(BuildContext context) {
    late Widget widget;
    if (usefulGrades.length < 2) {
      widget = [
        _getHeader(),
        EmptyUI(
          icon: Icons.error_outline,
          text: "Non ci sono dati",
          subtitle: "Per poter vedere il grafico, devi avere almeno due voti",
        )
      ].toColumn();
    } else {
      final brightness = Theme.of(context).brightness;
      final tooltipColor =
          (Color color, double darkCoefficient, double lightCoefficient) =>
              brightness == Brightness.dark
                  ? color.lighten(darkCoefficient)
                  : color.darken(lightCoefficient);

      final minY = max(0,
          (usefulGrades.map((g) => g.grade).toList().min - 2).ceilToDouble());
      final maxY = min(10,
          (usefulGrades.map((g) => g.grade).toList().max + 2).floorToDouble());

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
                    final descriptor =
                        touchedSpot.barIndex == 0 ? "Media: " : "";
                    return LineTooltipItem(
                      "${gradeToString(touchedSpot.y)}",
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
              topTitles: SideTitles(
                showTitles: false,
              ),
              bottomTitles: SideTitles(
                showTitles: true,
                margin: 8,
                getTitles: (double value) {
                  if (value >= usefulGrades.length) return "";
                  final date = usefulGrades[value.toInt()].date;

                  if (value == 0) {
                    return dateToString(date, short: true);
                  } else {
                    final previous = usefulGrades[value.toInt() - 1].date;
                    if (date.year == previous.year) {
                      if (date.month == previous.month &&
                          value.toInt() != usefulGrades.length - 1) {
                        return dateToString(
                          date,
                          short: true,
                          includeMonth: false,
                          includeYear: false,
                        );
                      } else {
                        return dateToString(
                          date,
                          short: true,
                          includeYear: false,
                        );
                      }
                    } else {
                      return dateToString(date, short: true);
                    }
                  }
                },
                getTextStyles: (context, double value) {
                  return Theme.of(context).textTheme.caption;
                },
              ),
              leftTitles: SideTitles(
                showTitles: true,
                margin: 8,
                reservedSize: 30,
                getTitles: (double value) {
                  return "";
                },
              ),
              rightTitles: SideTitles(
                showTitles: true,
                margin: 8,
                reservedSize: 30,
                getTitles: (double value) {
                  return value.toInt().toString();
                },
                getTextStyles: (context, double value) {
                  return TextStyle(
                    color: tooltipColor(getGradeColor(value), 0.1, 0.2),
                    fontSize: 10,
                  );
                },
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: gradeAverage(usefulGrades),
                  color: tooltipColor(
                      getGradeColor(gradeAverage(usefulGrades)), 0.1, 0.2),
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
                colors: usefulGrades.map((Grade grade) {
                  return getGradeColor(grade.grade);
                }).toList(),
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: false,
                ),
                belowBarData: BarAreaData(
                  show: true,
                  colors: usefulGrades.map((Grade grade) {
                    return getGradeColor(grade.grade).withOpacity(0.2);
                  }).toList(),
                  // gradientColorStops: [0.5, 0.0],
                  // gradientFrom: Offset(0, 0),
                  // gradientTo: Offset(0, 1),
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
        // return [
        //   new charts.LineChart(
        //     _generateData(context),
        //     animate: animate,
        //     primaryMeasureAxis: charts.NumericAxisSpec(
        //       tickProviderSpec: charts.BasicNumericTickProviderSpec(
        //         zeroBound: true,
        //         dataIsInWholeNumbers: false,
        //         desiredTickCount: 5,
        //       ),
        //       renderSpec: charts.GridlineRendererSpec(
        //         labelStyle: charts.TextStyleSpec(
        //           color: Theme.of(context).textTheme.caption!.color!.toChartColor(),
        //         ),
        //         lineStyle: charts.LineStyleSpec(
        //           color: Theme.of(context)
        //               .dividerColor
        //               .withOpacity(0.6)
        //               .toChartColor(),
        //           thickness: 1,
        //         ),
        //       ),
        //     ),
        //     domainAxis: charts.NumericAxisSpec(
        //       tickFormatterSpec: charts.BasicNumericTickFormatterSpec((_) => ""),
        //       renderSpec: charts.GridlineRendererSpec(
        //         labelStyle: charts.TextStyleSpec(
        //           color: Theme.of(context).textTheme.caption!.color!.toChartColor(),
        //         ),
        //         lineStyle: charts.LineStyleSpec(
        //           color: Theme.of(context)
        //               .dividerColor
        //               .withOpacity(0.6)
        //               .toChartColor(),
        //           thickness: 1,
        //         ),
        //       ),
        //     ),
        //   ).height(350),
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
      .where((g) => !isNaN(g.grade) && g.grade != 0)
      .toList()
      .reversed
      .toList();
  List<double> get usefulAverage => grades
      .map((e) =>
          gradeAverage(usefulGrades.take(usefulGrades.indexOf(e) + 1).toList()))
      .toList();

  // List<charts.Series<Grade, int>> _generateData(BuildContext context) {
  //   Color color = Theme.of(context).accentColor;

  //   return [
  //     charts.Series(
  //       id: "Grades",
  //       colorFn: (_, __) => charts.Color(
  //         r: color.red,
  //         g: color.green,
  //         b: color.blue,
  //         a: color.alpha,
  //       ),
  //       domainFn: (Grade grade, _) => usefulGrades.indexOf(grade),
  //       measureFn: (Grade grade, _) => grade.grade,
  //       fillColorFn: (Grade grade, _) =>
  //           getGradeColor(grade.grade).toChartColor(),
  //       data: usefulGrades,
  //       labelAccessorFn: (Grade grade, _) => grade.grade.toString(),
  //     ),
  //   ];
  // }
}
