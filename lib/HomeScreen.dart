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
int _todayUsage = 0;
String  _usageString="";
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
          currentMonthStart.subtract(const Duration(days: 30));
      DateTime twoMonthsAgoStart =
          previousMonthStart.subtract(const Duration(days: 30));
      DateTime threeMonthsAgoStart =
          twoMonthsAgoStart.subtract(const Duration(days: 30));

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
  Future<UsageData> _getUsageDataForWeek() async {
  int totalUsage = 0;
  DateTime now = DateTime.now();
  DateTime weekStart = now.subtract(const Duration(days: 7));
  List<AppUsageInfo> infoList =
      await AppUsage().getAppUsage(weekStart, now);

  for (var info in infoList) {
    if (info.packageName == "com.example.testappno") {
      totalUsage += info.usage.inMinutes;
    }
  }
  int totalUsageInHours = totalUsage ~/ 60; // Convert minutes to hours
  print("Last week: $totalUsageInHours hours");
  return UsageData(month: "Last week", usage: totalUsageInHours);
}


Future<UsageData> _getUsageDataForMonth(DateTime monthStart) async {
  int totalUsage = 0;
  DateTime monthEnd = monthStart.add(const Duration(days: 30));
  List<AppUsageInfo> infoList =
      await AppUsage().getAppUsage(monthStart, monthEnd);

  for (var info in infoList) {
    if (info.packageName == "com.example.testappno") {
      totalUsage += info.usage.inMinutes;
    }
  }
  int totalUsageInHours = totalUsage ~/ 60; // Convert minutes to hours
  print("${DateFormat('MMMM').format(monthStart)}: $totalUsageInHours hours");
  return UsageData(month: DateFormat('MMM').format(monthStart), usage: totalUsageInHours);
}
Future<String> _getUsageDataForDay() async {
  int totalUsage = 0;
  DateTime now = DateTime.now();
  DateTime dayStart = DateTime(now.year, now.month, now.day);
  List<AppUsageInfo> infoList =
      await AppUsage().getAppUsage(dayStart, now);

  for (var info in infoList) {
    if (info.packageName == "com.example.testappno") {
      totalUsage += info.usage.inMinutes;
      print (totalUsage);
    }
  }
  String usageString;
  if (totalUsage >= 60) {
    int totalUsageInHours = totalUsage ~/ 60; // Convert minutes to hours
    usageString = "Today: $totalUsageInHours hours";
  } else {
    usageString = "Today: $totalUsage minutes";
  }
  print(usageString);
  return usageString;
}



@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: const Text('App Usage Example'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children:[
          _usageDataList.isNotEmpty
              ? Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "App usage for the last 4 months",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
            FutureBuilder<String>(
  future: _getUsageDataForDay(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Text('Loading...'); // Show a loading indicator while the future is resolving
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return Text(snapshot.data ?? ''); // Show the data returned by the future, or an empty string if it's null
    }
  },
            ),
                      Container(
                        width: 200,
                        height: 200,
                      
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          series: <ChartSeries<UsageData, String>>[
                            ColumnSeries<UsageData, String>(
                                dataSource: _usageDataList,
                                xValueMapper: (UsageData usage, _) => usage.month,
                                yValueMapper: (UsageData usage, _) => usage.usage,
                                dataLabelSettings: const DataLabelSettings(isVisible: true))
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "App usage for the previous week",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<UsageData>(
                        future: _getUsageDataForWeek(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (!snapshot.hasData) {
                            return const Text("No data available");
                          } else {
                            return Text(
                              "Total usage for the previous week: ${snapshot.data!.usage} hours",
                              style: const TextStyle(fontSize: 16),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: Text("Press the button to get usage stats"),
                ),
          Expanded(
            child: ListView.builder(
              itemCount: _usageDataList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_usageDataList[index].month),
                  trailing: Text("${_usageDataList[index].usage} hours"),
                );
              },
            ),
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: getUsageStats, child: const Icon(Icons.file_download)),
    ),
  );

}

}
class UsageData {
  final String month;
  final int usage;

  UsageData({required this.month, required this.usage});
}
