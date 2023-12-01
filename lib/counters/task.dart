import 'package:flutter/material.dart';
import 'package:counter/counters/data_model.dart';

class TaskWidget extends StatefulWidget {
  final Task task;
  final CounterDataModel dataModel;
  final VoidCallback onTaskDeleted; // Deletion callback
  final Function? onIncrement; // Retain the onIncrement callback

  const TaskWidget(this.task, this.dataModel,
      {Key? key, this.onIncrement, required this.onTaskDeleted})
      : super(key: key);

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double maxSwipeDistance = 55.0; // Maximum swipe distance
  // late double maxSwipeDistance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween(begin: 0.0, end: -maxSwipeDistance).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    double delta = details.primaryDelta ?? 0.0;
    if (_controller.value - delta / maxSwipeDistance >= 0.0 &&
        _controller.value - delta / maxSwipeDistance <= 1.0) {
      _controller.value -= delta / maxSwipeDistance;
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_controller.value > 0.5) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getTaskColor() {
    if (widget.task.count >= widget.task.goal) {
      return Colors.green;
    } else if (widget.task.count >= widget.task.minimum) {
      return Colors.yellow;
    } else {
      return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  0,
                  0,
                  MediaQuery.of(context).size.width * 0.2,
                  0), // Adjusted to leave space for the 150 width
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Builder(
                    builder: (context) {
                      double containerWidth = 115;
                      double individualWidth = containerWidth / 2;

                      return Row(
                        children: [
                          Container(
                            width: individualWidth, // Adjusted width
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(
                                  15), // Set circular radius
                            ),
                            child: IconButton(
                              icon: Icon(Icons.delete),
                              color: Colors.white,
                              onPressed: () {
                                // delete task
                                _deleteTask(context);
                              },
                              tooltip: "Delete Task",
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(_animation.value, 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                color: _getTaskColor(), // Color changes based on task count
              ),
              margin: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.02,
                  1,
                  MediaQuery.of(context).size.width * 0.2,
                  0),
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.task.name,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Row(
                    children: [
                      Text('${widget.task.count}',
                          style: const TextStyle(fontSize: 20)),
                      IconButton(
                        icon: const Icon(Icons.add, size: 25),
                        onPressed: () async {
                          setState(
                            () {
                              widget.task.count++;
                              widget.onIncrement;
                            },
                          );
                          // Update the task count in the database
                          CounterDataModel().incrementCount(widget.task.id!);
                        },
                        tooltip: "Count up!",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteTask(BuildContext context) async {
    await widget.dataModel.deleteTask(widget.task.id!);

    // Trigger the callback
    widget.onTaskDeleted();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${widget.task.name} deleted"),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
