import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:team_workspace/core/di/global_di_instance.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_detail/task_detail_bloc.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_detail/task_detail_event.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_detail/task_detail_state.dart';
import 'package:team_workspace/features/tasks/presentation/views/task_form_screen.dart';
import 'package:team_workspace/features/tasks/presentation/widgets/priority_badge.dart';
import 'package:team_workspace/features/tasks/presentation/widgets/status_badge.dart';

class TaskDetailScreen extends StatelessWidget {
  final TasksEntity task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskDetailBloc>(param1: task),
      child: const _TaskDetailView(),
    );
  }
}

class _TaskDetailView extends StatelessWidget {
  const _TaskDetailView();

  TasksEntity _taskOf(TaskDetailState state) => switch (state) {
        TaskDetailLoadedState(:final task) => task,
        TaskDetailUpdatingState(:final task) => task,
        TaskDetailFailureState(:final task) => task,
        TaskDetailLoadingState() => throw StateError('unreachable'),
      };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskDetailBloc, TaskDetailState>(
      listener: (context, state) {
        if (state is TaskDetailFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final task = _taskOf(state);
        final isUpdating = state is TaskDetailUpdatingState;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) Navigator.of(context).pop(task);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Task Details'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    final updated = await Navigator.of(context).push<TasksEntity>(
                      MaterialPageRoute(builder: (_) => TaskFormScreen(existingTask: task)),
                    );
                    if (updated != null) {
                      if (context.mounted) {
                        context.read<TaskDetailBloc>().add(TaskDetailEvent.loaded(updated));
                      }
                    }
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(children: [
                    PriorityBadge(priority: task.priorityEnum),
                    const SizedBox(width: 8),
                    StatusBadge(status: task.statusEnum),
                  ]),
                  const SizedBox(height: 20),
                  _sectionTitle('Description'),
                  Text(task.description ?? 'No description provided'),
                  const SizedBox(height: 20),
                  _sectionTitle('Due date'),
                  Text(task.dueDate != null ? DateFormat('MMMM d, yyyy').format(task.dueDate!) : '-'),
                  const SizedBox(height: 20),
                  _sectionTitle('Assigned to'),
                  Text(task.assignedUser ?? 'Unassigned'),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isUpdating
                          ? null
                          : () => context.read<TaskDetailBloc>().add(
                                const TaskDetailEvent.toggleStatusRequested(),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            task.statusEnum == TaskStatus.completed ? Colors.orange : Colors.green,
                      ),
                      child: isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              task.statusEnum == TaskStatus.completed ? 'Reopen task' : 'Mark as completed',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
      );
}
