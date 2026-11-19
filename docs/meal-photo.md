# Ảnh bữa ăn

Từ **Hôm nay → Ghi bữa ăn → Chụp ảnh**, Lành đóng bảng chọn cách ghi bữa ăn trước khi mở camera. Nếu đã được cấp quyền, camera mở ngay sau khi bảng chọn đóng hoàn toàn. Khi cần cấp quyền, người dùng có thể đọc giải thích, chọn cấp quyền hoặc mở trình chọn ảnh của hệ điều hành. Nếu quyền bị hạn chế hoặc camera không mở được, vẫn có thể chọn ảnh. Khi hệ điều hành chặn hỏi lại, màn giải thích liên kết đến Cài đặt của ứng dụng.

Ảnh chụp hoặc chọn đều mở màn xem lại. Có thể chụp lại, chọn ảnh khác hoặc quay lại màn đã mở ảnh. Lành đọc bản sao tạm của ảnh, dọn tệp sau khi đọc và giữ nội dung ảnh trong bộ nhớ trong phiên xem lại. Android có thể khôi phục ảnh đang chọn khi hệ điều hành khởi động lại app.

Màn chụp mở như một tác vụ toàn màn hình với hiệu ứng điều hướng của nền tảng. Camera bắt đầu sau khi route đã vào hẳn và app đang foreground. Khi app rời foreground hoặc đóng màn, phiên camera được giải phóng. Kết quả từ phiên cũ được bỏ qua.

Khi bấm chụp, nút hiện tiến trình và dòng Đang chụp ảnh. Nếu camera không trả kết quả sau 15 giây, app báo lỗi và tạo lại phiên camera để có thể thử lại hoặc chọn ảnh. Ảnh được kiểm tra và làm nóng bộ nhớ đệm hiển thị trước khi chuyển sang xem lại. Chiều rộng giải mã được giới hạn ở 2048 pixel, byte ảnh gốc được giữ trong luồng.

Nút đổi camera nằm bên phải nút chụp, dùng icon `ph:camera-rotate` trong mẫu CameraPreview. Nút chỉ xuất hiện khi thiết bị có cả camera trước và sau. Khi đổi, app giải phóng phiên cũ trước khi mở hướng camera mới, hiện tiến trình và khóa các thao tác chụp, chọn ảnh, đổi tiếp. Hướng đã chọn được giữ khi chụp lại hoặc trở về từ nền. Nếu mở hướng mới thất bại, app thử mở lại hướng cũ và báo lỗi để có thể tiếp tục chụp.

Android bật Photo Picker khi nền tảng hỗ trợ. iOS dùng trình chọn với requestFullMetadata false. Việc khôi phục ảnh được kiểm tra khi app vào foreground và được phối hợp với luồng đang mở để tránh đọc hoặc xóa cùng một ảnh hai lần. Android có thể dựng lại Flutter trước khi người dùng chọn xong ảnh, nên việc khôi phục cũng được kiểm tra ở lần resume sau.

Plugin Android có thể hoàn tất sao chép ảnh sau callback resume. Khi chưa có kết quả, app kiểm tra lại tối đa 30 lần, cách nhau 500 ms. Các kiểm tra dừng khi app rời foreground, mở luồng ảnh hoặc hết khoảng kiểm tra. Nền tảng không hỗ trợ khôi phục bỏ qua bước này.

## Ước lượng bằng meal API

**Ước lượng bữa ăn** gửi ảnh tới `POST /v1/meal-analysis` của `services/meal_api` (multipart `image`, `request_id`). Domain và hợp đồng nằm ở `domain/meal_analysis.dart`, `HttpMealAnalysisRepository` ở `data/`, provider ở `meal_logging_providers.dart`. Widget và controller không biết HTTP.

