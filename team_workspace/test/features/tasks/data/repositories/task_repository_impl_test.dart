import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/core/network/network_info.dart';
import 'package:team_workspace/features/tasks/data/local_datasources/task_local_datasource.dart';
import 'package:team_workspace/features/tasks/data/models/task_model.dart';
import 'package:team_workspace/features/tasks/data/remote_datasources/task_remote_datasource.dart';
import 'package:team_workspace/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/repositories/task_repository.dart';

class MockTaskRemoteDatasource extends Mock implements TaskRemoteDatasource {}
class MockTaskLocalDatasource extends Mock implements TaskLocalDatasource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late TaskRepositoryImpl repository;
  late MockTaskRemoteDatasource mockRemoteDatasource;
  late MockTaskLocalDatasource mockLocalDatasource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDatasource = MockTaskRemoteDatasource();
    mockLocalDatasource = MockTaskLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();
    repository = TaskRepositoryImpl(mockRemoteDatasource, mockLocalDatasource, mockNetworkInfo);
  });

  final tTaskModel = TaskModel(id: 1, title: 'Test Task', status: 'pending', priority: 'low');
  final tTaskEntity = tTaskModel.toEntity();
  const tQueryParams = TaskQueryParams(page: 1, pageSize: 15);

  setUpAll(() {
    registerFallbackValue(tTaskModel);
    registerFallbackValue(PendingActionType.create);
  });

  group('getTasks', () {
    test('should return remote data and cache it when online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDatasource.getTasks(
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
        search: any(named: 'search'),
        statusFilter: any(named: 'statusFilter'),
        priorityFilter: any(named: 'priorityFilter'),
      )).thenAnswer((_) async => [tTaskModel]);
      when(() => mockLocalDatasource.cacheTasks(any(), clearExisting: any(named: 'clearExisting')))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.getTasks(tQueryParams);

      // assert
      expect(result, isA<SuccessResult<PaginatedTasks>>());
      final data = (result as SuccessResult<PaginatedTasks>).data;
      expect(data.tasks, [tTaskEntity]);
      verify(() => mockLocalDatasource.cacheTasks([tTaskModel], clearExisting: true)).called(1);
    });

    test('should return cached data when offline', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocalDatasource.getCachedTasks(
        search: any(named: 'search'),
        statusFilter: any(named: 'statusFilter'),
        priorityFilter: any(named: 'priorityFilter'),
      )).thenAnswer((_) async => [tTaskModel]);

      // act
      final result = await repository.getTasks(tQueryParams);

      // assert
      expect(result, isA<SuccessResult<PaginatedTasks>>());
      final data = (result as SuccessResult<PaginatedTasks>).data;
      expect(data.tasks, [tTaskEntity]);
      verifyZeroInteractions(mockRemoteDatasource);
    });
  });

  group('createTask', () {
    test('should call remote and cache when online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDatasource.createTask(any())).thenAnswer((_) async => tTaskModel);
      when(() => mockLocalDatasource.upsertTask(any(), isSynced: any(named: 'isSynced')))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.createTask(tTaskEntity);

      // assert
      expect(result, isA<SuccessResult<TasksEntity>>());
      verify(() => mockRemoteDatasource.createTask(any())).called(1);
      verify(() => mockLocalDatasource.upsertTask(any(), isSynced: true)).called(1);
    });

    test('should cache locally and enqueue pending action when offline', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocalDatasource.upsertTask(any(), isSynced: any(named: 'isSynced')))
          .thenAnswer((_) async => {});
      when(() => mockLocalDatasource.enqueuePendingAction(any(), any()))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.createTask(tTaskEntity);

      // assert
      expect(result, isA<SuccessResult<TasksEntity>>());
      verify(() => mockLocalDatasource.upsertTask(any(), isSynced: false)).called(1);
      verify(() => mockLocalDatasource.enqueuePendingAction(PendingActionType.create, any())).called(1);
      verifyZeroInteractions(mockRemoteDatasource);
    });
  });
}
