import 'package:flutter/material.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const PriorityBadge({super.key, required this.priority});

  Color get _color => switch (priority) {
        TaskPriority.high => Colors.red,
        TaskPriority.medium => Colors.orange,
        TaskPriority.low => Colors.green,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.label,
        style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
