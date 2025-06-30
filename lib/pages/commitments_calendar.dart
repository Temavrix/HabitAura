import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommitmentsCalendar extends StatefulWidget {
  const CommitmentsCalendar({super.key});

  @override
  State<CommitmentsCalendar> createState() => _CommitmentsCalendarState();
}

class _CommitmentsCalendarState extends State<CommitmentsCalendar> {
  final User user = FirebaseAuth.instance.currentUser!;
  late final CollectionReference toDoRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('todos');

  Map<DateTime, bool> _dayStatusMap =
      {}; // true = has completed task, false = only incomplete

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final snapshot = await toDoRef.get();
    Map<DateTime, bool> map = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      Timestamp createdAt = data['createdAt'];
      DateTime date =
          DateTime.fromMillisecondsSinceEpoch(
            createdAt.millisecondsSinceEpoch,
          ).toLocal();
      DateTime day = DateTime(date.year, date.month, date.day);

      bool completed = data['completed'] ?? false;

      if (!map.containsKey(day)) {
        map[day] = completed;
      } else {
        // If any task is completed for the day, mark it completed
        map[day] = map[day]! || completed;
      }
    }

    setState(() {
      _dayStatusMap = map;
    });
  }

  Widget _buildMarker(DateTime date, bool? completed) {
    if (completed == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 7,
        height: 7,
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: completed ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2025, 6, 1),
      lastDay: DateTime.utc(2040, 12, 31),
      focusedDay: DateTime.now(),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, _) {
          final dateKey = DateTime(day.year, day.month, day.day);
          final completed = _dayStatusMap[dateKey];
          return _buildMarker(day, completed);
        },
      ),
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        markerMargin: EdgeInsets.symmetric(horizontal: 1),
      ),
    );
  }
}
