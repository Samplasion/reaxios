// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/entities/Grade/Grade.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils.dart';

class _XY {
  final double x;
  final double y;

  _XY(this.x, this.y);
}

class GradeTimeAverageChart extends StatefulWidget {
  final List<Grade> grades;
  final bool dynamic;

  GradeTimeAverageChart({
    Key? key,
    required List<Grade> grades,
    this.dynamic = false,
  })  : grades = grades..sort((a, b) => a.date.compareTo(b.date)),
        super(key: key);

  @override
  _GradeTimeAverageChartState createState() => _GradeTimeAverageChartState();
}

class _GradeTimeAverageChartState extends State<GradeTimeAverageChart> {
  @override
  Widget build(BuildContext context) {
    final averagesSortedByValue = averages.where((avg) => avg.isFinite).toList()
      ..sort((a, b) => b.compareTo(a));

    double height = 200;
    double maxY = 10;
    double minY = 0;

    if (widget.dynamic) {
      minY = ifNull(
        averagesSortedByValue.min,
        min(3, max(0, ((averagesSortedByValue.min ?? 0) - 2).ceilToDouble())),
        minY,
      );
      maxY = ifNull(
        averagesSortedByValue.max,
        min(10, ((averagesSortedByValue.max ?? 0) + 1).floorToDouble()),
        maxY,
      );
      height = (maxY - minY) * 32;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: height,
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
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (double value, _) {
                  if (value >= 4)
                    return Text(
                      value.toInt().toString(),
                      style: Theme.of(context).textTheme.caption,
                    );
                  return Text("", style: Theme.of(context).textTheme.caption);
                },
              ),
            ),
          ),
          maxY: maxY.toDouble(),
          minY: minY.toDouble(),
          lineBarsData: [
            LineChartBarData(
              spots: averagesXY.map((e) => FlSpot(e.x, e.y)).toList(),
              isCurved: true,
              preventCurveOverShooting: true,
              color: Theme.of(context).primaryColor,
              barWidth: 2,
              isStrokeCapRound: false,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.4),
                    Theme.of(context).primaryColor.withOpacity(0.0)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
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
    );
  }

  List<double> get averages {
    final List<double> averages = [];
    for (var i = 0; i < widget.grades.length; i++) {
      averages.add(
        gradeAverage(
          Provider.of<Settings>(context, listen: false).getAverageMode(),
          widget.grades.take(i + 1).toList(),
        ),
      );
    }
    return averages;
  }

  List<_XY> get averagesXY {
    final List<_XY> averages = [];
    for (var i = 0; i < widget.grades.length; i++) {
      averages.add(
        _XY(
          i.toDouble(),
          gradeAverage(
              Provider.of<Settings>(context, listen: false).getAverageMode(),
              widget.grades.take(i + 1).toList()),
        ),
      );
    }
    return averages.where((element) => element.y.isFinite).toList();
  }
}
