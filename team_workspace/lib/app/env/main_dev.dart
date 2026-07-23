import 'package:flutter/widgets.dart';
import 'package:team_workspace/app/launch_app.dart';
import 'package:team_workspace/core/network/setup_network_module.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupNetworkModule(
    baseUrl: 'https://yqjyztrzxhscxvauerfw.supabase.co/rest/v1/',
  );
  runApp(const TeamWorkSpace());
}
