import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<UsageData> _usageDataList = [];

  @override
  void initState() {
    super.initState();
    getUsageStats();
  }

  void getUsageStats() async {
    try {
      // Get app usage stats for the current month and the previous three months
      DateTime now = DateTime.now();
      DateTime currentMonthStart = DateTime(now.year, now.month);
      DateTime previousMonthStart =
          currentMonthStart.subtract(Duration(days: 30));
      DateTime twoMonthsAgoStart =
          previousMonthStart.subtract(Duration(days: 30));
      DateTime threeMonthsAgoStart =
          twoMonthsAgoStart.subtract(Duration(days: 30));

      // Get app usage for each month and store it in a list
      _usageDataList.clear();
      _usageDataList.add(await _getUsageDataForMonth(currentMonthStart));
      _usageDataList.add(await _getUsageDataForMonth(previousMonthStart));
      _usageDataList.add(await _getUsageDataForMonth(twoMonthsAgoStart));
      _usageDataList.add(await _getUsageDataForMonth(threeMonthsAgoStart));

      setState(() {});
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }

  Future<UsageData> _getUsageDataForMonth(DateTime monthStart) async {
    int totalUsage = 0;
    DateTime monthEnd = monthStart.add(Duration(days: 30));
    List<AppUsageInfo> infoList =
        await AppUsage().getAppUsage(monthStart, monthEnd);

    for (var info in infoList) {
      if (info.packageName == "com.facebook.katana") {
        totalUsage += info.usage.inMinutes;
      }
    }
    print("${DateFormat('MMMM').format(monthStart)}: $totalUsage minutes");
    return UsageData(
        month: DateFormat('MMM').format(monthStart), usage: totalUsage);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App Usage Example'),
          backgroundColor: Colors.green,
        ),
        body: _usageDataList.isNotEmpty
            ? SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <ChartSeries<UsageData, String>>[
                  ColumnSeries<UsageData, String>(
                      dataSource: _usageDataList,
                      xValueMapper: (UsageData usage, _) => usage.month,
                      yValueMapper: (UsageData usage, _) => usage.usage,
                      dataLabelSettings: DataLabelSettings(isVisible: true))
                ],
              )
            : Center(
                child: Text("Press the button to get usage stats"),
              ),
        floatingActionButton: FloatingActionButton(
            onPressed: getUsageStats, child: Icon(Icons.file_download)),
      ),
    );
  }
}

class UsageData {
  final String month;
  final int usage;

  UsageData({required this.month, required this.usage});
}
