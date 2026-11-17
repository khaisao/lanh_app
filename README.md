# Lanh

Flutter application with a local Dart workspace. Open this directory in Android
Studio; `packages/app_ui` supplies the theme and shared UI components used by
the app. No parent monorepo or unpublished external packages are required.

## Development

Requires Flutter 3.50.0 or later with Dart 3.14, Android SDK 37, and the Android SDK/JDK configured
for Flutter. Select your Flutter SDK in Android Studio's Flutter settings.

Run from this directory:

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

For an Android emulator or connected phone:

Use an x86_64 Android system image for an emulator on this Windows machine.
The configured Flutter SDK reports 32-bit x86 Android devices as unsupported.
Select the supported device in Android Studio or use its ID from `flutter devices`.

```sh
flutter devices
flutter run -d <device-id>
flutter test integration_test/app_smoke_test.dart -d <device-id>
```

`pubspec.lock` pins application dependencies and should be committed. SDKs,
download caches, and machine-specific IDE settings are excluded from Git.

See [meal photo flow and device checks](docs/meal-photo.md) for the camera and photo library behavior.
