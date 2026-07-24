import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:team_workspace/core/di/global_di_instance.dart';
import 'package:team_workspace/core/mocks/assigned_user_mock.dart';
import 'package:team_workspace/core/utils/validators.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_form/task_form_bloc.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_form/task_form_event.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_form/task_form_state.dart';

class TaskFormScreen extends StatelessWidget {
  final TasksEntity? existingTask;
  const TaskFormScreen({super.key, this.existingTask});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskFormBloc>(param1: existingTask),
      child: _TaskFormView(existingTask: existingTask),
    );
  }
}

class _TaskFormView extends StatefulWidget {
  final TasksEntity? existingTask;
  const _TaskFormView({this.existingTask});

  @override
  State<_TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends State<_TaskFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskPriority _priority;
  late TaskStatus _status;
  late String _asignedUser;
  DateTime? _dueDate;

  bool get isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _priority = task?.priorityEnum ?? TaskPriority.medium;
    _status = task?.statusEnum ?? TaskStatus.pending;
    _asignedUser = task?.assignedUser ?? 'You';
    _dueDate = task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit(BuildContext context) {
    if (_dueDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please choose a due date')));
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      context.read<TaskFormBloc>().add(
        TaskFormEvent.submitted(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _priority,
          status: _status,
          dueDate: _dueDate!,
          assignedUser: _asignedUser,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Task' : 'Create Task')),
      body: BlocConsumer<TaskFormBloc, TaskFormState>(
        listener: (context, state) {
          if (state is TaskFormSuccess) {
            Navigator.of(context).pop(state.task);
          } else if (state is TaskFormFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isSubmitting = state is TaskFormSubmitting;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => Validators.required(v, field: 'Title'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          Validators.required(v, field: 'Description'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskPriority>(
                      initialValue: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: TaskPriority.values
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _priority = v ?? _priority),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<TaskStatus>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: TaskStatus.values
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _status = v ?? _status),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _dueDate != null
                              ? DateFormat('MMMM d, yyyy').format(_dueDate!)
                              : 'Select a date',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _asignedUser,
                      decoration: const InputDecoration(
                        labelText: 'Assigned to',
                        border: OutlineInputBorder(),
                      ),
                      items: assignedUserMock
                          .map(
                            (s) => DropdownMenuItem<String>(
                              value: s['name'],
                              child: Text(s['name']),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _asignedUser = v ?? _asignedUser),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : () => _submit(context),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(isEditing ? 'Save changes' : 'Create task'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
