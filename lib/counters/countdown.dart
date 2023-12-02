import 'package:counter/counters/data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

class CountDown extends StatefulWidget {
  final Counter counter;
  final CounterDataModel dataModel;
  final VoidCallback onReset;

  const CountDown({
    Key? key,
    required this.counter,
    required this.dataModel,
    required this.onReset,
  }) : super(key: key);

  @override
  _CountDownState createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
  late DateTime endTime;
  Key _timerKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _calculateEndTime();
  }

  void _calculateEndTime() {
    endTime = widget.counter.nextResetDate;
  }

  void _resetCountdown() async {
    DateTime newResetDate = DateTime.now().add(widget.counter.resetTimePeriod);
    await widget.dataModel
        .updateNextResetTime(widget.counter.id!, newResetDate);

    // Add historical data
    var currentTasks =
        await widget.dataModel.getTasksForCounter(widget.counter.id!);
    List<TaskHistory> tasksHistory = currentTasks.map((task) {
      return TaskHistory(
        task.id!,
        task.minimum,
        task.goal,
        task.count,
      );
    }).toList();
    CounterHistory history = CounterHistory(
      widget.counter.id!,
      DateTime.now(),
      tasksHistory,
    );

    // Store the history record in the database
    await widget.dataModel.addCounterHistory(history);

    setState(() {
      endTime = newResetDate;
      widget.counter.nextResetDate = newResetDate;
      widget.onReset();
      _timerKey = UniqueKey(); // Update key to force rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _timerKey,
      child: TimerCountdown(
        format: CountDownTimerFormat.daysHoursMinutesSeconds,
        daysDescription: '',
        hoursDescription: '',
        minutesDescription: '',
        secondsDescription: '',
        spacerWidth: 3,
        timeTextStyle: const TextStyle(color: Colors.white, fontSize: 15),
        colonsTextStyle: const TextStyle(color: Colors.white, fontSize: 15),
        endTime: endTime,
        onEnd: _resetCountdown,
      ),
    );
  }
}




//     void resetCountdown() {
//       while (endTime.isBefore(DateTime.now())) {
//         endTime = endTime.add(resetTimePeriod);
//       }
//     }