- Base URL đặt theo bản build: `--dart-define=LANH_MEAL_API_BASE_URL=http://<ip-lan-của-mac>:8080`. Thiếu biến này thì app hiện lỗi "chưa cấu hình", không gọi mạng. Không đặt địa chỉ Ollama vào app.
- Ảnh JPEG/PNG/WebP đến 4 MB được gửi nguyên. Ảnh lớn hơn hoặc định dạng khác (HEIC) được giải mã bằng codec nền tảng và mã hóa lại PNG, cạnh dài tối đa 1600 px.
- Mỗi ảnh có một `request_id` ổn định cho các lần thử lại. Hủy, Back hoặc đóng luồng sẽ hủy request và bỏ qua kết quả đến muộn. Timeout phía app là 90 giây.
- Lỗi RFC 9457 được ánh xạ thành loại lỗi domain: không thấy món (`food_not_identified`, danh sách rỗng), ảnh không hợp lệ, mất mạng, máy chủ bận/timeout, chưa cấu hình. Mỗi loại có thông điệp riêng ở màn Chưa ước lượng được, ảnh vẫn được giữ.
- Kết quả mở màn **Kiểm tra bữa ăn** theo bản MealReview kính mờ (18/11/2026): nút kính quay lại/đóng, ảnh hero có nhãn số món và tên bữa ghép từ tên các món, card Tổng năng lượng với nhãn Ước tính và bộ chọn Nửa phần/1 phần/1,5 phần dạng pill, card Chất dinh dưỡng với thanh tỷ lệ đạm/tinh bột/chất béo theo gam và ba ô có icon, danh sách món với khẩu phần, kcal và chip macro, ghi chú kèm mascot, thanh hành động nổi. Giá trị thiếu hiện "Chưa rõ", không thành 0; món thiếu kcal được ghi chú là chưa tính vào tổng. Số được làm tròn khi hiển thị theo locale. Các card dùng `AppGlassSurface` trong một `BackdropGroup` để chia sẻ lượt blur khi cuộn; hiệu ứng xuất hiện và thanh macro bị tắt khi bật Giảm chuyển động.
- Nút **Lưu bữa ăn** ghi một bản ghi độc lập vào SQLite cục bộ, gồm thời điểm, nguồn (ảnh hoặc lời kể), khẩu phần đã chọn, tổng dinh dưỡng và từng món. Các món được ghi trong cùng transaction với bản ghi bữa. Sau khi lưu thành công, luồng đóng và Home tải lại nhật ký của ngày hiện tại, sắp xếp bữa mới nhất trước. Ảnh được sao chép vào thư mục dữ liệu của ứng dụng và SQLite chỉ giữ đường dẫn; nếu sao chép ảnh thất bại, bữa vẫn được lưu và Home dùng icon mặc định. Nút lưu khóa trong lúc ghi và báo lỗi để thử lại nếu database gặp sự cố.
- Dữ liệu phân tích giả chỉ được dùng khi build/test bật `--dart-define=LANH_USE_FAKE_MEAL_ANALYSIS=true`. Bản thường không tự thay thế lỗi mạng bằng dữ liệu giả; lỗi server vẫn hiện màn thử lại.
- iOS cần `NSLocalNetworkUsageDescription` để gọi máy chủ trong mạng LAN; người dùng phải cho phép Mạng cục bộ. Bản phát hành phải dùng HTTPS tới API công khai có xác thực.

## Kiểm tra trên thiết bị

- Kiểm tra quyền camera lần đầu, từ chối, mở Cài đặt để cấp lại, và vào thẳng camera sau khi đã cho phép.
- Chụp và xem ảnh, chụp lại, đưa app về nền rồi mở lại. Kiểm tra nút Đóng quay lại bảng chọn cách ghi bữa ăn.
- Mở thư viện từ hai màn, hủy chọn, chọn ảnh, chọn ảnh khác và quay lại đúng màn trước đó. Xác nhận không hiện yêu cầu quyền đọc cả thư viện.
- Kiểm thử end-to-end trên iPhone: chạy meal API trên Mac với `--host 0.0.0.0`, iPhone cùng Wi-Fi và đã bật Mạng cục bộ cho Lành, rồi build `integration_test/meal_estimation_test.dart` với `LANH_MEAL_API_BASE_URL` theo quy trình Profile trong `docs/flutter/README.md`. Bài test chạy 3 lượt ước lượng thật, chọn Nửa phần, ghi `estimateMilliseconds` vào `results.json` và kiểm tra lỗi mạng khi server không tới được.
- Trên Android, kiểm tra trình chọn ảnh ở phiên bản cũ nhất app hỗ trợ và Android 13 trở lên. Trên iPhone, kiểm tra ảnh HEIC và trường hợp camera bị giới hạn bởi hệ thống.

Nếu camera virtual scene trên emulator phát log Camera3-Stream với timestamp âm lặp lại và chụp không trả kết quả, chuyển camera sau của AVD sang Emulated. Cấu hình Medium Phone API 33 (x86_64) trên máy phát triển đã được chuyển theo cách này sau khi tái hiện lỗi. Đây là cấu hình thiết bị giả lập.

## Cấu hình iOS

Ứng dụng dùng Swift Package Manager và đặt phiên bản iOS tối thiểu là 15.0. `ios/Runner/Info.plist` chứa mô tả quyền camera và thư viện. Camera khởi tạo với `enableAudio: false` vì luồng chỉ chụp ảnh.

Với `permission_handler_apple` đang khóa trong `pubspec.lock`, manifest của package nhận diện quyền camera từ `NSCameraUsageDescription`. Khi có máy Mac, chạy lệnh Flutter từ thư mục gốc dự án để package tìm được cấu hình ứng dụng. Nếu build trực tiếp từ Xcode.app, package yêu cầu biến môi trường `PERMISSION_HANDLER_INFO_PLIST` trỏ đến đường dẫn tuyệt đối của `ios/Runner/Info.plist`; xem phần hướng dẫn trong `ios/permission_handler_apple/Package.swift` của dependency. Cần kiểm tra hộp thoại quyền và thao tác trở lại từ Cài đặt trên thiết bị sau khi build.
