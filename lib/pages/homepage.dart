import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firstchapter/pages/commitments.dart';
import 'package:firstchapter/pages/exercise.dart';
import 'package:firstchapter/pages/login_page.dart';
import 'package:firstchapter/pages/budgettracker.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  // List of quotes [quoteText, author]
  final List<List<String>> ExeList = [
    [
      "Push yourself, because no one else is going to do it for you.",
      "Unknown",
    ],
    ["Discipline is the bridge between goals and accomplishment.", "Jim Rohn"],
    ["It always seems impossible until it’s done.", "Nelson Mandela"],
    ["Success starts with self-discipline.", "Unknown"],
    [
      "Your body can stand almost anything. It’s your mind that you have to convince.",
      "Unknown",
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final quote = ExeList[random.nextInt(ExeList.length)];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text("HabitAura"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                '"${quote[0]}"\n– ${quote[1]}',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
            ),

            buildImageContainer(
              context,
              imageUrl:
                  'https://images.unsplash.com/photo-1573679251481-6a94d5f501a4?q=80&w=2033&auto=format&fit=crop',
              text: "Your Commitments Planned >>>",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Commitments()),
                  ),
            ),
            SizedBox(height: 20),

            buildImageContainer(
              context,
              imageUrl:
                  'https://images.unsplash.com/photo-1593079831268-3381b0db4a77?q=80&w=1469&auto=format&fit=crop',
              text: "Sore today, strong tomorrow >>>",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExercisePage()),
                  ),
            ),
            SizedBox(height: 20),

            buildImageContainer(
              context,
              imageUrl:
                  'https://images.unsplash.com/photo-1555217851-6141535bd771?q=80&w=2574&auto=format&fit=crop',
              text: "Save more. Stress less >>>",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BudgetTracker()),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageContainer(
    BuildContext context, {
    required String imageUrl,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 170,
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Align(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
