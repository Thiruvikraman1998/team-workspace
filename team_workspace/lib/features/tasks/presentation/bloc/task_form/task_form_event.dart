import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';

part 'task_form_event.freezed.dart';

@freezed
sealed class TaskFormEvent with _$TaskFormEvent {
  const factory TaskFormEvent.submitted({
    required String title,
    required String description,
    required TaskPriority priority,
    required TaskStatus status,
    required DateTime dueDate,
    required String assignedUser,
  }) = TaskFormSubmitted;
}
