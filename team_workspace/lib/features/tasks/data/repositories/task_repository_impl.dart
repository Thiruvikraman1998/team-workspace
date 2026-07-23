import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/features/tasks/data/remote_datasources/task_remote_datasource.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDatasource _datasource;

  TaskRepositoryImpl(this._datasource);

  @override
  Future<Result<List<TasksEntity>>> getTasks({
    Map<String, dynamic>? queryParam,
  }) async {
    try {
      final result = await _datasource.getTasks(queryParams: queryParam);

      log(result.map((e) => e.toEntity()).toString());

      return SuccessResult(data: result.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return FailureResult(errorMessage: "Failed to fetch tasks :$e");
    } catch (e) {
      return FailureResult(errorMessage: e.toString());
    }
  }
}
