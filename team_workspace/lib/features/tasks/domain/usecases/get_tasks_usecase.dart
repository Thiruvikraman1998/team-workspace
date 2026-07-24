import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/core/usecase/usecase.dart';
import 'package:team_workspace/features/tasks/domain/repositories/task_repository.dart';

class GetTasksUsecase implements UseCase<PaginatedTasks, TaskQueryParams> {
  final TaskRepository _repository;

  GetTasksUsecase(this._repository);

  @override
  Future<Result<PaginatedTasks>> call(TaskQueryParams params) {
    return _repository.getTasks(params);
  }
}
