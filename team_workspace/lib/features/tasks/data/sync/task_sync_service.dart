import 'dart:async';
import 'dart:developer';

import 'package:team_workspace/core/network/network_info.dart';
import 'package:team_workspace/features/tasks/data/local_datasources/task_local_datasource.dart';
import 'package:team_workspace/features/tasks/data/remote_datasources/task_remote_datasource.dart';

/// Watches connectivity and flushes the `pending_actions` queue (tasks
/// created/edited while offline) back to the REST API once the device is
/// back online. This is the "bonus" offline-sync requirement.
class TaskSyncService {
  final TaskLocalDatasource _localDatasource;
  final TaskRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  StreamSubscription<bool>? _subscription;
  bool _isSyncing = false;

  TaskSyncService(this._localDatasource, this._remoteDatasource, this._networkInfo);

  void start() {
    _subscription = _networkInfo.onConnectivityChanged.listen((isConnected) {
      if (isConnected) syncPendingActions();
    });
    // also attempt an immediate sync on startup in case connectivity was
    // already restored before the app launched.
    syncPendingActions();
  }

  Future<void> syncPendingActions() async {
    if (_isSyncing) return;
    if (!await _networkInfo.isConnected) return;

    _isSyncing = true;
    try {
      final pending = await _localDatasource.getPendingActions();
      for (final action in pending) {
        try {
          switch (action.type) {
            case PendingActionType.create:
              final created = await _remoteDatasource.createTask(action.task);
              await _localDatasource.upsertTask(created, isSynced: true);
            case PendingActionType.update:
              final updated = await _remoteDatasource.updateTask(action.task);
              await _localDatasource.upsertTask(updated, isSynced: true);
          }
          await _localDatasource.removePendingAction(action.id);
        } catch (e) {
          // leave it queued, try again on next connectivity event
          log('Sync failed for pending action ${action.id}: $e');
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
