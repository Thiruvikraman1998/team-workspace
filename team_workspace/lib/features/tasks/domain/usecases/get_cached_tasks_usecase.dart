import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/repositories/task_repository.dart';

class GetCachedTasksUsecase {
  final TaskRepository _repository;

  GetCachedTasksUsecase(this._repository);

  Future<List<TasksEntity>> call() {
    return _repository.getCachedTasks();
  }
}
