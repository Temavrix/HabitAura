import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstchapter/utils/todo_list.dart';

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
    toDoRef.doc(docId).update({'completed': !currentStatus});
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

          if (docs.isEmpty) {
            return const Center(child: Text("No tasks yet. Add something!"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return TodoList(
                taskName: data['task'] ?? '',
                taskCompleted: data['completed'] ?? false,
                onChanged:
                    (_) => checkBoxChanged(doc.id, data['completed'] ?? false),
                deleteFunction: (_) => deleteTask(doc.id),
              );
            },
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
                    fillColor: Colors.white12,
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
