import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SummaryChart extends StatelessWidget {
  const SummaryChart({
    Key? key,
    required this.maxValue,
    required this.data1,
    required this.data2,
  }) : super(key: key);

  final int maxValue;
  final List<FlSpot> data1;
  final List<FlSpot> data2;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: -500,
        maxY: maxValue.toDouble(),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((e) {
                return LineTooltipItem(
                  e.y.toStringAsFixed(0),
                  Theme.of(context).textTheme.titleMedium ?? const TextStyle(),
                );
              }).toList();
            },
          ),
        ),
        gridData: buildFlGridData(),
        titlesData: buildFlTitlesData(context),
        lineBarsData: [
          buildLineChartBarData(
            data1,
            [Colors.tealAccent.withOpacity(0.5)],
          ),
          buildLineChartBarData(
            data2,
            [Colors.redAccent.withOpacity(0.5)],
          ),
        ],
      ),
    );
  }

  LineChartBarData buildLineChartBarData(
      List<FlSpot> data, List<Color> colors) {
    return LineChartBarData(
      spots: data,
      isCurved: true,
      preventCurveOverShooting: true,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: colors.map((color) => color.withOpacity(0.2)).toList(),
        ),
      ),
      gradient: LinearGradient(colors: colors),
    );
  }

  FlTitlesData buildFlTitlesData(BuildContext context) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: false,
          reservedSize: 22,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: false,
          reservedSize: 30,
          interval: maxValue / 5,
        ),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  FlGridData buildFlGridData() {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: true,
      horizontalInterval: maxValue / 2,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.white10,
          strokeWidth: 0.5,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: Colors.transparent,
          strokeWidth: 1,
          dashArray: value == 0 ? null : [4],
        );
      },
    );
  }
}
