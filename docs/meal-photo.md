# Ảnh bữa ăn

Từ **Hôm nay → Ghi bữa ăn → Chụp ảnh**, Lành đóng bảng chọn cách ghi bữa ăn trước khi mở camera. Nếu đã được cấp quyền, camera mở ngay sau khi bảng chọn đóng hoàn toàn. Khi cần cấp quyền, người dùng có thể đọc giải thích, chọn cấp quyền hoặc mở trình chọn ảnh của hệ điều hành. Nếu quyền bị hạn chế hoặc camera không mở được, vẫn có thể chọn ảnh. Khi hệ điều hành chặn hỏi lại, màn giải thích liên kết đến Cài đặt của ứng dụng.

Ảnh chụp hoặc chọn đều mở màn xem lại. Có thể chụp lại, chọn ảnh khác hoặc quay lại màn đã mở ảnh. Lành đọc bản sao tạm của ảnh, dọn tệp sau khi đọc và giữ nội dung ảnh trong bộ nhớ trong phiên xem lại. Android có thể khôi phục ảnh đang chọn khi hệ điều hành khởi động lại app. **Ước lượng bữa ăn** hiện thông báo chưa khả dụng.

Màn chụp mở như một tác vụ toàn màn hình với hiệu ứng điều hướng của nền tảng. Camera bắt đầu sau khi route đã vào hẳn và app đang foreground. Khi app rời foreground hoặc đóng màn, phiên camera được giải phóng. Kết quả từ phiên cũ được bỏ qua.

Khi bấm chụp, nút hiện tiến trình và dòng Đang chụp ảnh. Nếu camera không trả kết quả sau 15 giây, app báo lỗi và tạo lại phiên camera để có thể thử lại hoặc chọn ảnh. Ảnh được kiểm tra và làm nóng bộ nhớ đệm hiển thị trước khi chuyển sang xem lại. Chiều rộng giải mã được giới hạn ở 2048 pixel, byte ảnh gốc được giữ trong luồng.

Nút đổi camera nằm bên phải nút chụp, dùng icon `ph:camera-rotate` trong mẫu CameraPreview. Nút chỉ xuất hiện khi thiết bị có cả camera trước và sau. Khi đổi, app giải phóng phiên cũ trước khi mở hướng camera mới, hiện tiến trình và khóa các thao tác chụp, chọn ảnh, đổi tiếp. Hướng đã chọn được giữ khi chụp lại hoặc trở về từ nền. Nếu mở hướng mới thất bại, app thử mở lại hướng cũ và báo lỗi để có thể tiếp tục chụp.

Android bật Photo Picker khi nền tảng hỗ trợ. iOS dùng trình chọn với requestFullMetadata false. Việc khôi phục ảnh được kiểm tra khi app vào foreground và được phối hợp với luồng đang mở để tránh đọc hoặc xóa cùng một ảnh hai lần. Android có thể dựng lại Flutter trước khi người dùng chọn xong ảnh, nên việc khôi phục cũng được kiểm tra ở lần resume sau.

Plugin Android có thể hoàn tất sao chép ảnh sau callback resume. Khi chưa có kết quả, app kiểm tra lại tối đa 30 lần, cách nhau 500 ms. Các kiểm tra dừng khi app rời foreground, mở luồng ảnh hoặc hết khoảng kiểm tra. Nền tảng không hỗ trợ khôi phục bỏ qua bước này.

## Kiểm tra trên thiết bị

- Kiểm tra quyền camera lần đầu, từ chối, mở Cài đặt để cấp lại, và vào thẳng camera sau khi đã cho phép.
- Chụp và xem ảnh, chụp lại, đưa app về nền rồi mở lại. Kiểm tra nút Đóng quay lại bảng chọn cách ghi bữa ăn.
- Mở thư viện từ hai màn, hủy chọn, chọn ảnh, chọn ảnh khác và quay lại đúng màn trước đó. Xác nhận không hiện yêu cầu quyền đọc cả thư viện.
- Trên Android, kiểm tra trình chọn ảnh ở phiên bản cũ nhất app hỗ trợ và Android 13 trở lên. Trên iPhone, kiểm tra ảnh HEIC và trường hợp camera bị giới hạn bởi hệ thống.

Nếu camera virtual scene trên emulator phát log Camera3-Stream với timestamp âm lặp lại và chụp không trả kết quả, chuyển camera sau của AVD sang Emulated. Cấu hình Medium Phone API 33 (x86_64) trên máy phát triển đã được chuyển theo cách này sau khi tái hiện lỗi. Đây là cấu hình thiết bị giả lập.

## Cấu hình iOS

Ứng dụng dùng Swift Package Manager và đặt phiên bản iOS tối thiểu là 15.0. `ios/Runner/Info.plist` chứa mô tả quyền camera và thư viện. Camera khởi tạo với `enableAudio: false` vì luồng chỉ chụp ảnh.

Với `permission_handler_apple` đang khóa trong `pubspec.lock`, manifest của package nhận diện quyền camera từ `NSCameraUsageDescription`. Khi có máy Mac, chạy lệnh Flutter từ thư mục gốc dự án để package tìm được cấu hình ứng dụng. Nếu build trực tiếp từ Xcode.app, package yêu cầu biến môi trường `PERMISSION_HANDLER_INFO_PLIST` trỏ đến đường dẫn tuyệt đối của `ios/Runner/Info.plist`; xem phần hướng dẫn trong `ios/permission_handler_apple/Package.swift` của dependency. Cần kiểm tra hộp thoại quyền và thao tác trở lại từ Cài đặt trên thiết bị sau khi build.
