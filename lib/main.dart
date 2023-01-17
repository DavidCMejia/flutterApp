import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

final tasksProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(tasks: [
    const Task(id: 1, label: "Load rocket with supplies"),
    const Task(id: 2, label: "Launch rocket"),
    const Task(id: 3, label: "Head out to the first moon"),
  ]);
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exploration!',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Space Exploration Planner!'),
      ),
      body: Column(
        children: const [
          Progress(),
          TaskList(),
        ],
      ),
    );
  }
}

class Progress extends ConsumerWidget {
  const Progress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tasks = ref.watch(tasksProvider);
    var numCompletedTasks = tasks.where((task) => task.completed).length;

    return Column(
      children: [
        const Text("You are this far away from explore the universe!"),
        LinearProgressIndicator(value: numCompletedTasks / tasks.length)
      ],
    );
  }
}

class TaskList extends ConsumerWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tasks = ref.watch(tasksProvider);
    return Column(
      children: tasks
          .map(
            (task) => TaskItem(task: task),
          )
          .toList(),
    );
  }
}

class TaskItem extends ConsumerWidget {
  final Task task;

  const TaskItem({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Checkbox(
          onChanged: (newValue) =>
              ref.read(tasksProvider.notifier).toggle(task.id),
          value: task.completed,
        ),
        Text(task.label),
      ],
    );
  }
}

@immutable
class Task {
  final int id;
  final String label;
  final bool completed;

  const Task({required this.id, required this.label, this.completed = false});
  Task copyWith({int? id, String? label, bool? completed}) {
    return Task(
      id: id ?? this.id,
      label: label ?? this.label,
      completed: completed ?? this.completed,
    );
  }
}

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier({required List<Task> tasks}) : super(tasks);

  void add(Task task) {
    state = [...state, task];
  }

  void remove(Task task) {
    state = state.where((t) => t.id != task.id).toList();
  }

  void toggle(int taskId) {
    state = [
      for (final item in state)
        if (taskId == item.id)
          item.copyWith(completed: !item.completed)
        else
          item
    ];
  }
}
