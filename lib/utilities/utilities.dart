import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../collections/money.dart';
import '../extensions/extensions.dart';

class Utility {
  ///
  Color getYoubiColor({
    required String date,
    required String youbiStr,
    required Map<String, String> holidayMap,
  }) {
    Color color = Colors.black.withOpacity(0.2);

    switch (youbiStr) {
      case 'Sunday':
        color = Colors.redAccent.withOpacity(0.2);

      case 'Saturday':
        color = Colors.blueAccent.withOpacity(0.2);

      default:
        color = Colors.black.withOpacity(0.2);
    }

    if (holidayMap[date] != null) {
      color = Colors.greenAccent.withOpacity(0.2);
    }

    return color;
  }

  ///
  int makeCurrencySum({Money? money}) {
    int sum = 0;

    final int yen_10000 = (money != null) ? money.yen_10000 : 0;
    final int yen_5000 = (money != null) ? money.yen_5000 : 0;
    final int yen_2000 = (money != null) ? money.yen_2000 : 0;
    final int yen_1000 = (money != null) ? money.yen_1000 : 0;
    final int yen_500 = (money != null) ? money.yen_500 : 0;
    final int yen_100 = (money != null) ? money.yen_100 : 0;
    final int yen_50 = (money != null) ? money.yen_50 : 0;
    final int yen_10 = (money != null) ? money.yen_10 : 0;
    final int yen_5 = (money != null) ? money.yen_5 : 0;
    final int yen_1 = (money != null) ? money.yen_1 : 0;

    // ignore: join_return_with_assignment
    sum = (yen_10000 * 10000) +
        (yen_5000 * 5000) +
        (yen_2000 * 2000) +
        (yen_1000 * 1000) +
        (yen_500 * 500) +
        (yen_100 * 100) +
        (yen_50 * 50) +
        (yen_10 * 10) +
        (yen_5 * 5) +
        (yen_1 * 1);

    return sum;
  }

  ///
  List<LineTooltipItem> getGraphToolTip(List<LineBarSpot> touchedSpots) {
    final List<LineTooltipItem> list = <LineTooltipItem>[];

    for (final LineBarSpot element in touchedSpots) {
      final TextStyle textStyle = TextStyle(
        color: element.bar.gradient?.colors.first ??
            element.bar.color ??
            Colors.blueGrey,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      );

      final String price =
          element.y.round().toString().split('.')[0].toCurrency();

      list.add(
        LineTooltipItem(
          price,
          textStyle,
          textAlign: TextAlign.end,
        ),
      );
    }

    return list;
  }

  ///
  FlGridData getFlGridData() {
    const FlLine flline = FlLine(color: Colors.white30, strokeWidth: 1);

    return FlGridData(
      verticalInterval: 1,

      //横線
      getDrawingHorizontalLine: (double value) => flline,

      //縦線
      getDrawingVerticalLine: (double value) => flline,
    );
  }
}
