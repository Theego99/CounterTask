import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:counter/counters/data_model.dart';

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
    // Assuming getCounters() returns a list of all counters
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
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
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
          Expanded(
            child: ListView.builder(
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                      'Reset Time: ${historyData[index].resetTime}',
                      style: GoogleFonts.lato(fontSize: 18),
                    ),
                    subtitle: Text(
                      'Tasks: ${historyData[index].tasksHistory.length}',
                      style: GoogleFonts.lato(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

