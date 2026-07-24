import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
sealed class TaskModel with _$TaskModel {
  const TaskModel._();

  const factory TaskModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'task_id') String? taskId,
    @JsonKey(name: 'title') String? title,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'priority') String? priority,
    @JsonKey(name: 'current_status') String? status,
    @JsonKey(name: 'assigned_user') String? assignedUser,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  /// Builds the JSON body used for create/update REST calls. `id`/`created_at`
  /// are omitted since they are server generated.
  Map<String, dynamic> toRequestJson() => {
    if (id != null) 'id': id,
    'task_id': taskId,
    'title': title,
    'description': description,
    'priority': priority,
    'current_status': status,
    'assigned_user': assignedUser,
    'due_date': dueDate?.toIso8601String(),
  };

  factory TaskModel.fromEntity(TasksEntity entity) => TaskModel(
    id: entity.id,
    taskId: entity.taskId,
    title: entity.title,
    description: entity.description,
    priority: entity.priority,
    status: entity.status,
    assignedUser: entity.assignedUser,
    dueDate: entity.dueDate,
    createdAt: entity.createdAt,
  );

  TasksEntity toEntity() {
    return TasksEntity(
      id: id,
      taskId: taskId,
      title: title,
      description: description,
      priority: priority,
      status: status,
      assignedUser: assignedUser,
      dueDate: dueDate,
      createdAt: createdAt,
    );
  }

  /// --- sqflite (de)serialization -------------------------------------
  Map<String, dynamic> toDbMap({bool isSynced = true}) => {
    'id': taskId ?? id?.toString() ?? UniqueKeyFallback.next(),
    'remote_id': id,
    'task_id': taskId,
    'title': title,
    'description': description,
    'priority': priority,
    'status': status,
    'assigned_user': assignedUser,
    'due_date': dueDate?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
    'is_synced': isSynced ? 1 : 0,
  };

  factory TaskModel.fromDbMap(Map<String, dynamic> map) => TaskModel(
    id: map['remote_id'] as int?,
    taskId: map['task_id'] as String?,
    title: map['title'] as String?,
    description: map['description'] as String?,
    priority: map['priority'] as String?,
    status: map['status'] as String?,
    assignedUser: map['assigned_user'] as String?,
    dueDate: map['due_date'] != null
        ? DateTime.tryParse(map['due_date'] as String)
        : null,
    createdAt: map['created_at'] != null
        ? DateTime.tryParse(map['created_at'] as String)
        : null,
  );
}

/// Small helper to generate a locally-unique id for tasks created offline
/// (before they get a real server id assigned during sync).
class UniqueKeyFallback {
  static int _counter = 0;
  static String next() =>
      'local_${DateTime.now().microsecondsSinceEpoch}_${_counter++}';
}
