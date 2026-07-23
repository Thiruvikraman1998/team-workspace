import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
sealed class TaskModel with _$TaskModel {
  const TaskModel._();

  const factory TaskModel({
    @JsonKey(name: 'id') required int? id,
    @JsonKey(name: 'task_id') required String? taskId,
    @JsonKey(name: 'title') required String? title,
    @JsonKey(name: 'description') required String? description,
    @JsonKey(name: 'priority') required String? priority,
    @JsonKey(name: 'current_status') required String? status,
    @JsonKey(name: 'due_date') required DateTime? dueDate,
    @JsonKey(name: 'created_at') required DateTime? createdAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  TasksEntity toEntity() {
    return TasksEntity(
      id: id,
      taskId: taskId,
      title: title,
      description: description,
      priority: priority,
      status: status,
      dueDate: dueDate,
      createdAt: createdAt,
    );
  }
}
