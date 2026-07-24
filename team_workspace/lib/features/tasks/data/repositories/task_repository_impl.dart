import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/core/network/dio_error_mappers.dart';
import 'package:team_workspace/core/network/network_info.dart';
import 'package:team_workspace/features/tasks/data/local_datasources/task_local_datasource.dart';
import 'package:team_workspace/features/tasks/data/models/task_model.dart';
import 'package:team_workspace/features/tasks/data/remote_datasources/task_remote_datasource.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDatasource _remoteDatasource;
  final TaskLocalDatasource _localDatasource;
  final NetworkInfo _networkInfo;

  TaskRepositoryImpl(this._remoteDatasource, this._localDatasource, this._networkInfo);

  @override
  Future<Result<PaginatedTasks>> getTasks(TaskQueryParams params) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      // Offline: serve from cache. Pagination beyond page 1 has no more
      // pages to fetch locally so we simply return everything on page 1.
      final cached = await _localDatasource.getCachedTasks(
        search: params.search,
        statusFilter: params.statusFilter,
        priorityFilter: params.priorityFilter,
      );
      if (params.page > 1) {
        return const SuccessResult(data: PaginatedTasks(tasks: [], hasMore: false));
      }
      return SuccessResult(
        data: PaginatedTasks(tasks: cached.map((e) => e.toEntity()).toList(), hasMore: false),
      );
    }

    try {
      final result = await _remoteDatasource.getTasks(
        page: params.page,
        pageSize: params.pageSize,
        search: params.search,
        statusFilter: params.statusFilter,
        priorityFilter: params.priorityFilter,
      );

      await _localDatasource.cacheTasks(result, clearExisting: params.page == 1);

      log('Fetched ${result.length} tasks (page ${params.page})');

      return SuccessResult(
        data: PaginatedTasks(
          tasks: result.map((e) => e.toEntity()).toList(),
          hasMore: result.length == params.pageSize,
        ),
      );
    } on DioException catch (e) {
      // network hiccup mid-session: fall back to cache so the UI still has
      // something meaningful to show, but surface the error via message.
      final cached = await _localDatasource.getCachedTasks(
        search: params.search,
        statusFilter: params.statusFilter,
        priorityFilter: params.priorityFilter,
      );
      if (cached.isNotEmpty && params.page == 1) {
        return SuccessResult(
          data: PaginatedTasks(tasks: cached.map((e) => e.toEntity()).toList(), hasMore: false),
        );
      }
      return FailureResult(
        errorMessage: DioErrorMappers.fromException(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return FailureResult(errorMessage: e.toString());
    }
  }

  @override
  Future<List<TasksEntity>> getCachedTasks() async {
    final cached = await _localDatasource.getCachedTasks();
    return cached.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Result<TasksEntity>> getTaskById(String taskId) async {
    try {
      final cached = await _localDatasource.getTaskByLocalId(taskId);
      if (cached != null) return SuccessResult(data: cached.toEntity());
      return const FailureResult(errorMessage: 'Task not found');
    } catch (e) {
      return FailureResult(errorMessage: e.toString());
    }
  }

  @override
  Future<Result<TasksEntity>> createTask(TasksEntity task) async {
    final model = TaskModel.fromEntity(task);
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      await _localDatasource.upsertTask(model, isSynced: false);
      await _localDatasource.enqueuePendingAction(PendingActionType.create, model);
      return SuccessResult(data: model.toEntity());
    }

    try {
      final created = await _remoteDatasource.createTask(model);
      await _localDatasource.upsertTask(created, isSynced: true);
      return SuccessResult(data: created.toEntity());
    } on DioException catch (e) {
      // queue for retry instead of failing
      await _localDatasource.upsertTask(model, isSynced: false);
      await _localDatasource.enqueuePendingAction(PendingActionType.create, model);
      return FailureResult(
        errorMessage: DioErrorMappers.fromException(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return FailureResult(errorMessage: e.toString());
    }
  }

  @override
  Future<Result<TasksEntity>> updateTask(TasksEntity task) async {
    final model = TaskModel.fromEntity(task);
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      await _localDatasource.upsertTask(model, isSynced: false);
      await _localDatasource.enqueuePendingAction(PendingActionType.update, model);
      return SuccessResult(data: model.toEntity());
    }

    try {
      final updated = await _remoteDatasource.updateTask(model);
      await _localDatasource.upsertTask(updated, isSynced: true);
      return SuccessResult(data: updated.toEntity());
    } on DioException catch (e) {
      await _localDatasource.upsertTask(model, isSynced: false);
      await _localDatasource.enqueuePendingAction(PendingActionType.update, model);
      return FailureResult(
        errorMessage: DioErrorMappers.fromException(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return FailureResult(errorMessage: e.toString());
    }
  }
}
