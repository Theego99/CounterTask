import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:counter/counters/data_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class StatScreen extends StatefulWidget {
  const StatScreen({Key? key}) : super(key: key);

  @override
  _StatScreenState createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> {
  int? selectedCounterId;
  List<CounterHistory> historyData = [];
  CounterDataModel dataModel = CounterDataModel();
  List<int> counterIds = []; // List of counter IDs for the dropdown

  @override
  void initState() {
    super.initState();
    _loadCounterIds();
  }

  Future<void> _loadCounterIds() async {
    var counters = await dataModel.getCounters();
    setState(() {
      counterIds = counters.map((counter) => counter.id!).toList();
      if (counterIds.isNotEmpty) {
        selectedCounterId = counterIds.first;
        _loadHistoryData();
      }
    });
  }

  Future<void> _loadHistoryData() async {
    if (selectedCounterId != null) {
      var data = await dataModel.getCounterHistory(selectedCounterId!);
      setState(() {
        historyData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract task data from historyData
    List<TaskHistory> taskHistories = _extractTaskHistories();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 77, 31, 201),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: DropdownButton<int>(
                value: selectedCounterId,
                onChanged: (newValue) {
                  setState(() {
                    selectedCounterId = newValue;
                    _loadHistoryData();
                  });
                },
                items: counterIds.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('Counter $value'),
                  );
                }).toList(),
              ),
            ),
            // Insights
            if (historyData.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: buildInsights(historyData),
                ),
              ),
            //chart
            if (taskHistories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildLineChart(taskHistories),
              ),
          ],
        ),
      ),
    );
  }

  List<TaskHistory> _extractTaskHistories() {
    Map<int, List<double>> taskData = {};
    for (var history in historyData) {
      for (var task in history.tasksHistory) {
        taskData.putIfAbsent(task.taskId, () => []).add(task.count.toDouble());
      }
    }
    return taskData.entries.map((e) => TaskHistory(e.key, e.value)).toList();
  }

// Create a Line Chart with dynamic width and horizontal scrolling
  Widget buildLineChart(List<TaskHistory> taskHistories) {
    List<LineChartBarData> lines = [];
    Map<int, List<FlSpot>> taskSpots = {};

    int maxDataPoints = 0;
    Color getRandomColor() {
      return Colors.primaries[Random().nextInt(Colors.primaries.length)];
    }

    // Grouping task counts by their task ID
    for (var taskHistory in taskHistories) {
      List<FlSpot> spots = [];
      for (int i = 0; i < taskHistory.counts.length; i++) {
        spots.add(FlSpot(i.toDouble(), taskHistory.counts[i]));
      }
      maxDataPoints = max(maxDataPoints, spots.length);
      taskSpots[taskHistory.taskId] = spots;
    }

    // Creating a line for each task
    taskSpots.forEach((taskId, spots) {
      lines.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        colors: [getRandomColor()],
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ));
    });

    // Calculate the chart width
    // Calculate chart width
    double minWidthPerPoint = 50; // Minimum width per data point
    double chartWidth = max(
        MediaQuery.of(context).size.width, minWidthPerPoint * maxDataPoints);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: 200,
        width: chartWidth,
        child: LineChart(
          LineChartData(
            lineBarsData: lines,
            gridData: FlGridData(show: true), // Enable Grid
            titlesData: FlTitlesData(
              bottomTitles: SideTitles(
                showTitles: true,
                getTextStyles: (context, value) =>
                    const TextStyle(color: Colors.white, fontSize: 12),
                getTitles: (value) {
                  // Logic to return task names based on index
                  int index = value.toInt();
                  if (index < historyData.length) {
                    return index.toString();
                  }
                  return '';
                },
              ),
              leftTitles: SideTitles(
                showTitles: true,
                getTextStyles: (context, value) =>
                    const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildInsights(List<CounterHistory> historyData) {
    double percentageReachingMinimum =
        calculatePercentageReachingMinimum(historyData);
    double percentageReachingGoal =
        calculatePercentageReachingGoal(historyData);
    String taskWithHighestGoalPercentage =
        findTaskWithHighestGoalPercentage(historyData);
    DateTime resetTimeLowestSum = findResetTimeWithLowestSum(historyData);
    DateTime resetTimeHighestSum = findResetTimeWithHighestSum(historyData);

    TextStyle statsTextStyle = TextStyle(color: Colors.grey[800], fontSize: 14);
    TextStyle headerTextStyle = TextStyle(
        color: Colors.deepPurple[900],
        fontSize: 20,
        fontWeight: FontWeight.bold);
    Color cardBackgroundColor = Colors.white;
    Color progressIndicatorBackgroundColor = Colors.deepPurple[100]!;
    Color progressIndicatorValueColor = Colors.deepPurple[800]!;

    return [
      Card(
        color: cardBackgroundColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Performance Insights", style: headerTextStyle),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentageReachingMinimum / 100,
                  backgroundColor: progressIndicatorBackgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      progressIndicatorValueColor),
                  minHeight: 12,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                    "Minimum reached: ${percentageReachingMinimum.toStringAsFixed(2)}%",
                    style: statsTextStyle),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentageReachingGoal / 100,
                  backgroundColor: Colors.teal[100],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[800]!),
                  minHeight: 12,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                    "Goal reached: ${percentageReachingGoal.toStringAsFixed(2)}%",
                    style: statsTextStyle),
              ),
            ],
          ),
        ),
      ),
      Card(
        color: cardBackgroundColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Key Achievements", style: headerTextStyle),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.star_border, color: Colors.deepPurple[900]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Top Task: $taskWithHighestGoalPercentage",
                      style: statsTextStyle.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.trending_down, color: Colors.red[400]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Lowest Point: ${DateFormat('yyyy-MM-dd – kk:mm').format(resetTimeLowestSum)}",
                      style: statsTextStyle.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.green[400]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Peak Performance: ${DateFormat('yyyy-MM-dd – kk:mm').format(resetTimeHighestSum)}",
                      style: statsTextStyle.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }
}

