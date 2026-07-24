import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:team_workspace/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_form/task_form_event.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_form/task_form_state.dart';

/// Handles both Create and Edit flows. Pass [existingTask] to edit; leave it
/// null to create a brand new task.
class TaskFormBloc extends Bloc<TaskFormEvent, TaskFormState> {
  final CreateTaskUsecase _createTaskUsecase;
  final UpdateTaskUsecase _updateTaskUsecase;
  final TasksEntity? existingTask;

  static const _uuid = Uuid();

  TaskFormBloc({
    required CreateTaskUsecase createTaskUsecase,
    required UpdateTaskUsecase updateTaskUsecase,
    this.existingTask,
  }) : _createTaskUsecase = createTaskUsecase,
       _updateTaskUsecase = updateTaskUsecase,
       super(const TaskFormState.idle()) {
    on<TaskFormSubmitted>(_onSubmitted);
  }

  bool get isEditing => existingTask != null;

  Future<void> _onSubmitted(
    TaskFormSubmitted event,
    Emitter<TaskFormState> emit,
  ) async {
    emit(const TaskFormState.submitting());

    final task = TasksEntity(
      id: existingTask?.id,
      taskId: existingTask?.taskId ?? _uuid.v4(),
      title: event.title,
      description: event.description,
      priority: event.priority.apiValue,
      status: event.status.apiValue,
      assignedUser: existingTask?.assignedUser ?? event.assignedUser,
      dueDate: event.dueDate,
      createdAt: existingTask?.createdAt ?? DateTime.now(),
    );

    final result = isEditing
        ? await _updateTaskUsecase(task)
        : await _createTaskUsecase(task);

    result.when(
      success: (saved) => emit(TaskFormState.success(saved)),
      failure: (message, _) => emit(TaskFormState.failure(message)),
    );
  }
}
