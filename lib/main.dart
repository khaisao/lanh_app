import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/app/app.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  binding.deferFirstFrame();
  runApp(const ProviderScope(child: Application()));
  unawaited(AppBackground.preload().whenComplete(binding.allowFirstFrame));
}
