import 'package:flutter/material.dart';
import 'package:team_workspace/core/global_di_instance.dart';
import 'package:team_workspace/features/tasks/di.dart';
import 'package:team_workspace/features/tasks/domain/repositories/task_repository.dart';
import 'package:team_workspace/features/tasks/presentation/views/add_edit_task_screen.dart';
import 'package:team_workspace/features/tasks/presentation/views/task_details.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();

  late TaskRepository _repo;

  @override
  void initState() {
    super.initState();
    if (!getIt.isRegistered<TaskRepository>()) {
      setupTaskDi();
    }

    _repo = getIt<TaskRepository>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTasks();
    });
  }

  Future<void> getTasks() async {
    final result = await _repo.getTasks();
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Workspace')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1565D8),
                    width: 1.5,
                  ),
                ),
                hintText: 'Search tasks',
                prefixIcon: Icon(Icons.search, color: Colors.black),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TaskDetails()),
                      );
                    },
                    child: const Card(
                      elevation: 0,
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Title of the Task'),
                                Text('Priority'),
                              ],
                            ),
                            Text('Subtitle or minimal description of the task'),
                            Row(
                              mainAxisAlignment: .spaceEvenly,
                              children: [Text('Due Date'), Text('Status')],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
