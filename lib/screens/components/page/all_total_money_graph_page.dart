// ignore_for_file: depend_on_referenced_packages

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../collections/spend_time_place.dart';
import '../../../controllers/controllers_mixin.dart';
import '../../../extensions/extensions.dart';

import '../money_graph_alert.dart';
import '../parts/money_dialog.dart';

class AllTotalMoneyGraphPage extends ConsumerStatefulWidget {
  const AllTotalMoneyGraphPage({
    super.key,
//    this.data,
    this.year,
    required this.alertWidth,
    required this.monthList,
    required this.isar,
    required this.monthlyDateSumMap,
    required this.bankPriceTotalPadMap,
    required this.monthlySpendMap,
    required this.thisMonthSpendTimePlaceList,
    required this.allSpendTimePlaceList,
    required this.dataMap,
  });

//  final List<Map<String, int>>? data;
  final int? year;
  final double alertWidth;
  final List<int> monthList;
  final Isar isar;
  final Map<String, int> monthlyDateSumMap;
  final Map<String, int> bankPriceTotalPadMap;
  final Map<String, int> monthlySpendMap;
  final List<SpendTimePlace> thisMonthSpendTimePlaceList;
  final List<SpendTimePlace> allSpendTimePlaceList;
  final Map<int, List<Map<String, int>>> dataMap;

  @override
  ConsumerState<AllTotalMoneyGraphPage> createState() => _AllTotalMoneyGraphPageState();
}

