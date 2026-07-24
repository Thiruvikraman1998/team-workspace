import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';

part 'task_list_state.freezed.dart';

enum TaskListStatus { initial, loading, loadingMore, success, empty, failure }

@freezed
sealed class TaskListState with _$TaskListState {
  const TaskListState._();

  const factory TaskListState({
    @Default(TaskListStatus.initial) TaskListStatus status,
    @Default([]) List<TasksEntity> tasks,
    @Default(1) int currentPage,
    @Default(true) bool hasMore,
    @Default('') String searchQuery,
    String? statusFilter,
    String? priorityFilter,
    String? errorMessage,
  }) = _TaskListState;

  bool get isInitialLoading => status == TaskListStatus.loading && currentPage == 1;
  bool get isLoadingMore => status == TaskListStatus.loadingMore;
}
