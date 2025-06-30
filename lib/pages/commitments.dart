import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstchapter/utils/todo_list.dart';
import 'package:firstchapter/pages/commitments_calendar.dart';

class Commitments extends StatefulWidget {
  const Commitments({super.key});

  @override
  State<Commitments> createState() => _CommitmentsState();
}

class _CommitmentsState extends State<Commitments> {
  final TextEditingController _controller = TextEditingController();
  final User user = FirebaseAuth.instance.currentUser!;

  late final CollectionReference toDoRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('todos');

  void saveNewTask(String taskName) {
    if (taskName.trim().isEmpty) return;

    toDoRef.add({
      'task': taskName.trim(),
      'completed': false,
      'createdAt': Timestamp.now(),
    });

    _controller.clear();
  }

  void checkBoxChanged(String docId, bool currentStatus) {
    toDoRef.doc(docId).update({
      'completed': !currentStatus,
      'completedAt': !currentStatus ? Timestamp.now() : null,
    });
  }

  void deleteTask(String docId) {
    toDoRef.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("My Commitments"),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: toDoRef.orderBy('createdAt').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          final uncompletedTasks =
              docs.where((doc) => !(doc['completed'] ?? false)).toList()..sort(
                (a, b) => (a['createdAt'] as Timestamp).compareTo(
                  b['createdAt'] as Timestamp,
                ),
              );

          // Group completed tasks by date
          Map<String, List<QueryDocumentSnapshot>> completedTaskGroups = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['completed'] ?? false) {
              Timestamp? completedAt = data['completedAt'];
              String dateLabel =
                  completedAt != null
                      ? DateTime.fromMillisecondsSinceEpoch(
                        completedAt.millisecondsSinceEpoch,
                      ).toLocal().toString().split(' ')[0]
                      : "Unknown Date";

              completedTaskGroups.putIfAbsent(dateLabel, () => []).add(doc);
            }
          }

          if (docs.isEmpty) {
            return const Center(
              child: Text("No commitments yet. Add something!"),
            );
          }

          return ListView(
            children: [
              const SizedBox(height: 10),

              const CommitmentsCalendar(),

              const Divider(thickness: 1),

              ...uncompletedTasks.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return TodoList(
                  taskName: data['task'] ?? '',
                  taskCompleted: data['completed'] ?? false,
                  onChanged:
                      (_) =>
                          checkBoxChanged(doc.id, data['completed'] ?? false),
                  deleteFunction: (_) => deleteTask(doc.id),
                );
              }),

              const SizedBox(height: 20),

              // Show completed tasks under their completion date
              ...(() {
                final entries = completedTaskGroups.entries.toList();
                entries.sort(
                  (a, b) => b.key.compareTo(a.key),
                ); // Sort by date descending
                return entries.expand((entry) {
                  // Sort each group's tasks by completedAt descending
                  entry.value.sort((a, b) {
                    final aTime =
                        (a['completedAt'] as Timestamp?)
                            ?.millisecondsSinceEpoch ??
                        0;
                    final bTime =
                        (b['completedAt'] as Timestamp?)
                            ?.millisecondsSinceEpoch ??
                        0;
                    return bTime.compareTo(aTime);
                  });

                  return [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        "Completed on ${entry.key}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...entry.value.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return TodoList(
                        taskName: data['task'] ?? '',
                        taskCompleted: data['completed'] ?? false,
                        onChanged:
                            (_) => checkBoxChanged(
                              doc.id,
                              data['completed'] ?? false,
                            ),
                        deleteFunction: (_) => deleteTask(doc.id),
                      );
                    }).toList(),
                  ];
                }).toList();
              })(),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Add a new task",
                    filled: true,
                    fillColor: const Color.fromARGB(160, 255, 255, 255),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () => saveNewTask(_controller.text),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
