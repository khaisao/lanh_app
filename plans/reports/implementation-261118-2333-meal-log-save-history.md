# Implementation report: lưu bữa ăn và lịch sử hôm nay

## Kết quả
- Nút Lưu trên kết quả phân tích hoạt động cho cả photo và voice.
- Meal và meal items được ghi trong một transaction SQLite version 1.
- Ảnh được sao chép vào thư mục dữ liệu cục bộ; lỗi sao chép không làm mất bản ghi.
- Home đọc bản ghi của ngày hiện tại theo giờ thiết bị, mới nhất trước, hiển thị ảnh hoặc icon mặc định.
- Build/test có thể bật `LANH_USE_FAKE_MEAL_ANALYSIS=true`; production không tự dùng dữ liệu giả khi server lỗi.

## Files chính
- `lib/features/meal_logging/domain/meal_log.dart`
- `lib/features/meal_logging/domain/meal_log_repository.dart`
- `lib/features/meal_logging/data/sqlite_meal_log_repository.dart`
- `lib/features/meal_logging/data/fake_meal_analysis_repository.dart`
- `lib/features/meal_logging/meal_logging_providers.dart`
- `lib/features/today/presentation/today_screen.dart`
- `integration_test/meal_save_fake_test.dart`

## Validation
- `flutter analyze` — pass.
- `flutter test` — 155 tests pass.
- `flutter test test/meal_log_test.dart test/meal_photo_flow_test.dart` — pass.
- `flutter build apk --debug` — pass.
- `flutter test integration_test/meal_save_fake_test.dart -d emulator-5554 --dart-define=LANH_USE_FAKE_MEAL_ANALYSIS=true` — pass trên Android 13 API 33 emulator; kiểm tra lưu ảnh, SQLite persistence, duplicate tap guard, date filter và Home history.
- `flutter test integration_test/app_smoke_test.dart -d emulator-5554 --dart-define=LANH_USE_FAKE_MEAL_ANALYSIS=true` — pass sau khi cài lại APK.

## Backup
Trước khi chạy integration test, dữ liệu database của app trên emulator được backup tại `build/backups/lanh-db-before-meal-261118-2350.tar`.

## Lưu ý
- Các test có cảnh báo hit-test vốn đã tồn tại ở luồng camera, nhưng không có test nào thất bại.
- Emulator được dùng là `emulator-5554` (Android 13/API 33). Không có thiết bị Android vật lý kết nối.
