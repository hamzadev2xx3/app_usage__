import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, int> _usageMap = {};

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

      // Get app usage for each month and store it in a map
      _usageMap.clear();
      _usageMap['Current Month'] =
          await _getTotalUsageForMonth(currentMonthStart);
      _usageMap['Previous Month'] =
          await _getTotalUsageForMonth(previousMonthStart);
      _usageMap['Two Months Ago'] =
          await _getTotalUsageForMonth(twoMonthsAgoStart);
      _usageMap['Three Months Ago'] =
          await _getTotalUsageForMonth(threeMonthsAgoStart);

      setState(() {});
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }

  Future<int> _getTotalUsageForMonth(DateTime monthStart) async {
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
    return totalUsage;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitHours = twoDigits(duration.inHours);
    return "$twoDigitHours Hour $twoDigitMinutes minute";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App Usage Example'),
          backgroundColor: Colors.green,
        ),
        body: _usageMap.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _usageMap.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Total usage: ${formatDuration(Duration(minutes: entry.value))}",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  );
                }).toList(),
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
