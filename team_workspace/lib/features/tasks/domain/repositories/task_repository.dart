import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';

abstract class TaskRepository {
  Future<Result<List<TasksEntity>>> getTasks({
    Map<String, dynamic>? queryParam,
  });
}
