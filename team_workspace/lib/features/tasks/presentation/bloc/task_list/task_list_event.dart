import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';

part 'task_list_event.freezed.dart';

@freezed
sealed class TaskListEvent with _$TaskListEvent {
  const factory TaskListEvent.started() = TaskListStarted;
  const factory TaskListEvent.refreshRequested() = TaskListRefreshRequested;
  const factory TaskListEvent.nextPageRequested() = TaskListNextPageRequested;
  const factory TaskListEvent.searchChanged(String query) = TaskListSearchChanged;
  const factory TaskListEvent.statusFilterChanged(String? status) = TaskListStatusFilterChanged;
  const factory TaskListEvent.priorityFilterChanged(String? priority) = TaskListPriorityFilterChanged;

  /// Fired from the detail/form screens so the dashboard reflects changes
  /// immediately without a refetch.
  const factory TaskListEvent.taskUpserted(TasksEntity task) = TaskListTaskUpserted;
}
