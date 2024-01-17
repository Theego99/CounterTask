import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:counter/counters/data_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  List<Counter> counters = [];

  @override
  void initState() {
    super.initState();
    dataModel.initDB();
    _loadCounterIds();
    _loadCounters();
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

  Future<void> _loadCounters() async {
    List<Counter> loadedCounters = await dataModel.getCounters();
    setState(() {
      // Assuming you have a state variable that holds the list of counters
      counters = loadedCounters;
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
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 77, 31, 201),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blueGrey[300]!, width: 2),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedCounterId,
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: Colors.deepPurple),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCounterId = newValue;
                        _loadHistoryData();
                      });
                    },
                    items: counterIds.map<DropdownMenuItem<int>>((int value) {
                      var matchingCounter =
                          counters.firstWhere((counter) => counter.id == value);
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          matchingCounter.name,
                          style: TextStyle(color: Colors.deepPurple[800]),
                        ),
                      );
                    }).toList(),
                    dropdownColor: Colors.white,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
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
            if (historyData.isEmpty)
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  AppLocalizations.of(context)!.noDataAvailable,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
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

    // Task-Specific Stats Cards
    List<Widget> taskSpecificCards() {
      // Gather unique task IDs for the selected counter
      Set<int> uniqueTaskIds = historyData
          .where((history) => history.counterId == selectedCounterId)
          .expand((history) => history.tasksHistory.map((task) => task.taskId))
          .toSet();

      // Use FutureBuilder to fetch and display names for all unique tasks
      return [
        FutureBuilder<List<Task>>(
          future: dataModel.getTasksForCounter(selectedCounterId as int),
          builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                // Filter tasks to include only those with unique IDs
                var tasksToDisplay = snapshot.data!
                    .where((task) => uniqueTaskIds.contains(task.id))
                    .toList();

                return Card(
                  color: cardBackgroundColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tasksToDisplay.map((task) {
                        Map<String, double> dataMap = {
                          AppLocalizations.of(context)!.notReachedMinimum:
                              calculateNotReachedMinimum(historyData, task.id),
                          AppLocalizations.of(context)!.reachedMinimum:
                              calculateReachedMinimum(historyData, task.id),
                          AppLocalizations.of(context)!.reachedGoal:
                              calculateReachedGoal(historyData, task.id),
                        };

                        double averageCount =
                            calculateAverageCount(historyData, task.id);

                        return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(" ${task.name}", style: headerTextStyle),
                                SizedBox(height: 8),
                                PieChartWithData(context, dataMap),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.timeline,
                                        color: Colors.deepPurple[900]),
                                    SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)!.allTimeAverage + "" + averageCount.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ));
                      }).toList(),
                    ),
                  ),
                );
              } else {
                return Card(
                  child:
                      Text(AppLocalizations.of(context)!.error + snapshot.error.toString(), style: headerTextStyle),
                );
              }
            }
            return Card(
              child: Text(AppLocalizations.of(context)!.loading, style: headerTextStyle),
            );
          },
        ),
      ];
    }

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
              Text(AppLocalizations.of(context)!.performance, style: headerTextStyle),
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
                    AppLocalizations.of(context)!.minimumReached + percentageReachingMinimum.toStringAsFixed(2) + "%",
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
                     AppLocalizations.of(context)!.reachedGoal + percentageReachingGoal.toStringAsFixed(2) + "%",
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
              Text(AppLocalizations.of(context)!.keyInsights, style: headerTextStyle),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.star_border, color: Colors.deepPurple[900]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.topTask + ":" + taskWithHighestGoalPercentage.toString(),
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
                      AppLocalizations.of(context)!.lowestPerformance + {DateFormat('yyyy-MM-dd – kk:mm').format(resetTimeLowestSum)}.toString(),
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
                      AppLocalizations.of(context)!.peakPerformance + {DateFormat('yyyy-MM-dd – kk:mm').format(resetTimeHighestSum)}.toString(),
                      style: statsTextStyle.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 24.0, left: 10),
        child: Container(
          width: 250.0, // Set a specific width
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLegendItem(AppLocalizations.of(context)!.notReachedMinimum, Colors.orange),
                SizedBox(height: 8),
                _buildLegendItem(AppLocalizations.of(context)!.reachedMinimum, Colors.yellow),
                SizedBox(height: 8),
                _buildLegendItem(AppLocalizations.of(context)!.reachedGoal, Colors.green),
              ],
            ),
          ),
        ),
      ),
      ...taskSpecificCards(),
    ];
  }
}

double calculateAverageCount(List<CounterHistory> historyData, int? taskid) {
  int totalOccurrences = 0;
  int sum = 0;

  for (var history in historyData) {
    for (var task in history.tasksHistory) {
      if (task.taskId == taskid) {
        totalOccurrences++;
        sum += task.count;
      }
    }
  }

  if (totalOccurrences == 0) return 0;

  double average = sum / totalOccurrences;
  return double.parse(average.toStringAsFixed(1));
}

double calculateNotReachedMinimum(
    List<CounterHistory> historyData, int? taskid) {
  int totalOccurrences = 0;
  int occurrencesNotReachedMinimum = 0;

  for (var history in historyData) {
    for (var task in history.tasksHistory) {
      if (task.taskId == taskid) {
        totalOccurrences++;
        if (task.count < task.minimum) {
          occurrencesNotReachedMinimum++;
        }
      }
    }
  }

  return (totalOccurrences == 0)
      ? 0
      : (occurrencesNotReachedMinimum / totalOccurrences) * 100;
}

double calculateReachedMinimum(List<CounterHistory> historyData, int? taskid) {
  int totalOccurrences = 0;
  int occurrencesReachedMinimum = 0;

  for (var history in historyData) {
    for (var task in history.tasksHistory) {
      if (task.taskId == taskid) {
        totalOccurrences++;
        if (task.count >= task.minimum) {
          occurrencesReachedMinimum++;
        }
      }
    }
  }

  return (totalOccurrences == 0)
      ? 0
      : (occurrencesReachedMinimum / totalOccurrences) * 100;
}

double calculateReachedGoal(List<CounterHistory> historyData, int? taskid) {
  int totalOccurrences = 0;
  int occurrencesReachedGoal = 0;

  for (var history in historyData) {
    for (var task in history.tasksHistory) {
      if (task.taskId == taskid) {
        totalOccurrences++;
        if (task.count >= task.goal) {
          occurrencesReachedGoal++;
        }
      }
    }
  }

  return (totalOccurrences == 0)
      ? 0
      : (occurrencesReachedGoal / totalOccurrences) * 100;
}

Container PieChartWithData(BuildContext context ,Map<String, double> dataMap) {
  List<PieChartSectionData> sections = dataMap.entries.map((entry) {
    return PieChartSectionData(
      color: entry.key == AppLocalizations.of(context)!.notReachedMinimum
          ? Colors.orange
          : entry.key == AppLocalizations.of(context)!.reachedMinimum
              ? Colors.yellow
              : Colors.green,
      value: entry.value,
      title: '',
      radius: 50.0,
    );
  }).toList();

  return Container(
    height: 200.0, // Fixed height for the pie chart
    child: PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
      ),
    ),
  );
}

Widget _buildLegendItem(String label, Color color) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 16.0,
        height: 16.0,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      SizedBox(width: 8.0),
      Text(label),
    ],
  );
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



