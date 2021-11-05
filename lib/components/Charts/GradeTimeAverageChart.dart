// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/api/utils/utils.dart';
import 'package:reaxios/utils.dart';
import 'package:styled_widget/styled_widget.dart';

class _XY {
  final double x;
  final double y;

  _XY(this.x, this.y);
}

class GradeTimeAverageChart extends StatefulWidget {
  final List<Grade> grades;

  GradeTimeAverageChart({Key? key, required this.grades}) : super(key: key);

  @override
  _GradeTimeAverageChartState createState() => _GradeTimeAverageChartState();
}

class _GradeTimeAverageChartState extends State<GradeTimeAverageChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor:
                  Theme.of(context).primaryColor.contrastText.withOpacity(0.5),
              tooltipPadding: const EdgeInsets.all(5),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  return LineTooltipItem(
                    '${touchedSpot.y}',
                    TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: false,
          ),
          borderData: FlBorderData(
            show: false,
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: SideTitles(showTitles: false),
            rightTitles: SideTitles(showTitles: false),
            bottomTitles: SideTitles(showTitles: false),
            leftTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTextStyles: (context, _) =>
                    Theme.of(context).textTheme.caption,
                getTitles: (double value) {
                  if (value >= 4) return value.toInt().toString();
                  return "";
                },
                checkToShowTitle: (_, __, ___, ____, _____) => true),
          ),
          maxY: 10,
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: averagesXY.map((e) => FlSpot(e.x, e.y)).toList(),
              isCurved: true,
              preventCurveOverShooting: true,
              // colors: averages.map((e) => getGradeColor(e)).toList(),
              colors: [Theme.of(context).primaryColor],
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.4),
                  Theme.of(context).primaryColor.withOpacity(0.0)
                ],
                gradientFrom: Offset(0, 0),
                gradientTo: Offset(0, 1),
              ),
            ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(y: 6, color: Theme.of(context).accentColor),
            ],
          ),
        ),
      ),
    ).paddingDirectional(horizontal: 8);
  }

  List<double> get averages {
    final List<double> averages = [];
    for (var i = 0; i < widget.grades.length; i++) {
      averages.add(gradeAverage(widget.grades.take(i + 1).toList()));
    }
    return averages;
  }

  List<_XY> get averagesXY {
    final List<_XY> averages = [];
    for (var i = 0; i < widget.grades.length; i++) {
      averages.add(
          _XY(i.toDouble(), gradeAverage(widget.grades.take(i + 1).toList())));
    }
    return averages;
  }
}
