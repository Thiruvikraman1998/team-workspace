import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/presentation/widgets/priority_badge.dart';
import 'package:team_workspace/features/tasks/presentation/widgets/status_badge.dart';

class TaskCard extends StatelessWidget {
  final TasksEntity task;
  final VoidCallback onTap;

  const TaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dueDate = task.dueDate;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title ?? 'Untitled task',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              if ((task.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  PriorityBadge(priority: task.priorityEnum),
                  const SizedBox(width: 8),
                  StatusBadge(status: task.statusEnum),
                  const Spacer(),
                  if (dueDate != null)
                    Text(
                      DateFormat('MMM d, yyyy').format(dueDate),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
