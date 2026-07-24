import 'package:flutter/material.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';

class FilterBar extends StatelessWidget {
  final String? statusFilter;
  final String? priorityFilter;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onPriorityChanged;

  const FilterBar({
    super.key,
    required this.statusFilter,
    required this.priorityFilter,
    required this.onStatusChanged,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          Text('Status'),
          _dropdown(
            hint: 'Status',
            value: statusFilter,
            items: TaskStatus.values.map((e) => e.apiValue).toList(),
            labels: TaskStatus.values.map((e) => e.label).toList(),
            onChanged: onStatusChanged,
          ),
          Text('Priority'),
          _dropdown(
            hint: 'Priority',
            value: priorityFilter,
            items: TaskPriority.values.map((e) => e.apiValue).toList(),
            labels: TaskPriority.values.map((e) => e.label).toList(),
            onChanged: onPriorityChanged,
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required List<String> labels,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          hint: Text(hint),
          value: value,
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('All')),
            for (var i = 0; i < items.length; i++)
              DropdownMenuItem<String?>(
                value: items[i],
                child: Text(labels[i]),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
