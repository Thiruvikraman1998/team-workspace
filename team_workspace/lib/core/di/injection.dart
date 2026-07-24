import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:team_workspace/core/database/app_database.dart';
import 'package:team_workspace/core/di/global_di_instance.dart';
import 'package:team_workspace/core/network/network_info.dart';
import 'package:team_workspace/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:team_workspace/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:team_workspace/features/auth/domain/repositories/auth_repository.dart';
import 'package:team_workspace/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:team_workspace/features/auth/domain/usecases/login_usecase.dart';
import 'package:team_workspace/features/auth/domain/usecases/logout_usecase.dart';
import 'package:team_workspace/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:team_workspace/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:team_workspace/features/tasks/data/local_datasources/task_local_datasource.dart';
import 'package:team_workspace/features/tasks/data/remote_datasources/task_remote_datasource.dart';
import 'package:team_workspace/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:team_workspace/features/tasks/data/sync/task_sync_service.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/repositories/task_repository.dart';
import 'package:team_workspace/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:team_workspace/features/tasks/domain/usecases/get_cached_tasks_usecase.dart';
import 'package:team_workspace/features/tasks/domain/usecases/get_task_by_id_usecase.dart';
import 'package:team_workspace/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:team_workspace/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_detail/task_detail_bloc.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_form/task_form_bloc.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_list/task_list_bloc.dart';

/// Registers every dependency used across the app. Called once from main
/// after setupNetworkModule and Firebase have been initialized.
Future<void> setupInjection() async {
  // --- Core -----------------------------------------------------------
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // --- Auth feature 
  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton(() => SignUpUsecase(getIt()));
  getIt.registerLazySingleton(() => LoginUsecase(getIt()));
  getIt.registerLazySingleton(() => LogoutUsecase(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUserUsecase(getIt()));
  getIt.registerFactory(
    () => AuthBloc(
      signUpUsecase: getIt(),
      loginUsecase: getIt(),
      logoutUsecase: getIt(),
      getCurrentUserUsecase: getIt(),
    ),
  );

  // --- Tasks feature 
  getIt.registerLazySingleton<TaskRemoteDatasource>(
    () => TaskRemoteDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<TaskLocalDatasource>(
    () => TaskLocalDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton(() => GetTasksUsecase(getIt()));
  getIt.registerLazySingleton(() => GetCachedTasksUsecase(getIt()));
  getIt.registerLazySingleton(() => GetTaskByIdUsecase(getIt()));
  getIt.registerLazySingleton(() => CreateTaskUsecase(getIt()));
  getIt.registerLazySingleton(() => UpdateTaskUsecase(getIt()));

  getIt.registerFactory(
    () => TaskListBloc(getTasksUsecase: getIt(), getCachedTasksUsecase: getIt()),
  );
  getIt.registerFactoryParam<TaskDetailBloc, TasksEntity, void>(
    (task, _) => TaskDetailBloc(updateTaskUsecase: getIt(), initialTask: task),
  );
  getIt.registerFactoryParam<TaskFormBloc, TasksEntity?, void>(
    (existingTask, _) => TaskFormBloc(
      createTaskUsecase: getIt(),
      updateTaskUsecase: getIt(),
      existingTask: existingTask,
    ),
  );

  getIt.registerLazySingleton<TaskSyncService>(
    () => TaskSyncService(getIt(), getIt(), getIt()),
  );
}
