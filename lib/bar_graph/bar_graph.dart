import 'package:chat_app_final/Database/expense_database.dart';
import 'package:chat_app_final/bar_graph/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;
  const MyBarGraph(
      {super.key, required this.monthlySummary, required this.startMonth});

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

int monthlyExpense = 5000;

class _MyBarGraphState extends State<MyBarGraph> {
  List<IndividualBar> barData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)=> scrollToEnd);

  }

  //monthly data initialize
  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) => IndividualBar(
        x: index,
        y: widget.monthlySummary[index],
      ),
    );
  }

  //scroll to latest month
  final ScrollController _scrollController=ScrollController();
  void scrollToEnd(){
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  //Alert box when the expense reaches expense
  void alertBox(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16.0),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 40,
              ),
              SizedBox(width: 16), // Add spacing between the icon and text
              Expanded(
                child: Text(
                  "Chill Bro!",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ),
            ],
          ),
          content: const Text("You have exceeded the ₹5000 limit",
              style: TextStyle(
                fontSize: 18,
              )),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  //calculate max for upper limit of graph

  double calculateMax() {
    double max = monthlyExpense.toDouble();

    widget.monthlySummary.sort();

    max = widget.monthlySummary.last * 1.05;
    if (widget.monthlySummary.last < monthlyExpense.toDouble()) {
      return monthlyExpense.toDouble();
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    //current expense
    double? currentMonthExpense=Provider.of<ExpenseDatabase>(context).currentMonthExpense;

    //initialize
    initializeBarData();
    //alert box trigger if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentMonthExpense! >= monthlyExpense) {
        alertBox(context);
      }
    });

    //bar dimension sizes
    double barWidth = 20;
    double spaceBetweenBars = 15;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: SizedBox(
        width:
            barWidth * barData.length + spaceBetweenBars * (barData.length - 1),
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: calculateMax(),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) =>
                      getBottomTitles(value, meta, widget.startMonth),
                  reservedSize: 24,
                ),
              ),
            ),
            barGroups: barData
                .map(
                  (data) => BarChartGroupData(
                    x: data.x,
                    barRods: [
                      BarChartRodData(
                          toY: data.y,
                          width: barWidth,
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.deepPurple.shade200,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: calculateMax(),
                            color: Colors.deepPurple.shade50,
                          )),
                    ],
                  ),
                )
                .toList(),
            alignment: BarChartAlignment.center,
            groupsSpace: spaceBetweenBars,
          ),
        ),
      ),
    );
  }
}

Widget getBottomTitles(double value, TitleMeta meta, int startMonth) {
  //print("Value is: $value");
  const textStyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  // List of month abbreviations
  const List<String> monthAbbreviations = [
    'J',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D'
  ];

  // Calculate the correct month based on the startMonth and current index
  int adjustedMonth = (startMonth + value.toInt() - 1) % 12;

  String text = monthAbbreviations[adjustedMonth];

  return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: textStyle,
      ));
}
