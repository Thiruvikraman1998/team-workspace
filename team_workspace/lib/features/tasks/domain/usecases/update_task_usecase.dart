import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/core/usecase/usecase.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/repositories/task_repository.dart';

class UpdateTaskUsecase implements UseCase<TasksEntity, TasksEntity> {
  final TaskRepository _repository;

  UpdateTaskUsecase(this._repository);

  @override
  Future<Result<TasksEntity>> call(TasksEntity params) {
    return _repository.updateTask(params);
  }
}
