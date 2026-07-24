import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:team_workspace/app/launch_app.dart';
import 'package:team_workspace/core/di/global_di_instance.dart';
import 'package:team_workspace/core/di/injection.dart';
import 'package:team_workspace/core/network/setup_network_module.dart';
import 'package:team_workspace/features/tasks/data/sync/task_sync_service.dart';
import 'package:team_workspace/firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  setupNetworkModule(
    baseUrl: 'https://yqjyztrzxhscxvauerfw.supabase.co/rest/v1/',
  );

  await setupInjection();

  // start listening for connectivity changes so offline edits sync back
  // automatically once the device reconnects.
  getIt<TaskSyncService>().start();

  runApp(const TeamWorkSpace());
}