class _AllTotalMoneyGraphPageState extends ConsumerState<AllTotalMoneyGraphPage>
    with ControllersMixin<AllTotalMoneyGraphPage> {
  LineChartData graphData = LineChartData();
  LineChartData graphData2 = LineChartData();

  List<FlSpot> _flspots = <FlSpot>[];

  int graphMin = 0;
  int graphMax = 0;

  ///
  @override
  Widget build(BuildContext context) {
    _setChartData();

    double circleAvatarWidth = (widget.alertWidth / widget.monthList.length) * 0.3;

    if (circleAvatarWidth > 15) {
      circleAvatarWidth = 15;
    }

    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(width: context.screenSize.width),
              const SizedBox(height: 30),
              Divider(color: Colors.white.withOpacity(0.4), thickness: 5),
              Expanded(child: LineChart(graphData2)),
              SizedBox(
                height: 60,
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: widget.monthList.map((int e) {
                        return GestureDetector(
                          onTap: () {
                            appParamNotifier.setSelectedGraphMonth(month: e);

                            if (widget.year != null) {
                              MoneyDialog(
                                context: context,
                                widget: MoneyGraphAlert(
                                  date: DateTime(widget.year!, e),
                                  isar: widget.isar,
                                  monthlyDateSumMap: widget.monthlyDateSumMap,
                                  bankPriceTotalPadMap: widget.bankPriceTotalPadMap,
                                  monthlySpendMap: widget.monthlySpendMap,
                                  graphMin: graphMin,
                                  graphMax: graphMax,
                                  thisMonthSpendTimePlaceList: widget.thisMonthSpendTimePlaceList,
                                  monthSTPList: widget.allSpendTimePlaceList
                                      .where((SpendTimePlace element) =>
                                          element.date.split('-')[1] == e.toString().padLeft(2, '0'))
                                      .toList(),
                                ),
                                executeFunctionWhenDialogClose: true,
                                ref: ref,
                                from: 'AllTotalMoneyGraphPage',
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: circleAvatarWidth,
                            backgroundColor: (appParamState.selectedGraphMonth == e)
                                ? Colors.yellowAccent.withOpacity(0.2)
                                : Colors.white.withOpacity(0.2),
                            child: Text(
                              e.toString(),
                              style: TextStyle(
                                fontSize: circleAvatarWidth * 0.6,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(width: context.screenSize.width),
              const SizedBox(height: 30),
              Divider(color: Colors.white.withOpacity(0.4), thickness: 5),
              Expanded(child: LineChart(graphData)),
              const SizedBox(height: 60),
            ],
          ),
        ],
      ),
    );
  }

  ///
  void _setChartData() {
    _flspots = <FlSpot>[];

    String lastDate = '';
    int lastTotal = 0;

    int i = 0;
    final List<int> list = <int>[];

    widget.dataMap.forEach((int key, List<Map<String, int>> value) {
      bool flag = false;

      if (widget.year != null) {
        if (key == widget.year) {
          flag = true;
        }
      } else {
        flag = true;
      }

      if (flag) {
        for (final Map<String, int> element in value) {
          for (final MapEntry<String, int> element2 in element.entries) {
            _flspots.add(FlSpot((i + 1).toDouble(), element2.value.toDouble()));

            list.add(element2.value);

            lastDate = element2.key;

            if (element2.value > 0) {
              lastTotal = element2.value;
            }

            i++;
          }
        }
      }
    });

    final List<String> exLastDate = lastDate.split('-');

    if (exLastDate[0] != '') {
      final int lastDateMonthLastDay = DateTime(exLastDate[0].toInt(), exLastDate[1].toInt() + 1, 0).day;

      for (int i = list.length; i <= (list.length + (lastDateMonthLastDay - exLastDate[2].toInt())); i++) {
        _flspots.add(FlSpot(i.toDouble(), lastTotal.toDouble()));
      }
    }

    if (list.isNotEmpty) {
      const int warisuu = 500000;
      final int minValue = list.reduce(min);
      final int maxValue = list.reduce(max);

      graphMin = ((minValue / warisuu).floor()) * warisuu;
      graphMax = ((maxValue / warisuu).ceil()) * warisuu;

      graphData = LineChartData(
        ///
        minX: 1,
        maxX: _flspots.length.toDouble(),
        //
        minY: graphMin.toDouble(),
        maxY: graphMax.toDouble(),

        ///
        lineTouchData: (widget.year == null)
            ? const LineTouchData(enabled: false)
            : LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 2,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      final List<LineTooltipItem> list = <LineTooltipItem>[];

                      for (final LineBarSpot element in touchedSpots) {
                        if (widget.year != null) {
                          final TextStyle textStyle = TextStyle(
                            color: element.bar.gradient?.colors.first ?? element.bar.color ?? Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );

                          final String price = element.y.round().toString().split('.')[0].toCurrency();

                          final String day = DateTime(widget.year!).add(Duration(days: element.x.toInt() - 1)).yyyymmdd;

                          list.add(
                            LineTooltipItem(
                              '$day\n$price',
                              textStyle,
                              textAlign: TextAlign.end,
                            ),
                          );
                        }
                      }

                      return list;
                    }),
              ),

        ///
        gridData: FlGridData(
          verticalInterval: 1,
          getDrawingVerticalLine: (double value) {
            final int day =
                (widget.year != null) ? DateTime(widget.year!).add(Duration(days: value.toInt() - 1)).day : 0;

            final DateTime today = DateTime.now();
            final DateTime newYear = DateTime(today.year);
            int dayOfYear = today.difference(newYear).inDays + 1;

            if (widget.year != DateTime.now().year) {
              dayOfYear = -1;
            }

            return FlLine(
              color: (value.toInt() == dayOfYear)
                  ? const Color(0xFFFBB6CE).withOpacity(0.3)
                  : (day == 1)
                      ? Colors.yellowAccent.withOpacity(0.3)
                      : Colors.transparent,
              strokeWidth: (value.toInt() == dayOfYear) ? 3 : 1,
            );
          },
        ),

        ///
        titlesData: const FlTitlesData(show: false),

        ///
        borderData: FlBorderData(show: false),

        ///
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: _flspots,
            color: (widget.year == null) ? Colors.greenAccent : Colors.yellowAccent,
            dotData: const FlDotData(show: false),
            barWidth: 1,
          ),
        ],
      );

      graphData2 = LineChartData(
        ///
        minX: 1,
        maxX: _flspots.length.toDouble(),
        //
        minY: graphMin.toDouble(),
        maxY: graphMax.toDouble(),

        borderData: FlBorderData(show: false),

        ///
        lineTouchData: const LineTouchData(enabled: false),

        ///
        gridData: const FlGridData(show: false),

        ///
        titlesData: FlTitlesData(
          //-------------------------// 上部の目盛り
          topTitles: const AxisTitles(),
          //-------------------------// 上部の目盛り

          //-------------------------// 下部の目盛り
          bottomTitles: const AxisTitles(),
          //-------------------------// 下部の目盛り

          //-------------------------// 左側の目盛り
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 70,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == graphMin || value == graphMax) {
                  return const SizedBox();
                }

                return SideTitleWidget(
                    meta: meta,
                    space: 4,
                    child: Text(
                      value.toInt().toString().toCurrency(),
                      style: const TextStyle(fontSize: 10),
                    ));
              },
            ),
          ),
          //-------------------------// 左側の目盛り

          //-------------------------// 右側の目盛り
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 70,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == graphMin || value == graphMax) {
                  return const SizedBox();
                }

                return SideTitleWidget(
                    meta: meta,
                    space: 4,
                    child: Text(
                      value.toInt().toString().toCurrency(),
                      style: const TextStyle(fontSize: 10),
                    ));
              },
            ),
          ),
          //-------------------------// 右側の目盛り
        ),

        ///
        lineBarsData: <LineChartBarData>[],
      );
    }
  }
}
