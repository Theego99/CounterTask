import 'package:counter/counters/my_counters_screen.dart';
import 'package:counter/counters/proxy_decorator.dart';
import 'package:flutter/material.dart';
import 'package:counter/counters/data_model.dart';
import 'package:counter/counters/task.dart';
import 'package:counter/counters/countdown.dart';
import 'package:counter/counters/drop_down_menu.dart';

class CounterWidget extends StatefulWidget {
  final Counter counter;
  final CounterDataModel dataModel;
  final VoidCallback onDelete;
  final VoidCallback onCounterUpdate;

  CounterWidget(
      this.counter, this.dataModel, this.onDelete, this.onCounterUpdate)
      : super(key: ValueKey(counter.id)); // Use counter's ID as key

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget>
    with TickerProviderStateMixin {
  bool isExpanded = false;
  List<Task> tasks = []; // Add a tasks list to keep track of tasks
  late AnimationController _controller;
  late Animation<double> _animation;
  final double maxSwipeDistance = 150.0; // Maximum swipe distance

  Future<void> _loadTasks() async {
    var loadedTasks =
        await widget.dataModel.getTasksForCounter(widget.counter.id!);
    setState(
      () {
        tasks = loadedTasks;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      trackpadScrollCausesScale: false,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 72, // Adjusted width
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 23, 125, 208),
                    borderRadius:
                        BorderRadius.circular(15), // Set circular radius
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.white,
                    onPressed:
                        _showEditCounterDialog, // Updated to call the edit dialog
                    tooltip: "Edit Counter",
                  ),
                ),
                Container(
                  width: 72, // Adjusted width
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                        BorderRadius.circular(15), // Set circular radius
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.white,
                    onPressed: () {
                      // delete task
                      _deleteCounter(context);
                    },
                    tooltip: "Delete Counter",
                  ),
                ),
                SizedBox(
                  height: 80,
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(_animation.value, 0),
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue,
                          Color.fromRGBO(24, 117, 194, 1),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            widget.counter.name,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          trailing: Wrap(
                            spacing: 12, // space between two icons
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  size: 40,
                                ),
                                onPressed: () {
                                  _showAddTaskDialog(context);
                                },
                                tooltip: 'Create New Task',
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 45,
                            ),
                            CountDown(
                              counter: widget.counter,
                              dataModel: widget.dataModel,
                              onReset: _resetTasks,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isExpanded)
                    ReorderableListView(
                      proxyDecorator: customProxyDecorator,
                      buildDefaultDragHandles: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        for (final task in tasks)
                          ReorderableDragStartListener(
                            index: tasks.indexOf(task),
                            key: Key(task.name +
                                task.id.toString()), // Use a unique key
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(255, 77, 31, 201),
                                  width: 2,
                                ),
                              ),
                              child: TaskWidget(
                                task,
                                widget.dataModel,
                                onIncrement: () {
                                  setState(() {
                                    // Increment the task count
                                    widget.dataModel.updateTask(task);
                                  });
                                },
                                onTaskDeleted: () {
                                  setState(() {
                                    _loadTasks();
                                  });
                                },
                              ),
                            ),
                          ),
                      ],
                      onReorder: (int oldIndex, int newIndex) {
                        setState(
                          () {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final Task item = tasks.removeAt(oldIndex);
                            tasks.insert(newIndex, item);
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetTasks() {
    for (var task in tasks) {
      task.count = 0; // Reset count to zero
      widget.dataModel.updateTask(task); // Save the reset count to the database
    }
    _updateCounter(widget.counter.name, widget.counter.resetTimePeriod);
    _loadTasks(); // Reload tasks to update the UI
    setState(() {
      widget.onCounterUpdate();
    });
  }

  void _deleteCounter(BuildContext context) async {
    // Show a confirmation dialog
    bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Are you sure you want to delete counter?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(false), // User presses Cancel
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(true), // User presses Yes
                  child: Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false; // If the dialog is dismissed, it returns null. Convert it to false.

    // If confirm is true, proceed with deletion
    if (confirm) {
      await widget.dataModel.deleteCounter(widget.counter.id!);
      widget.onDelete(); // This will call removeCounter from MyCounters
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${widget.counter.name} deleted"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showEditCounterDialog() {
    String updatedName = widget.counter.name;
    // Decompose the Duration into days, hours, minutes, and seconds
    int initialDays = widget.counter.resetTimePeriod.inDays;
    int initialHours = widget.counter.resetTimePeriod.inHours % 24;
    int initialMinutes = widget.counter.resetTimePeriod.inMinutes % 60;
    int initialSeconds = widget.counter.resetTimePeriod.inSeconds % 60;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // These need to be stateful values inside the dialog
        int selectedDays = initialDays;
        int selectedHours = initialHours;
        int selectedMinutes = initialMinutes;
        int selectedSeconds = initialSeconds;

        return StatefulBuilder(
          // Use StatefulBuilder to manage state inside the dialog
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Counter'),
              content: SingleChildScrollView(
                // Use SingleChildScrollView for better handling of small screens
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Counter Name'),
                      controller:
                          TextEditingController(text: widget.counter.name),
                      onChanged: (value) {
                        updatedName = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownMenuWidget(
                      label: 'Days',
                      initialValue: selectedDays,
                      onSelected: (value) {
                        setState(() {
                          selectedDays = value as int;
                        });
                      },
                      items:
                          List.generate(32, (index) => index, growable: false),
                    ),
                    const SizedBox(height: 20),
                    DropdownMenuWidget(
                      label: 'Hours',
                      initialValue: selectedHours,
                      onSelected: (value) {
                        setState(() {
                          selectedHours = value as int;
                        });
                      },
                      items:
                          List.generate(24, (index) => index, growable: false),
                    ),
                    const SizedBox(height: 20),
                    DropdownMenuWidget(
                      label: 'Minutes',
                      initialValue: selectedMinutes,
                      onSelected: (value) {
                        setState(() {
                          selectedMinutes = value as int;
                        });
                      },
                      items:
                          List.generate(60, (index) => index, growable: false),
                    ),
                    const SizedBox(height: 20),
                    DropdownMenuWidget(
                      label: 'Seconds',
                      initialValue: selectedSeconds,
                      onSelected: (value) {
                        setState(() {
                          selectedSeconds = value as int;
                        });
                      },
                      items:
                          List.generate(60, (index) => index, growable: false),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    // Reassemble the Duration from the selected values
                    Duration updatedResetTimePeriod = Duration(
                      days: selectedDays,
                      hours: selectedHours,
                      minutes: selectedMinutes,
                      seconds: selectedSeconds,
                    );
                    _updateCounter(updatedName, updatedResetTimePeriod);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateCounter(
      String updatedName, Duration updatedResetTimePeriod) async {
    Counter updatedCounter = Counter(
      updatedResetTimePeriod,
      updatedName,
      widget.counter.createdAt,
      widget.counter.nextResetDate,
      id: widget.counter.id,
    );

    await widget.dataModel.updateCounter(
        updatedCounter); // Corrected line to update counter in database
    widget.onCounterUpdate(); // This might be intended to trigger a UI refresh
    _loadTasks(); // Refreshing the tasks
    setState(() {});
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController taskNameController = TextEditingController();
    int? minimum;
    int? goal;

    String? minimumErrorText;
    String? goalErrorText;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: taskNameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
                onChanged: (value) {
                  // No need to set state here as the controller handles it
                },
                validator: (value) {
                  if (value != null && value.length > 10) {
                    return 'Name cannot exceed 10 characters';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Minimum',
                  errorText: minimumErrorText,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final parsedValue = int.tryParse(value);
                  if (parsedValue != null) {
                    minimum = parsedValue;
                    minimumErrorText = null;
                  } else {
                    minimumErrorText = 'Only numbers are accepted';
                  }
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Goal',
                  errorText: goalErrorText,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final parsedValue = int.tryParse(value);
                  if (parsedValue != null) {
                    goal = parsedValue;
                    goalErrorText = null;
                  } else {
                    goalErrorText = 'Only numbers are accepted';
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (taskNameController.text.isNotEmpty &&
                    minimum != null &&
                    goal != null &&
                    taskNameController.text.length <= 10) {
                  final newTask = Task(taskNameController.text, minimum ?? 0,
                      goal ?? 0, widget.counter.id!, 0);

                  widget.dataModel.addTask(newTask);
                  _loadTasks();
                  Navigator.of(context).pop();
                } else {
                  // Show an error message if conditions are not met
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please enter a valid task name (up to 10 characters) and numbers for Minimum and Goal.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
