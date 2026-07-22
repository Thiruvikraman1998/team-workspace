import 'package:flutter/material.dart';
import 'package:team_workspace/features/auth/presentation/views/login_screen.dart';

class TeamWorkSpace extends StatelessWidget {
  const TeamWorkSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Team Work Space",
      theme: ThemeData(),
      home: const LoginScreen(),
    );
  }
}
