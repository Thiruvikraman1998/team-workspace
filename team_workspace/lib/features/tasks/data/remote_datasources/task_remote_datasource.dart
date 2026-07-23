import 'package:team_workspace/core/constants/api_endpoints.dart';
import 'package:team_workspace/core/network/api_client.dart';
import 'package:team_workspace/features/tasks/data/models/task_model.dart';

abstract class TaskRemoteDatasource {
  Future<List<TaskModel>> getTasks({Map<String, dynamic>? queryParams});
}

class TaskRemoteDatasourceImpl implements TaskRemoteDatasource {
  final ApiClient _apiClient;

  TaskRemoteDatasourceImpl(this._apiClient);

  @override
  Future<List<TaskModel>> getTasks({Map<String, dynamic>? queryParams}) async {
    final response = await _apiClient.get(
      ApiEndpoints.tasks,
      queryParams: queryParams,
    );
    final data = response.data as List;
    return data.map((e) => TaskModel.fromJson(e)).toList();
  }
}
