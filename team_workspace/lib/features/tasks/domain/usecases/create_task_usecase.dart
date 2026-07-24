import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/core/usecase/usecase.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/repositories/task_repository.dart';

class CreateTaskUsecase implements UseCase<TasksEntity, TasksEntity> {
  final TaskRepository _repository;

  CreateTaskUsecase(this._repository);

  @override
  Future<Result<TasksEntity>> call(TasksEntity params) {
    return _repository.createTask(params);
  }
}
