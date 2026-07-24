import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/core/usecase/usecase.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/repositories/task_repository.dart';

class GetTaskByIdUsecase implements UseCase<TasksEntity, String> {
  final TaskRepository _repository;

  GetTaskByIdUsecase(this._repository);

  @override
  Future<Result<TasksEntity>> call(String taskId) {
    return _repository.getTaskById(taskId);
  }
}
