import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:team_workspace/core/database/app_database.dart';
import 'package:team_workspace/features/tasks/data/models/task_model.dart';

enum PendingActionType { create, update }

class PendingAction {
  final String id;
  final PendingActionType type;
  final TaskModel task;

  const PendingAction({required this.id, required this.type, required this.task});
}

abstract class TaskLocalDatasource {
  Future<void> cacheTasks(List<TaskModel> tasks, {bool clearExisting = false});
  Future<List<TaskModel>> getCachedTasks({
    String? search,
    String? statusFilter,
    String? priorityFilter,
  });
  Future<void> upsertTask(TaskModel task, {bool isSynced = true});
  Future<TaskModel?> getTaskByLocalId(String localId);

  Future<void> enqueuePendingAction(PendingActionType type, TaskModel task);
  Future<List<PendingAction>> getPendingActions();
  Future<void> removePendingAction(String id);
}

class TaskLocalDatasourceImpl implements TaskLocalDatasource {
  final AppDatabase _database;

  TaskLocalDatasourceImpl(this._database);

  @override
  Future<void> cacheTasks(List<TaskModel> tasks, {bool clearExisting = false}) async {
    final db = await _database.database;
    final batch = db.batch();
    if (clearExisting) {
      batch.delete('tasks');
    }
    for (final task in tasks) {
      batch.insert('tasks', task.toDbMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<TaskModel>> getCachedTasks({
    String? search,
    String? statusFilter,
    String? priorityFilter,
  }) async {
    final db = await _database.database;
    final where = <String>[];
    final args = <dynamic>[];

    if (search != null && search.trim().isNotEmpty) {
      where.add('title LIKE ?');
      args.add('%${search.trim()}%');
    }
    if (statusFilter != null && statusFilter.isNotEmpty) {
      where.add('status = ?');
      args.add(statusFilter);
    }
    if (priorityFilter != null && priorityFilter.isNotEmpty) {
      where.add('priority = ?');
      args.add(priorityFilter);
    }

    final rows = await db.query(
      'tasks',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'created_at DESC',
    );

    return rows.map(TaskModel.fromDbMap).toList();
  }

  @override
  Future<void> upsertTask(TaskModel task, {bool isSynced = true}) async {
    final db = await _database.database;
    await db.insert(
      'tasks',
      task.toDbMap(isSynced: isSynced),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<TaskModel?> getTaskByLocalId(String localId) async {
    final db = await _database.database;
    final rows = await db.query('tasks', where: 'id = ?', whereArgs: [localId], limit: 1);
    if (rows.isEmpty) return null;
    return TaskModel.fromDbMap(rows.first);
  }

  @override
  Future<void> enqueuePendingAction(PendingActionType type, TaskModel task) async {
    final db = await _database.database;
    await db.insert('pending_actions', {
      'id': task.taskId ?? task.id?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      'action_type': type.name,
      'payload': jsonEncode(task.toJson()),
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<PendingAction>> getPendingActions() async {
    final db = await _database.database;
    final rows = await db.query('pending_actions', orderBy: 'created_at ASC');
    return rows.map((row) {
      final payload = jsonDecode(row['payload'] as String) as Map<String, dynamic>;
      return PendingAction(
        id: row['id'] as String,
        type: PendingActionType.values.byName(row['action_type'] as String),
        task: TaskModel.fromJson(payload),
      );
    }).toList();
  }

  @override
  Future<void> removePendingAction(String id) async {
    final db = await _database.database;
    await db.delete('pending_actions', where: 'id = ?', whereArgs: [id]);
  }
}
