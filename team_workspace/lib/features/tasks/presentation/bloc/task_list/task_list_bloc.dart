import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/repositories/task_repository.dart';
import 'package:team_workspace/features/tasks/domain/usecases/get_cached_tasks_usecase.dart';
import 'package:team_workspace/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_list/task_list_event.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_list/task_list_state.dart';

const _pageSize = 15;

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final GetTasksUsecase _getTasksUsecase;
  final GetCachedTasksUsecase _getCachedTasksUsecase;

  Timer? _debounce;

  TaskListBloc({
    required GetTasksUsecase getTasksUsecase,
    required GetCachedTasksUsecase getCachedTasksUsecase,
  })  : _getTasksUsecase = getTasksUsecase,
        _getCachedTasksUsecase = getCachedTasksUsecase,
        super(const TaskListState()) {
    on<TaskListStarted>(_onStarted);
    on<TaskListRefreshRequested>(_onRefresh);
    on<TaskListNextPageRequested>(_onNextPage);
    on<TaskListSearchChanged>(_onSearchChanged);
    on<TaskListStatusFilterChanged>(_onStatusFilterChanged);
    on<TaskListPriorityFilterChanged>(_onPriorityFilterChanged);
    on<TaskListTaskUpserted>(_onTaskUpserted);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  Future<void> _onStarted(TaskListStarted event, Emitter<TaskListState> emit) async {
    // paint something instantly from cache, then refresh from network
    final cached = await _getCachedTasksUsecase();
    if (cached.isNotEmpty) {
      emit(state.copyWith(status: TaskListStatus.success, tasks: cached, hasMore: true, currentPage: 1));
    }
    await _fetchPage(emit, page: 1, replace: true);
  }

  Future<void> _onRefresh(TaskListRefreshRequested event, Emitter<TaskListState> emit) async {
    await _fetchPage(emit, page: 1, replace: true);
  }

  Future<void> _onNextPage(TaskListNextPageRequested event, Emitter<TaskListState> emit) async {
    if (state.isLoadingMore || !state.hasMore || state.status == TaskListStatus.loading) return;
    await _fetchPage(emit, page: state.currentPage + 1, replace: false);
  }

  Future<void> _onSearchChanged(TaskListSearchChanged event, Emitter<TaskListState> emit) async {
    emit(state.copyWith(searchQuery: event.query));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      add(const TaskListEvent.refreshRequested());
    });
  }

  Future<void> _onStatusFilterChanged(
    TaskListStatusFilterChanged event,
    Emitter<TaskListState> emit,
  ) async {
    emit(state.copyWith(statusFilter: event.status));
    add(const TaskListEvent.refreshRequested());
  }

  Future<void> _onPriorityFilterChanged(
    TaskListPriorityFilterChanged event,
    Emitter<TaskListState> emit,
  ) async {
    emit(state.copyWith(priorityFilter: event.priority));
    add(const TaskListEvent.refreshRequested());
  }

  void _onTaskUpserted(TaskListTaskUpserted event, Emitter<TaskListState> emit) {
    final task = event.task;
    final tasks = List<TasksEntity>.from(state.tasks);
    final idx = tasks.indexWhere((t) => _sameTask(t, task));
    if (idx >= 0) {
      tasks[idx] = task;
    } else {
      tasks.insert(0, task);
    }
    emit(state.copyWith(tasks: tasks, status: TaskListStatus.success));
  }

  bool _sameTask(TasksEntity a, TasksEntity b) {
    if (a.taskId != null && b.taskId != null) return a.taskId == b.taskId;
    return a.id == b.id;
  }

  Future<void> _fetchPage(
    Emitter<TaskListState> emit, {
    required int page,
    required bool replace,
  }) async {
    emit(state.copyWith(
      status: replace ? TaskListStatus.loading : TaskListStatus.loadingMore,
      errorMessage: null,
    ));

    final result = await _getTasksUsecase(TaskQueryParams(
      page: page,
      pageSize: _pageSize,
      search: state.searchQuery,
      statusFilter: state.statusFilter,
      priorityFilter: state.priorityFilter,
    ));

    result.when(
      success: (data) {
        final tasks = replace ? data.tasks : [...state.tasks, ...data.tasks];
        emit(state.copyWith(
          status: tasks.isEmpty ? TaskListStatus.empty : TaskListStatus.success,
          tasks: tasks,
          currentPage: page,
          hasMore: data.hasMore,
        ));
      },
      failure: (message, _) {
        if (state.tasks.isNotEmpty && !replace) {
          // keep existing list visible, just surface the pagination error
          emit(state.copyWith(status: TaskListStatus.success, errorMessage: message));
        } else {
          emit(state.copyWith(status: TaskListStatus.failure, errorMessage: message));
        }
      },
    );
  }
}
