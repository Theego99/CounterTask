import 'package:flutter/material.dart';
import 'package:counter/counters/counter.dart';
import 'package:counter/counters/data_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:counter/counters/drop_down_menu.dart';
import 'package:counter/counters/proxy_decorator.dart';

class MyCounters extends StatefulWidget {
  final CounterDataModel dataModel;

  const MyCounters({
    Key? key,
    required this.dataModel,
  }) : super(key: key);

  @override
  State<MyCounters> createState() => _MyCountersState();
}

class _MyCountersState extends State<MyCounters> {
  String newCounterName = '';
  int selectedDays = 0; // Initialize with 0
  int selectedHours = 0; // Initialize with 0
  int selectedMinutes = 0; // Initialize with 0
  int selectedSeconds = 0; // Initialize with 0
  List<Counter> counters = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    CounterDataModel().initDB();
    _loadCounters();
  }

  void refreshCounters() async {
    List<Counter> updatedCounters = await widget.dataModel.getCounters();

    setState(() {
      counters = updatedCounters;
    });
  }

  void removeCounter() async {
    List<Counter> updatedCounters = await widget.dataModel.getCounters();
    setState(() {
      counters = updatedCounters;
    });
  }

  void _loadCounters() async {
    List<Counter> loadedCounters = await CounterDataModel().getCounters();
    setState(() {
      // Assuming you have a state variable that holds the list of counters
      counters = loadedCounters;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (counters.isEmpty) {
      // Display the Column with image, text, and button
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                _showAddCounterDialog(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              icon: const Icon(
                Icons.add_box,
                size: 40,
              ),
              label: Text(
                'New counter',
                style: GoogleFonts.lato(fontSize: 30),
              ),
            ),
            const SizedBox(height: 30),
            Image.asset(
              'assets/images/Blacklogonobackground.png',
              width: 200,
              color: const Color.fromARGB(149, 255, 255, 255),
            ),
            const SizedBox(height: 100),
            Text(
              'Keep track of every task!',
              style: GoogleFonts.lato(
                color: const Color.fromARGB(255, 237, 223, 252),
                fontSize: 24,
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Scaffold(
  body: Container(
    color: Color.fromARGB(255, 77, 31, 201),
    child: Center( // Centering the content
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9, // 80% of screen width
        ),
        child: ListView.builder(
          itemCount: counters.length + 2, // Adding 2 for the button and extra space
          itemBuilder: (context, index) {
            if (index == 0) {
              // IconButton as the first item
              return Padding(
                padding: const EdgeInsets.all(30),
                child: IconButton(
                  onPressed: () {
                    _showAddCounterDialog(context);
                  },
                  icon: const Icon(Icons.add_box),
                  iconSize: 40,
                  color: Colors.white,
                  tooltip: 'Create New Counter',
                ),
              );
            } else if (index == counters.length + 1) {
              // SizedBox as the last item for extra space
              return SizedBox(height: MediaQuery.of(context).size.height * 0.1);
            }
            final counter = counters[index - 1];
            return CounterWidget(
              counter,
              widget.dataModel,
              removeCounter,
              refreshCounters,
            );
          },
        ),
      ),
    ),
  ),
)

      );
    }
  }

  void _showAddCounterDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Counter'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Counter Name'),
                    onChanged: (value) {
                      setState(() {
                        newCounterName = value;
                      });
                    },
                    validator: (value) {
                      if (value != null && value.length > 10) {
                        return 'Name cannot exceed 10 characters';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 30),
                  // Time Period UI
                  Text(
                    'Time Period:',
                    style: GoogleFonts.lato(fontSize: 20),
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
                    items: List.generate(32, (index) => index, growable: false),
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
                    items: List.generate(24, (index) => index, growable: false),
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
                    items: List.generate(60, (index) => index, growable: false),
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
                    items: List.generate(60, (index) => index, growable: false),
                  ),
                  // Add Button
                  TextButton(
                    child: const Text('Add'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Check if the combined time period is not 0
                        if (selectedDays +
                                selectedHours +
                                selectedMinutes +
                                selectedSeconds >
                            0) {
                          // Create and add a new counter with the specified time period
                          final newCounter = Counter(
                            Duration(
                              days: selectedDays,
                              hours: selectedHours,
                              minutes: selectedMinutes,
                              seconds: selectedSeconds,
                            ),
                            newCounterName,
                            DateTime.now(),
                            DateTime.now().add(
                              Duration(
                                days: selectedDays,
                                hours: selectedHours,
                                minutes: selectedMinutes,
                                seconds: selectedSeconds,
                              ),
                            ),
                          );

                          // widget.dataModel.addCounter(newCounter);
                          widget.dataModel.addCounter(newCounter);

                          // Close the dialog
                          Navigator.of(context).pop();

                          // Update the counters list and rebuild the widget
                          void updateCounters() async {
                            List<Counter> updatedCounters =
                                await widget.dataModel.getCounters();
                            setState(
                              () {
                                counters = updatedCounters;
                              },
                            );
                          }

                          updateCounters();
                        } else {
                          // Show an alert or a Snackbar if the time period is 0
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Reset time period must be greater than 0.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
