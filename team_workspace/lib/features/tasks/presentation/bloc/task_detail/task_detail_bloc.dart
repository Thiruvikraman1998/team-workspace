import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_detail/task_detail_event.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_detail/task_detail_state.dart';

class TaskDetailBloc extends Bloc<TaskDetailEvent, TaskDetailState> {
  final UpdateTaskUsecase _updateTaskUsecase;

  TaskDetailBloc({
    required UpdateTaskUsecase updateTaskUsecase,
    required TasksEntity initialTask,
  }) : _updateTaskUsecase = updateTaskUsecase,
       super(TaskDetailState.loaded(initialTask)) {
    on<TaskDetailLoaded>(
      (event, emit) => emit(TaskDetailState.loaded(event.task)),
    );
    on<TaskDetailToggleStatusRequested>(_onToggleStatus);
  }

  Future<void> _onToggleStatus(
    TaskDetailToggleStatusRequested event,
    Emitter<TaskDetailState> emit,
  ) async {
    final current = switch (state) {
      TaskDetailLoadedState(:final task) => task,
      TaskDetailUpdatingState(:final task) => task,
      TaskDetailFailureState(:final task) => task,
      TaskDetailLoadingState() => throw StateError('unreachable'),
    };

    final newStatus = current.statusEnum == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;
    final optimistic = current.copyWith(status: newStatus.apiValue);

    emit(TaskDetailState.updating(optimistic));

    final result = await _updateTaskUsecase(optimistic);
    result.when(
      success: (updated) => emit(TaskDetailState.loaded(updated)),
      failure: (message, _) => emit(TaskDetailState.failure(current, message)),
    );
  }
}
