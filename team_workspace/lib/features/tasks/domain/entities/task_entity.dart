import 'package:equatable/equatable.dart';

class TasksEntity extends Equatable {
  final int? id;
  final String? taskId;
  final String? title;
  final String? description;
  final String? priority;
  final String? status;
  final DateTime? dueDate;
  final DateTime? createdAt;

  const TasksEntity({
    this.id,
    this.taskId,
    this.title,
    this.description,
    this.priority,
    this.status,
    this.dueDate,
    this.createdAt,
  });

  factory TasksEntity.fromJson(Map<String, dynamic> json) => TasksEntity(
    id: json['id'],
    taskId: json['taskId'],
    title: json['title'],
    description: json['description'],
    priority: json['priority'],
    status: json['status'],
    dueDate: json['dueDate'],
    createdAt: json['createdAt'],
  );

  @override
  List<Object?> get props => [
    id,
    taskId,
    title,
    description,
    priority,
    status,
    dueDate,
    createdAt,
  ];
}
