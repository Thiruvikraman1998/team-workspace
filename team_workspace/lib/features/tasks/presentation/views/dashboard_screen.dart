import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_workspace/core/di/global_di_instance.dart';
import 'package:team_workspace/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:team_workspace/features/auth/presentation/bloc/auth_event.dart';
import 'package:team_workspace/features/auth/presentation/bloc/auth_state.dart';
import 'package:team_workspace/features/auth/presentation/views/login_screen.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_list/task_list_bloc.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_list/task_list_event.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_list/task_list_state.dart';
import 'package:team_workspace/features/tasks/presentation/views/task_detail_screen.dart';
import 'package:team_workspace/features/tasks/presentation/views/task_form_screen.dart';
import 'package:team_workspace/features/tasks/presentation/widgets/filter_bar.dart';
import 'package:team_workspace/features/tasks/presentation/widgets/task_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<TaskListBloc>()..add(const TaskListEvent.started())),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<TaskListBloc>().add(const TaskListEvent.nextPageRequested());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthBloc>().add(const AuthEvent.logoutRequested()),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final created = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TaskFormScreen()),
            );
            if (created != null && context.mounted) {
              context.read<TaskListBloc>().add(TaskListEvent.taskUpserted(created));
            }
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) =>
                    context.read<TaskListBloc>().add(TaskListEvent.searchChanged(value)),
                decoration: InputDecoration(
                  hintText: 'Search tasks by title',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            BlocBuilder<TaskListBloc, TaskListState>(
              buildWhen: (p, c) => p.statusFilter != c.statusFilter || p.priorityFilter != c.priorityFilter,
              builder: (context, state) {
                return FilterBar(
                  statusFilter: state.statusFilter,
                  priorityFilter: state.priorityFilter,
                  onStatusChanged: (v) =>
                      context.read<TaskListBloc>().add(TaskListEvent.statusFilterChanged(v)),
                  onPriorityChanged: (v) =>
                      context.read<TaskListBloc>().add(TaskListEvent.priorityFilterChanged(v)),
                );
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<TaskListBloc, TaskListState>(
                builder: (context, state) {
                  if (state.isInitialLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == TaskListStatus.failure) {
                    return _ErrorView(
                      message: state.errorMessage ?? 'Something went wrong',
                      onRetry: () => context.read<TaskListBloc>().add(const TaskListEvent.refreshRequested()),
                    );
                  }
                  if (state.status == TaskListStatus.empty) {
                    return _EmptyView(
                      onRefresh: () => context.read<TaskListBloc>().add(const TaskListEvent.refreshRequested()),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<TaskListBloc>().add(const TaskListEvent.refreshRequested());
                      await Future.delayed(const Duration(milliseconds: 600));
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.tasks.length + (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.tasks.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final task = state.tasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () async {
                            final updated = await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
                            );
                            if (updated != null && context.mounted) {
                              context.read<TaskListBloc>().add(TaskListEvent.taskUpserted(updated));
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('No tasks found'),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRefresh, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }
}
