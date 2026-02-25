import 'package:flutter/material.dart';

import 'app/app.dart';
import 'di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const GuardianesApp());
}
