import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Counter {
  int? id;
  final String name;
  final Duration resetTimePeriod;
  final DateTime createdAt;
  DateTime nextResetDate;

  Counter(this.resetTimePeriod, this.name, this.createdAt, this.nextResetDate,
      {this.id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'reset_time_period': resetTimePeriod.inMilliseconds,
      'created_at': createdAt.toIso8601String(),
      'next_reset_date': nextResetDate.toIso8601String(),
    };
  }

  static Counter fromMap(Map<String, dynamic> map) {
    return Counter(
      Duration(milliseconds: map['reset_time_period']),
      map['name'],
      DateTime.parse(map['created_at']),
      DateTime.parse(map['next_reset_date']),
      id: map['id'],
    );
  }
}

class Task {
  int? id; // Unique identifier for SQL
  final String name;
  final int minimum;
  final int goal;
  int count = 0;
  final int counterId; // Reference to the Counter

  Task(
    this.name,
    this.minimum,
    this.goal,
    this.counterId,
    this.count, {
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'minimum': minimum,
      'goal': goal,
      'count': count,
      'counter_id': counterId,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      map['name'],
      map['minimum'],
      map['goal'],
      map['counter_id'],
      id: map['id'],
      map['count'],
    );
  }
}

class CounterHistory {
  final int counterId;
  final DateTime resetTime;
  final List<TaskHistory> tasksHistory;

  CounterHistory(this.counterId, this.resetTime, this.tasksHistory);

  Map<String, dynamic> toMap() {
    return {
      'counter_id': counterId,
      'reset_time': resetTime.toIso8601String(),
      'tasks_history':
          jsonEncode(tasksHistory.map((task) => task.toMap()).toList()),
    };
  }

  static CounterHistory fromMap(Map<String, dynamic> map) {
    return CounterHistory(
      map['counter_id'],
      DateTime.parse(map['reset_time']),
      (jsonDecode(map['tasks_history']) as List)
          .map((taskMap) => TaskHistory.fromMap(taskMap))
          .toList(),
    );
  }
}

class TaskHistory {
  final int taskId;
  final int minimum;
  final int goal;
  final int count;

  TaskHistory(this.taskId, this.minimum, this.goal, this.count);

  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'minimum': minimum,
      'goal': goal,
      'count': count,
    };
  }

  static TaskHistory fromMap(Map<String, dynamic> map) {
    return TaskHistory(
      map['task_id'],
      map['minimum'],
      map['goal'],
      map['count'],
    );
  }
}

class CounterDataModel {
  Database? database;

  Future<void> initDB() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'mycounters.db'),
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE counters(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, reset_time_period INTEGER, created_at TEXT, next_reset_date TEXT)");
        db.execute(
            "CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, minimum INTEGER, goal INTEGER, count INTEGER, counter_id INTEGER, FOREIGN KEY (counter_id) REFERENCES counters (id))");
        db.execute(
          "CREATE TABLE counter_history(id INTEGER PRIMARY KEY AUTOINCREMENT, counter_id INTEGER, reset_time TEXT, tasks_history TEXT, FOREIGN KEY (counter_id) REFERENCES counters (id))",
        );
      },
      version: 1,
    );
  }

  Future<void> addCounter(Counter counter) async {
    await initDB();
    if (database != null) {
      await database!.insert('counters', counter.toMap());
    } else {
      print("Database is not initialized.");
      // Handle the error appropriately
    }
  }

  Future<void> updateCounter(Counter counter) async {
    await database!.update(
      'counters',
      counter.toMap(),
      where: "id = ?",
      whereArgs: [counter.id],
    );
  }

  Future<void> deleteCounter(int id) async {
    await initDB();
    await database!.delete(
      'counters',
      where: "id = ?",
      whereArgs: [id],
    );
    // Also delete associated tasks
    await database!.delete(
      'tasks',
      where: "counter_id = ?",
      whereArgs: [id],
    );
  }

  Future<List<Counter>> getCounters() async {
    await initDB();
    final List<Map<String, dynamic>> counterMaps =
        await database!.query('counters');
    return List.generate(counterMaps.length, (i) {
      return Counter.fromMap(counterMaps[i]);
    });
  }

  Future<void> addTask(Task task) async {
    await initDB();
    await database!.insert('tasks', task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await initDB();
    await database!.update(
      'tasks',
      task.toMap(),
      where: "id = ?",
      whereArgs: [task.id],
    );
  }

  Future<void> incrementCount(int id) async {
    await initDB();
    await database!
        .execute("UPDATE tasks SET count = count + 1 WHERE id = $id ");
  }

  Future<void> deleteTask(int id) async {
    await initDB();
    await database!.delete(
      'tasks',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<Task>> getTasksForCounter(int counterId) async {
    await initDB();
    final List<Map<String, dynamic>> taskMaps = await database!.query(
      'tasks',
      where: 'counter_id = ?',
      whereArgs: [counterId],
    );
    List.generate(taskMaps.length, (i) {
      print(Task.fromMap(taskMaps[i]).count);
    });
    return List.generate(
      taskMaps.length,
      (i) {
        return Task.fromMap(taskMaps[i]);
      },
    );
  }

  Future<void> updateNextResetTime(
      int counterId, DateTime nextResetDate) async {
    await initDB();
    await database!.update(
      'counters',
      {'next_reset_date': nextResetDate.toIso8601String()},
      where: "id = ?",
      whereArgs: [counterId],
    );
  }

  Future<List<CounterHistory>> getCounterHistory(int counterId) async {
    await initDB();
    final List<Map<String, dynamic>> historyMaps = await database!.query(
      'counter_history',
      where: 'counter_id = ?',
      whereArgs: [counterId],
    );
    return List.generate(
      historyMaps.length,
      (i) {
        return CounterHistory.fromMap(historyMaps[i]);
      },
    );
  }

  Future<void> addCounterHistory(CounterHistory history) async {
    await initDB();
    if (database != null) {
      await database!.insert('counter_history', history.toMap());
    } else {
      print("Database is not initialized.");
      // Handle the error appropriately
    }
  }
}
