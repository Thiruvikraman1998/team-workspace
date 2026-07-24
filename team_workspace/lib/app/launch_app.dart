import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_workspace/core/di/global_di_instance.dart';
import 'package:team_workspace/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:team_workspace/features/auth/presentation/bloc/auth_event.dart';
import 'package:team_workspace/features/auth/presentation/bloc/auth_state.dart';
import 'package:team_workspace/features/auth/presentation/views/login_screen.dart';
import 'package:team_workspace/features/tasks/presentation/views/dashboard_screen.dart';

class TeamWorkSpace extends StatelessWidget {
  const TeamWorkSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Team Work Space",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black),
        colorSchemeSeed: Colors.indigo,
      ),
      home: const _SessionGate(),
    );
  }
}

/// Restores the persisted session (Firebase Auth, falling back to the
/// sqflite-cached session for offline restarts) before deciding whether to
/// show the login screen or the dashboard.
class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(const AuthEvent.checkSessionRequested()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return switch (state) {
            AuthAuthenticated() => const DashboardScreen(),
            AuthUnauthenticated() || AuthFailure() => const LoginScreen(),
            _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
          };
        },
      ),
    );
  }
}
