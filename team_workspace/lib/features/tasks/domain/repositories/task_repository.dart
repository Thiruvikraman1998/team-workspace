import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';

class TaskQueryParams {
  final int page;
  final int pageSize;
  final String? search;
  final String? statusFilter;
  final String? priorityFilter;

  const TaskQueryParams({
    this.page = 1,
    this.pageSize = 15,
    this.search,
    this.statusFilter,
    this.priorityFilter,
  });
}

class PaginatedTasks {
  final List<TasksEntity> tasks;
  final bool hasMore;

  const PaginatedTasks({required this.tasks, required this.hasMore});
}

abstract class TaskRepository {
  /// Fetches a page of tasks from the remote API. Falls back to the local
  /// sqflite cache automatically when there is no connectivity.
  Future<Result<PaginatedTasks>> getTasks(TaskQueryParams params);

  /// Returns the last cached page (used for the very first start / offline
  /// start) without hitting the network.
  Future<List<TasksEntity>> getCachedTasks();

  Future<Result<TasksEntity>> getTaskById(String taskId);

  Future<Result<TasksEntity>> createTask(TasksEntity task);

  Future<Result<TasksEntity>> updateTask(TasksEntity task);
}
