import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:team_workspace/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_form/task_form_bloc.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_form/task_form_event.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_form/task_form_state.dart';

class MockCreateTaskUsecase extends Mock implements CreateTaskUsecase {}
class MockUpdateTaskUsecase extends Mock implements UpdateTaskUsecase {}

void main() {
  late TaskFormBloc taskFormBloc;
  late MockCreateTaskUsecase mockCreateTaskUsecase;
  late MockUpdateTaskUsecase mockUpdateTaskUsecase;

  setUp(() {
    mockCreateTaskUsecase = MockCreateTaskUsecase();
    mockUpdateTaskUsecase = MockUpdateTaskUsecase();
    taskFormBloc = TaskFormBloc(
      createTaskUsecase: mockCreateTaskUsecase,
      updateTaskUsecase: mockUpdateTaskUsecase,
    );
  });

  const tTask = TasksEntity(id: 1, title: 'New Task');

  setUpAll(() {
    registerFallbackValue(const TasksEntity());
  });

  group('TaskFormSubmitted (Create)', () {
    blocTest<TaskFormBloc, TaskFormState>(
      'emits [submitting, success] when create is successful',
      build: () {
        when(() => mockCreateTaskUsecase(any())).thenAnswer((_) async => const SuccessResult(data: tTask));
        return taskFormBloc;
      },
      act: (bloc) => bloc.add(const TaskFormEvent.submitted(
        title: 'New Task',
        description: 'Desc',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
      )),
      expect: () => [
        const TaskFormState.submitting(),
        const TaskFormState.success(tTask),
      ],
    );

    blocTest<TaskFormBloc, TaskFormState>(
      'emits [submitting, failure] when create fails',
      build: () {
        when(() => mockCreateTaskUsecase(any())).thenAnswer((_) async => const FailureResult(errorMessage: 'Error'));
        return taskFormBloc;
      },
      act: (bloc) => bloc.add(const TaskFormEvent.submitted(
        title: 'New Task',
        description: 'Desc',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
      )),
      expect: () => [
        const TaskFormState.submitting(),
        const TaskFormState.failure('Error'),
      ],
    );
  });

  group('TaskFormSubmitted (Edit)', () {
    const existingTask = TasksEntity(id: 1, title: 'Old Title', taskId: 'uuid-123');
    
    setUp(() {
      taskFormBloc = TaskFormBloc(
        createTaskUsecase: mockCreateTaskUsecase,
        updateTaskUsecase: mockUpdateTaskUsecase,
        existingTask: existingTask,
      );
    });

    blocTest<TaskFormBloc, TaskFormState>(
      'emits [submitting, success] when update is successful',
      build: () {
        when(() => mockUpdateTaskUsecase(any())).thenAnswer((_) async => const SuccessResult(data: tTask));
        return taskFormBloc;
      },
      act: (bloc) => bloc.add(const TaskFormEvent.submitted(
        title: 'Updated Title',
        description: 'Desc',
        priority: TaskPriority.medium,
        status: TaskStatus.inProgress,
      )),
      expect: () => [
        const TaskFormState.submitting(),
        const TaskFormState.success(tTask),
      ],
      verify: (_) {
        verify(() => mockUpdateTaskUsecase(any(that: isA<TasksEntity>().having((e) => e.taskId, 'taskId', 'uuid-123')))).called(1);
      },
    );
  });
}
