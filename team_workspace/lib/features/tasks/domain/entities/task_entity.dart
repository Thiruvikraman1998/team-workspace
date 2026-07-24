import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high }

enum TaskStatus { pending, inProgress, completed }

extension TaskPriorityX on TaskPriority {
  String get label => switch (this) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Medium',
        TaskPriority.high => 'High',
      };

  String get apiValue => name;

  static TaskPriority fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      default:
        return TaskPriority.low;
    }
  }
}

extension TaskStatusX on TaskStatus {
  String get label => switch (this) {
        TaskStatus.pending => 'Pending',
        TaskStatus.inProgress => 'In Progress',
        TaskStatus.completed => 'Completed',
      };

  String get apiValue => switch (this) {
        TaskStatus.pending => 'pending',
        TaskStatus.inProgress => 'in_progress',
        TaskStatus.completed => 'completed',
      };

  static TaskStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'in_progress':
      case 'in progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      default:
        return TaskStatus.pending;
    }
  }
}

class TasksEntity extends Equatable {
  final int? id;
  final String? taskId;
  final String? title;
  final String? description;
  final String? priority;
  final String? status;
  final String? assignedUser;
  final DateTime? dueDate;
  final DateTime? createdAt;

  const TasksEntity({
    this.id,
    this.taskId,
    this.title,
    this.description,
    this.priority,
    this.status,
    this.assignedUser,
    this.dueDate,
    this.createdAt,
  });

  TaskPriority get priorityEnum => TaskPriorityX.fromString(priority);
  TaskStatus get statusEnum => TaskStatusX.fromString(status);

  TasksEntity copyWith({
    int? id,
    String? taskId,
    String? title,
    String? description,
    String? priority,
    String? status,
    String? assignedUser,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return TasksEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedUser: assignedUser ?? this.assignedUser,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        title,
        description,
        priority,
        status,
        assignedUser,
        dueDate,
        createdAt,
      ];
}
