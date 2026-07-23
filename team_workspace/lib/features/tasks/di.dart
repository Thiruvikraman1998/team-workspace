import 'package:team_workspace/core/global_di_instance.dart';
import 'package:team_workspace/core/network/api_client.dart';
import 'package:team_workspace/features/tasks/data/remote_datasources/task_remote_datasource.dart';
import 'package:team_workspace/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:team_workspace/features/tasks/domain/repositories/task_repository.dart';

void setupTaskDi() {
  getIt.registerLazySingleton<TaskRemoteDatasource>(() {
    return TaskRemoteDatasourceImpl(getIt.get<ApiClient>());
  });

  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(getIt<TaskRemoteDatasource>()),
  );
}
