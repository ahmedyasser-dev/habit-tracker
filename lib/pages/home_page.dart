import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:provider/provider.dart';

import '../util/habit_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    //read the existing habits on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();

    super.initState();
  }

  //textField controller
  final TextEditingController textController = TextEditingController();

  //create a new habit
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
              hintText: "Create a new habit..",
              hintStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary)),
        ),
        actions: [
          //save button
          MaterialButton(
            onPressed: () {
              //get the new habit name
              String newHabitName = textController.text;

              //save to db
              context.read<HabitDatabase>().addHabit(newHabitName);

              //pop box
              Navigator.pop(context);

              //clear controller
              textController.clear();
            },
            child: Text(
              "Save",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface),
            ),
          ),
          //cancel button
          MaterialButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);

              //clear textController
              textController.clear();
            },
            child: Text(
              'cancel',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface),
            ),
          ),
        ],
      ),
    );
  }

  //check the habit on and off
  void checkHabitOnOff(bool? value, Habit habit) {
    //update the habit completion status
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  //edit habit
  void editHabitBox(Habit habit) {
    //set the controller to have the current habit's name
    textController.text = habit.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
              hintText: "Write the new habit name..",
              hintStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary)),
        ),
        actions: [
          //update button
          MaterialButton(
            onPressed: () {
              //get the new habit name
              String newHabitName = textController.text;

              //save to db
              context
                  .read<HabitDatabase>()
                  .updateHabitName(habit.id, newHabitName);

              //pop box
              Navigator.pop(context);

              //clear controller
              textController.clear();
            },
            child: Text(
              "Update",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface),
            ),
          ),
          //cancel button
          MaterialButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);

              //clear textController
              textController.clear();
            },
            child: Text(
              'cancel',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface),
            ),
          ),
        ],
      ),
    );
  }

  //delete habit
  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure you wanna delete ${habit.name}?'),
        actions: [
          //delete button
          MaterialButton(
            onPressed: () {
              //delete from db
              context.read<HabitDatabase>().deleteHabit(habit.id);

              //pop box
              Navigator.pop(context);
            },
            child: Text(
              "Delete",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface),
            ),
          ),
          //cancel button
          MaterialButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);
            },
            child: Text(
              'cancel',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: Theme.of(context).colorScheme.surface,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          //H E A T M A P
          _buildHeatMap(),

          //H A B I T | L I S T
          _buildHabitList(),
        ],
      ),
    );
  }

  //build heatmap
  Widget _buildHeatMap() {
    //habit db
    final habitDB = context.watch<HabitDatabase>();

    //current habits
    List<Habit> currentHabits = habitDB.currentHabits;

    //return the heatmap UI
    return FutureBuilder<DateTime?>(
      future: habitDB.getFirstLaunchDate(),
      builder: (context, snapshot) {
        //once the date is available => build heatmap
        if (snapshot.hasData) {
          return MyHeatMap(
            startDate: snapshot.data!,
            datasets: prepHeatMapDataset(currentHabits),
          );
        }

        //handle case where no data is returned
        else {
          return Container();
        }
      },
    );
  }

  //build habit list
  Widget _buildHabitList() {
    //habit db
    final habitDB = context.watch<HabitDatabase>();

    //current habits
    List<Habit> currentHabits = habitDB.currentHabits;

    //return list of habits UI
    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        //get each individual habit
        final habit = currentHabits[index];

        //check if the habit is completed today
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

        //return habit tile to UI
        return HabitTile(
          text: habit.name,
          isCompleted: isCompletedToday,
          onChanged: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) => editHabitBox(habit),
          deleteHabit: (context) => deleteHabitBox(habit),
        );
      },
    );
  }
}
