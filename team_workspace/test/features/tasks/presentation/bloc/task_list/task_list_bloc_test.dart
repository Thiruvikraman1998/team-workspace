import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/repositories/task_repository.dart';
import 'package:team_workspace/features/tasks/domain/usecases/get_cached_tasks_usecase.dart';
import 'package:team_workspace/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_list/task_list_bloc.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_list/task_list_event.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_list/task_list_state.dart';

class MockGetTasksUsecase extends Mock implements GetTasksUsecase {}
class MockGetCachedTasksUsecase extends Mock implements GetCachedTasksUsecase {}

void main() {
  late TaskListBloc taskListBloc;
  late MockGetTasksUsecase mockGetTasksUsecase;
  late MockGetCachedTasksUsecase mockGetCachedTasksUsecase;

  setUp(() {
    mockGetTasksUsecase = MockGetTasksUsecase();
    mockGetCachedTasksUsecase = MockGetCachedTasksUsecase();
    taskListBloc = TaskListBloc(
      getTasksUsecase: mockGetTasksUsecase,
      getCachedTasksUsecase: mockGetCachedTasksUsecase,
    );
  });

  const tTasks = [TasksEntity(id: 1, title: 'Task 1')];
  const tPaginatedTasks = PaginatedTasks(tasks: tTasks, hasMore: false);

  setUpAll(() {
    registerFallbackValue(const TaskQueryParams());
  });

  group('TaskListStarted', () {
    blocTest<TaskListBloc, TaskListState>(
      'emits [success(cached), loading, success(remote)] when started and cache is not empty',
      build: () {
        when(() => mockGetCachedTasksUsecase()).thenAnswer((_) async => tTasks);
        when(() => mockGetTasksUsecase(any())).thenAnswer((_) async => const SuccessResult(data: tPaginatedTasks));
        return taskListBloc;
      },
      act: (bloc) => bloc.add(const TaskListEvent.started()),
      expect: () => [
        const TaskListState(status: TaskListStatus.success, tasks: tTasks, hasMore: true, currentPage: 1),
        const TaskListState(status: TaskListStatus.loading, tasks: tTasks, hasMore: true, currentPage: 1),
        const TaskListState(status: TaskListStatus.success, tasks: tTasks, hasMore: false, currentPage: 1),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'emits [loading, success] when started and cache is empty',
      build: () {
        when(() => mockGetCachedTasksUsecase()).thenAnswer((_) async => []);
        when(() => mockGetTasksUsecase(any())).thenAnswer((_) async => const SuccessResult(data: tPaginatedTasks));
        return taskListBloc;
      },
      act: (bloc) => bloc.add(const TaskListEvent.started()),
      expect: () => [
        const TaskListState(status: TaskListStatus.loading),
        const TaskListState(status: TaskListStatus.success, tasks: tTasks, hasMore: false, currentPage: 1),
      ],
    );
  });

  group('TaskListRefreshRequested', () {
    blocTest<TaskListBloc, TaskListState>(
      'emits [loading, success] when refresh is requested',
      build: () {
        when(() => mockGetTasksUsecase(any())).thenAnswer((_) async => const SuccessResult(data: tPaginatedTasks));
        return taskListBloc;
      },
      act: (bloc) => bloc.add(const TaskListEvent.refreshRequested()),
      expect: () => [
        const TaskListState(status: TaskListStatus.loading),
        const TaskListState(status: TaskListStatus.success, tasks: tTasks, hasMore: false, currentPage: 1),
      ],
    );
  });

  group('TaskListSearchChanged', () {
    blocTest<TaskListBloc, TaskListState>(
      'emits state with new query and eventually triggers refresh',
      build: () {
        when(() => mockGetTasksUsecase(any())).thenAnswer((_) async => const SuccessResult(data: tPaginatedTasks));
        return taskListBloc;
      },
      act: (bloc) => bloc.add(const TaskListEvent.searchChanged('new search')),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const TaskListState(searchQuery: 'new search'),
        const TaskListState(status: TaskListStatus.loading, searchQuery: 'new search'),
        const TaskListState(status: TaskListStatus.success, tasks: tTasks, hasMore: false, currentPage: 1, searchQuery: 'new search'),
      ],
    );
  });
}
