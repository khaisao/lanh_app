import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final directory = Platform.environment['LANH_DEVICE_CAPTURE_DIR'];
  if (directory == null) {
    throw ArgumentError(
      'Set LANH_DEVICE_CAPTURE_DIR to save device screenshots.',
    );
  }
  await Directory(directory).create(recursive: true);
  await integrationDriver(
    onScreenshot: (name, bytes, [arguments]) async {
      await File('$directory/$name.png').writeAsBytes(bytes);
      return true;
    },
    responseDataCallback: (_) async {},
  );
}
