# Lanh

Flutter application with a local Dart workspace. Open this directory in Android
Studio; `packages/app_ui` supplies the theme and shared UI components used by
the app. No parent monorepo or unpublished external packages are required.

## Development

Requires Flutter 3.50.0 or later with Dart 3.14, and the Android SDK/JDK configured
for Flutter. Select your Flutter SDK in Android Studio's Flutter settings.

Run from this directory:

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

For an Android emulator or connected phone:

```sh
flutter run
flutter test integration_test/app_smoke_test.dart -d <device-id>
```

`pubspec.lock` pins application dependencies and should be committed. SDKs,
download caches, and machine-specific IDE settings are excluded from Git.
