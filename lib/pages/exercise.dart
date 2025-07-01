import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final Function(bool?) onChanged;
  final String imageUrl;
  final int sets;

  const ExerciseTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.imageUrl,
    required this.sets,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        height: 120,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            // Content overlay
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: taskCompleted,
                    onChanged: onChanged,
                    activeColor: Colors.black,
                  ),
                  Expanded(
                    child: Text(
                      '$taskName for $sets sets',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        decoration:
                            taskCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});
  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  List<List<dynamic>> ExeList = [
    [
      'Do 10 Push-ups',
      false,
      'https://plus.unsplash.com/premium_photo-1667511316841-6a775f347479?q=80&w=1471&auto=format&fit=crop',
      1,
    ],
    [
      'Do 10 Sit-ups',
      false,
      'https://plus.unsplash.com/premium_photo-1664910890583-62f2a99ece69?q=80&w=1470&auto=format&fit=crop',
      1,
    ],
    [
      'Do 10 Bicep Dips',
      false,
      'https://media.istockphoto.com/id/1008346250/photo/disabled-young-man-working-on-arms-dips-exercise.jpg?s=612x612&w=0&k=20&c=YI8dmSwLqTMChYocL1xM75Ii0YkTOiaSr9qthfkbJOc=',
      1,
    ],
    [
      'Do 10 Russian Twist',
      false,
      'https://plus.unsplash.com/premium_photo-1663013224361-59a7076dc57d?q=80&w=1471&auto=format&fit=crop',
      1,
    ],
    [
      'Do 10 Knee Touches',
      false,
      'https://thumbs.dreamstime.com/b/african-american-guy-doing-elbow-to-knee-abdominal-crunches-laptop-indoor-abs-workout-african-american-guy-doing-elbow-to-knee-220076207.jpg',
      1,
    ],
    [
      'Do planking for 1 minute',
      false,
      'https://plus.unsplash.com/premium_photo-1672046218182-77e9a3e9f141?q=80&w=1470&auto=format&fit=crop',
      1,
    ],
  ];

  int globalSets = 1;

  @override
  void initState() {
    super.initState();
    checkAndResetTasksIfNewDay();
  }

  Future<void> checkAndResetTasksIfNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    await loadGlobalSets(prefs);
    final today = DateTime.now();
    final lastDateStr = prefs.getString('last_checked_date');
    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      if (today.year != lastDate.year ||
          today.month != lastDate.month ||
          today.day != lastDate.day) {
        resetAllTasks(prefs);
      } else {
        loadTaskStatus(prefs);
      }
    } else {
      resetAllTasks(prefs);
    }
  }

  void resetAllTasks(SharedPreferences prefs) {
    for (int i = 0; i < ExeList.length; i++) {
      ExeList[i][1] = false;
      prefs.setBool('task_$i', false);
    }
    prefs.setString('last_checked_date', DateTime.now().toIso8601String());
    setState(() {});
  }

  void loadTaskStatus(SharedPreferences prefs) {
    for (int i = 0; i < ExeList.length; i++) {
      bool? status = prefs.getBool('task_$i');
      if (status != null) {
        ExeList[i][1] = status;
      }
    }
    setState(() {});
  }

  Future<void> saveTaskStatus(int index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('task_$index', ExeList[index][1]);
  }

  Future<void> loadGlobalSets(SharedPreferences prefs) async {
    setState(() {
      globalSets = prefs.getInt('global_sets') ?? 4;
      for (int i = 0; i < ExeList.length; i++) {
        ExeList[i][3] = globalSets;
      }
    });
  }

  Future<void> saveGlobalSets(SharedPreferences prefs) async {
    prefs.setInt('global_sets', globalSets);
  }

  void checkBoxChanged(int index) {
    setState(() {
      ExeList[index][1] = !ExeList[index][1];
    });
    saveTaskStatus(index);
  }

  void updateGlobalSets(double value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      globalSets = value.toInt();
      for (int i = 0; i < ExeList.length; i++) {
        ExeList[i][3] = globalSets;
      }
    });
    await saveGlobalSets(prefs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Daily Exercises Checklist'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                const Text(
                  "Adjust sets for all exercises",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Slider(
                  value: globalSets.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: globalSets.toString(),
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey,
                  onChanged: updateGlobalSets,
                ),
              ],
            ),
          ),

          // Exercise list
          Expanded(
            child: ListView.builder(
              itemCount: ExeList.length,
              itemBuilder: (BuildContext context, index) {
                return ExerciseTile(
                  taskName: ExeList[index][0],
                  taskCompleted: ExeList[index][1],
                  imageUrl: ExeList[index][2],
                  sets: ExeList[index][3],
                  onChanged: (value) => checkBoxChanged(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
