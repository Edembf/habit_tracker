import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_habit_screen.dart';

class HabitTrackerScreen extends StatefulWidget {
  final String username;
  const HabitTrackerScreen({super.key, required this.username});

  @override
  _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  Map<String, String> selectedHabitsMap = {};
  Map<String, String> completedHabitsMap = {};
  String name = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? widget.username;
      selectedHabitsMap = Map<String, String>.from(
        jsonDecode(prefs.getString('selectedHabitsMap') ?? '{}'),
      );
      completedHabitsMap = Map<String, String>.from(
        jsonDecode(prefs.getString('completedHabitsMap') ?? '{}'),
      );
    });
  }

  Future<void> _saveHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedHabitsMap', jsonEncode(selectedHabitsMap));
    await prefs.setString('completedHabitsMap', jsonEncode(completedHabitsMap));
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse('0x$hexColor'));
  }

  Color _getHabitColor(String habit, Map<String, String> habitsMap) {
    String? colorHex = habitsMap[habit];
    if (colorHex != null) {
      try {
        return _getColorFromHex(colorHex);
      } catch (e) {
        debugPrint('Error parsing color for $habit: $e');
      }
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        title: Text(
          name.isNotEmpty ? name : 'Loading...',
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'To Do 📝',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: selectedHabitsMap.isEmpty
                ? const Center(
                    child: Text(
                      'Use the + button to create some habits!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : _buildListView(selectedHabitsMap, isTodo: true),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Done ✅🎉',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: completedHabitsMap.isEmpty
                ? const Center(
                    child: Text(
                      'Swipe right to mark as done.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : _buildListView(completedHabitsMap, isTodo: false),
          ),
        ],
      ),
      // LE BOUTON EST MAINTENANT TOUJOURS VISIBLE
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHabitScreen()),
          ).then((_) => _loadUserData());
        },
        backgroundColor: Colors.blue.shade800,
        tooltip: 'Add Habits',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildListView(Map<String, String> habitsMap, {required bool isTodo}) {
    final keys = habitsMap.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        String habit = keys[index];
        Color habitColor = _getHabitColor(habit, habitsMap);
        return Dismissible(
          key: Key('${isTodo ? 'todo' : 'done'}_$habit'),
          direction: isTodo
              ? DismissDirection.endToStart
              : DismissDirection.startToEnd,
          onDismissed: (_) {
            setState(() {
              if (isTodo) {
                String color = selectedHabitsMap.remove(habit)!;
                completedHabitsMap[habit] = color;
              } else {
                String color = completedHabitsMap.remove(habit)!;
                selectedHabitsMap[habit] = color;
              }
              _saveHabits();
            });
          },
          background: _buildDismissBackground(isTodo),
          child: _buildHabitCard(habit, habitColor, isCompleted: !isTodo),
        );
      },
    );
  }

  Widget _buildDismissBackground(bool isTodo) {
    return Container(
      color: isTodo ? Colors.green : Colors.orange,
      alignment: isTodo ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(isTodo ? Icons.check : Icons.undo, color: Colors.white),
    );
  }

  Widget _buildHabitCard(
    String title,
    Color color, {
    bool isCompleted = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: color,
      child: ListTile(
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: isCompleted
            ? const Icon(Icons.check_circle, color: Colors.white70)
            : null,
      ),
    );
  }
}
