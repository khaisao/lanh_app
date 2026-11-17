# Kiểm tra luồng ảnh bữa ăn

Ba màn đã nối vào mục Chụp ảnh từ bảng chọn ghi bữa ăn. Giao diện dùng token, typography, assets và nút trong app_ui. Các thành phần bổ sung gồm nút mặt thẻ trong suốt, lớp phủ ảnh, mặt kính và token từ ba HTML được gửi.

## Kiểm tra tự động

- dart format đã chạy cho các tệp Dart của thay đổi.
- flutter analyze hoàn tất với 0 vấn đề.
- flutter test hoàn tất với 62 bài qua.
- Bốn kích thước 320×700, 360×800, 390×844 và 430×932 đều kiểm tra luồng chụp, xem lại, thông báo AI và chụp lại.
- Cỡ chữ 200% tại 320×700 được kiểm tra với cấu hình giao diện Android và iOS.
- Các nhánh từ chối quyền, quyền bị hạn chế, mở Cài đặt, lỗi chọn ảnh, hủy chọn ảnh, quay về đúng nguồn, khôi phục ảnh đang chọn và vòng đời camera có bài kiểm tra.
- Bản APK debug android-x64 biên dịch thành công với compileSdk 37. Thư viện liquid_glass_shader hiện có phát cảnh báo về shader khi biên dịch trên Windows.

## Kiểm tra trực tiếp

Android 13 API 33 x86_64, cấu hình Pixel 5, chạy APK thật qua Home.

| Trường hợp | Kết quả |
| --- | --- |
| Mở Chụp ảnh khi chưa cấp quyền | Hiện màn giải thích, hộp thoại hệ thống xuất hiện sau khi bấm Cho phép camera |
| Từ chối lần đầu | Hiện hướng dẫn và giữ lựa chọn thư viện |
| Từ chối lần hai | Hiện Mở Cài đặt, mở được trang cài đặt ứng dụng |
| Cấp lại quyền trong Cài đặt | Mở lại luồng vào camera trực tiếp |
| Chọn ảnh khi camera bị từ chối | Mở trình chọn của hệ điều hành và xem được ảnh đã chọn |
| Hủy trình chọn | Quay về màn đã mở trình chọn |
| Chụp và chụp lại | Xem được ảnh từ camera emulator và mở lại camera |
| Đưa app về nền rồi quay lại | Camera tiếp tục chụp và mở màn xem lại được |
| Bấm Ước lượng bữa ăn | Hiện hộp thoại chưa khả dụng, đóng thông báo giữ ảnh |
| Đóng camera | Quay lại bảng chọn cách ghi bữa ăn |
| Dọn ảnh | Sau khi đọc ảnh, thư mục cache của ứng dụng trống. Ảnh nguồn trong Pictures vẫn tồn tại |

Đã đối chiếu HTML và ảnh chụp giao diện Flutter. Manifest Android sau khi hợp nhất chỉ giữ quyền camera cho luồng ảnh. Camera sử dụng enableAudio false. iOS khai báo mô tả camera và thư viện, trình chọn được gọi với requestFullMetadata false.

## Phần cần môi trường bổ sung

Chưa chạy trên điện thoại Android thật hoặc iPhone. Chưa biên dịch bằng Xcode. HEIC, quyền iOS và vòng đời camera iOS cần xác nhận trên iPhone. Các bài kiểm tra giao diện với cấu hình iOS chạy bằng Flutter trên Windows.

Emulator thử nghiệm đã tắt và đăng ký AVD đã được gỡ. Công cụ duyệt tự động chặn lệnh xóa thư mục tạm còn lại tại build/lanh-photo-api33.avd, với lý do chung blocked by policy. Thư mục này có thể được dọn cùng dữ liệu build.
