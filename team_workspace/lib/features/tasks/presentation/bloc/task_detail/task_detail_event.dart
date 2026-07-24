import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';

part 'task_detail_event.freezed.dart';

@freezed
sealed class TaskDetailEvent with _$TaskDetailEvent {
  const factory TaskDetailEvent.loaded(TasksEntity task) = TaskDetailLoaded;
  const factory TaskDetailEvent.toggleStatusRequested() = TaskDetailToggleStatusRequested;
}