double calculatePercentageReachingMinimum(List<CounterHistory> historyData) {
  int totalTasks = 0;
  int tasksReachedMinimum = 0;

  for (var history in historyData) {
    for (var task in history.tasksHistory) {
      totalTasks++;
      if (task.count >= task.minimum) {
        tasksReachedMinimum++;
      }
    }
  }

  return (totalTasks == 0) ? 0 : (tasksReachedMinimum / totalTasks) * 100;
}

double calculatePercentageReachingGoal(List<CounterHistory> historyData) {
  int totalTasks = 0;
  int tasksReachedGoal = 0;

  for (var history in historyData) {
    for (var task in history.tasksHistory) {
      totalTasks++;
      if (task.count >= task.goal) {
        tasksReachedGoal++;
      }
    }
  }

  return (totalTasks == 0) ? 0 : (tasksReachedGoal / totalTasks) * 100;
}

String findTaskWithHighestGoalPercentage(List<CounterHistory> historyData) {
  Map<int, int> goalCounts = {};
  Map<int, int> taskTotals = {};

  for (var history in historyData) {
    for (var task in history.tasksHistory) {
      taskTotals[task.taskId] = (taskTotals[task.taskId] ?? 0) + 1;
      if (task.count >= task.goal) {
        goalCounts[task.taskId] = (goalCounts[task.taskId] ?? 0) + 1;
      }
    }
  }

  int? taskIdWithHighestGoalPercentage;
  double highestPercentage = 0.0;

  for (var taskId in taskTotals.keys) {
    double percentage = (goalCounts[taskId] ?? 0) / taskTotals[taskId]! * 100;
    if (percentage > highestPercentage) {
      highestPercentage = percentage;
      taskIdWithHighestGoalPercentage = taskId;
    }
  }

  return taskIdWithHighestGoalPercentage == null
      ? "None"
      : "Task $taskIdWithHighestGoalPercentage";
}

DateTime findResetTimeWithLowestSum(List<CounterHistory> historyData) {
  return historyData.reduce((a, b) {
    int sumA = a.tasksHistory.fold(0, (sum, task) => sum + task.count);
    int sumB = b.tasksHistory.fold(0, (sum, task) => sum + task.count);
    return sumA < sumB ? a : b;
  }).resetTime;
}

DateTime findResetTimeWithHighestSum(List<CounterHistory> historyData) {
  return historyData.reduce((a, b) {
    int sumA = a.tasksHistory.fold(0, (sum, task) => sum + task.count);
    int sumB = b.tasksHistory.fold(0, (sum, task) => sum + task.count);
    return sumA > sumB ? a : b;
  }).resetTime;
}

// TaskHistory model
class TaskHistory {
  final int taskId;
  final List<double> counts; // Historical count data for this task

  TaskHistory(this.taskId, this.counts);

  static TaskHistory fromMap(Map<String, dynamic> map) {
    // Assuming map['tasks_history'] is a list of task data
    // Here you need to extract the counts for each task from the map
    List<double> counts = [];
    for (var taskMap in map['tasks_history']) {
      counts.add(taskMap['count'].toDouble());
    }
    return TaskHistory(
      map['task_id'],
      counts,
    );
  }
}
