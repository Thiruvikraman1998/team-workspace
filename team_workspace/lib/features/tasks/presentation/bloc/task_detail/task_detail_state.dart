import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';

part 'task_detail_state.freezed.dart';

@freezed
sealed class TaskDetailState with _$TaskDetailState {
  const factory TaskDetailState.loading() = TaskDetailLoadingState;
  const factory TaskDetailState.loaded(TasksEntity task) = TaskDetailLoadedState;
  const factory TaskDetailState.updating(TasksEntity task) = TaskDetailUpdatingState;
  const factory TaskDetailState.failure(TasksEntity task, String message) = TaskDetailFailureState;
}
