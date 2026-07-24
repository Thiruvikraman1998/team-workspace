import 'package:dio/dio.dart';
import 'package:team_workspace/core/constants/api_endpoints.dart';
import 'package:team_workspace/core/network/api_client.dart';
import 'package:team_workspace/features/tasks/data/models/task_model.dart';

abstract class TaskRemoteDatasource {
  /// PostgREST-style pagination using `Range` header (offset/limit).
  Future<List<TaskModel>> getTasks({
    required int page,
    required int pageSize,
    String? search,
    String? statusFilter,
    String? priorityFilter,
  });

  Future<TaskModel> createTask(TaskModel task);

  Future<TaskModel> updateTask(TaskModel task);
}

class TaskRemoteDatasourceImpl implements TaskRemoteDatasource {
  final ApiClient _apiClient;

  TaskRemoteDatasourceImpl(this._apiClient);

  @override
  Future<List<TaskModel>> getTasks({
    required int page,
    required int pageSize,
    String? search,
    String? statusFilter,
    String? priorityFilter,
  }) async {
    final from = (page - 1) * pageSize;
    final to = from + pageSize - 1;

    final queryParams = <String, dynamic>{'order': 'created_at.desc'};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['title'] = 'ilike.*${search.trim()}*';
    }
    if (statusFilter != null && statusFilter.isNotEmpty) {
      queryParams['current_status'] = 'eq.$statusFilter';
    }
    if (priorityFilter != null && priorityFilter.isNotEmpty) {
      queryParams['priority'] = 'eq.$priorityFilter';
    }

    final response = await _apiClient.get(
      ApiEndpoints.tasks,
      queryParams: queryParams,
      options: Options(headers: {'Range': '$from-$to'}),
    );

    final data = response.data as List;
    return data
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    final response = await _apiClient.post(
      ApiEndpoints.tasks,
      data: task.toRequestJson(),
      options: Options(headers: {'Prefer': 'return=representation'}),
    );
    final data = response.data;
    final json = data is List ? data.first : data;
    return TaskModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    final response = await _apiClient.put(
      ApiEndpoints.taskById(task.id!),
      data: task.toRequestJson(),
      options: Options(headers: {'Prefer': 'return=representation'}),
    );
    final data = response.data;
    final json = data is List ? data.first : data;
    return TaskModel.fromJson(json as Map<String, dynamic>);
  }
}
