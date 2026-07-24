import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_detail/task_detail_bloc.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_detail/task_detail_event.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_detail/task_detail_state.dart';

class MockUpdateTaskUsecase extends Mock implements UpdateTaskUsecase {}

void main() {
  late TaskDetailBloc taskDetailBloc;
  late MockUpdateTaskUsecase mockUpdateTaskUsecase;

  const tInitialTask = TasksEntity(
    id: 1,
    title: 'Initial Task',
    status: 'pending',
  );

  setUp(() {
    mockUpdateTaskUsecase = MockUpdateTaskUsecase();
    taskDetailBloc = TaskDetailBloc(
      updateTaskUsecase: mockUpdateTaskUsecase,
      initialTask: tInitialTask,
    );
  });

  setUpAll(() {
    registerFallbackValue(const TasksEntity());
  });

  group('TaskDetailLoaded', () {
    const tNewTask = TasksEntity(id: 1, title: 'Updated Externally');
    blocTest<TaskDetailBloc, TaskDetailState>(
      'emits [loaded] with the new task',
      build: () => taskDetailBloc,
      act: (bloc) => bloc.add(const TaskDetailEvent.loaded(tNewTask)),
      expect: () => [
        const TaskDetailState.loaded(tNewTask),
      ],
    );
  });

  group('TaskDetailToggleStatusRequested', () {
    final tUpdatedTask = tInitialTask.copyWith(status: TaskStatus.completed.apiValue);

    blocTest<TaskDetailBloc, TaskDetailState>(
      'emits [updating, loaded] when toggle is successful',
      build: () {
        when(() => mockUpdateTaskUsecase(any())).thenAnswer((_) async => SuccessResult(data: tUpdatedTask));
        return taskDetailBloc;
      },
      act: (bloc) => bloc.add(const TaskDetailEvent.toggleStatusRequested()),
      expect: () => [
        TaskDetailState.updating(tUpdatedTask),
        TaskDetailState.loaded(tUpdatedTask),
      ],
    );

    blocTest<TaskDetailBloc, TaskDetailState>(
      'emits [updating, failure] when toggle fails',
      build: () {
        when(() => mockUpdateTaskUsecase(any())).thenAnswer((_) async => const FailureResult(errorMessage: 'Network error'));
        return taskDetailBloc;
      },
      act: (bloc) => bloc.add(const TaskDetailEvent.toggleStatusRequested()),
      expect: () => [
        TaskDetailState.updating(tUpdatedTask),
        const TaskDetailState.failure(tInitialTask, 'Network error'),
      ],
    );
  });
}
