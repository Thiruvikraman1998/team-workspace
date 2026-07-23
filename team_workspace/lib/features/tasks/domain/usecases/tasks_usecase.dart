import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/repositories/task_repository.dart';

class TasksUsecase {
  final TaskRepository _taskRepository;

  TasksUsecase(this._taskRepository);

  Future<Result<List<TasksEntity>>> call(Map<String, dynamic> queryParams) {
    return _taskRepository.getTasks();
  }
}
