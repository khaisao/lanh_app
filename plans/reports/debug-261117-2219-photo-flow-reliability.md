# Chuyển màn và chụp ảnh

Đã sửa nền route, phản hồi khi chụp, khôi phục ảnh đến muộn và quản lý camera. Kết quả hiện được xác nhận bằng 80 bài kiểm thử, phân tích Flutter và Android 13 emulator. Người dùng xác nhận chưa có môi trường iOS.

## Nguyên nhân được xác nhận

1. Nền gradient nằm ngoài router, các Scaffold trong suốt. Trong chuyển cảnh, nội dung route cũ có thể nhìn xuyên qua route mới. Bài kiểm tra pixel tại 90% thời lượng chuyển cảnh thất bại trên cấu hình Android và iOS khi bỏ nền riêng, rồi qua khi khôi phục phần sửa.
2. Camera virtual scene của Medium Phone API 33 trả timestamp âm lặp lại trong log Camera3-Stream. takePicture nhận lệnh nhưng không hoàn tất. Cold boot không sửa được. Đổi riêng camera sau sang Emulated làm cùng bản app cũ trả ảnh sau khoảng 0,27 giây. Cấu hình AVD hiện đã dùng Emulated.
3. Giao diện cũ chỉ làm mờ nút khi chụp. close còn đợi lệnh chụp đang treo, khiến phiên lỗi có thể chặn việc mở lại.
4. Sau khi Android đóng tiến trình đang chọn ảnh, Flutter có thể khởi động lại phía sau Photo Picker. Plugin sao chép ảnh ở luồng nền và ghi kết quả sau resume. Chỉ kiểm tra lúc khởi động hoặc một lần tại resume đều bỏ lỡ ảnh. Đã tái hiện bằng tiến trình cũ bị đóng, tiến trình mới có PID khác và ảnh không xuất hiện.

## Phần sửa

- Mỗi route có AppBackground riêng, dùng lại ảnh đã giải mã. Giữ chuyển cảnh chuẩn của nền tảng. Camera mở như tác vụ toàn màn hình và bắt đầu sau khi route vào hẳn.
- Có trạng thái Đang chụp ảnh và Đang mở ảnh. Chỉ có một lệnh chụp đang chạy. Ảnh được giải mã trước khi mở màn xem lại.
- Thời hạn chờ lệnh chụp là 15 giây. Khi lỗi hoặc hết hạn, app báo lỗi và tạo lại camera. Đóng camera thực hiện dispose trực tiếp.
- Đổi thế hệ phiên khi rời foreground, khởi động lại hoặc đóng. Kết quả cũ và phiên khởi tạo muộn được loại bỏ.
- Android bật Photo Picker. Giữ quyền camera theo thao tác người dùng, hướng dẫn Cài đặt khi bị chặn và đường chọn ảnh khi từ chối.
- Điều phối khôi phục để tránh mở trùng màn hoặc tiêu thụ cùng một kết quả với luồng đang chạy. Kiểm tra lại tối đa 30 lần cách nhau 500 ms cho kết quả sao chép đến muộn. Chỉ kiểm tra khi foreground và nền tảng hỗ trợ.
- Giữ nguyên byte ảnh trong luồng và giới hạn chiều rộng giải mã ở 2048 pixel. AI vẫn hiện thông báo chưa khả dụng.

## Kiểm tra tự động

- dart format đã chạy cho các tệp Dart thay đổi.
- flutter analyze không có vấn đề.
- flutter test hoàn tất với 80 bài qua.
- Build APK debug android-x64 thành công. Thư viện liquid_glass_shader sẵn có vẫn phát cảnh báo shader khi biên dịch trên Windows.
- Bốn kích thước điện thoại 320×700, 360×800, 390×844, 430×932 và chữ 200%.
- Pixel chuyển cảnh Android/iOS, dùng lại ảnh nền, tab và lối vào Home.
- Chụp thành công, lỗi chụp, chụp treo, bấm liên tiếp, đóng khi đang chụp, trả kết quả muộn, chờ giải mã và lỗi ảnh.
- Rời foreground khi chụp hoặc khởi tạo, camera không khả dụng và đóng tài nguyên.
- Quyền bị từ chối, bị hạn chế, Cài đặt, hủy chọn, chọn ảnh từ các màn và ảnh được khôi phục.
- Kết quả khôi phục đến sau startup hoặc resume, ngăn khôi phục khi flow đang hoạt động, dừng kiểm tra sau khoảng giới hạn và bỏ qua nền tảng không hỗ trợ.

## Kiểm tra native Android 13 API 33

Thiết bị Medium Phone API 33 x86_64, camera sau Emulated. APK chạy qua Home.

| Trường hợp | Kết quả |
| --- | --- |
| Chụp, xem lại, chụp lại | Qua, hiển thị ảnh trả về từ camera emulator |
| Camera virtual scene | Tái hiện lỗi timestamp âm và lệnh chụp treo |
| Chuyển nguồn camera sang Emulated | Cùng bản app trả ảnh, xác nhận nguyên nhân ở nguồn camera giả lập |
| Hủy chọn ảnh từ màn quyền và camera | Quay lại đúng màn |
| Từ chối quyền một lần | Giữ lựa chọn thư viện và khả năng hỏi lại |
| Từ chối lần hai | Hiện Mở Cài đặt |
| Chọn ảnh khi camera bị chặn | Mở Photo Picker và xem được ảnh |
| Cấp lại quyền trong Cài đặt | Tự mở camera khi trở lại app |
| Đưa camera về nền và mở lại | Chụp tiếp và mở màn xem lại được |
| Tiến trình bị Android đóng trong lúc chọn ảnh | Đã xác nhận PID cũ mất, PID mới được tạo, chọn ảnh tiếp và tự mở màn xem lại |
| Quyền thư viện | Photo Picker hiển thị quyền truy cập chỉ ảnh đã chọn |
| Log sau các luồng đã kiểm tra | Không thấy lỗi Flutter hoặc AndroidRuntime |

Đã xem lại các frame ghi hình camera và màn xem ảnh. Luồng hiển thị ảnh tĩnh sau khi chụp, các nút đổi đúng theo trạng thái.

## Đối chiếu tài liệu

- Route opaque chỉ che route trước khi chuyển cảnh hoàn tất. Nền của từng route phải tự vẽ kín trong lúc chuyển cảnh. [Flutter PageRoute.opaque](https://api.flutter.dev/flutter/widgets/PageRoute/opaque.html)
- CameraX là triển khai được Flutter khuyến nghị và hỗ trợ các đặc điểm khác nhau của camera thiết bị. Giữ plugin hiện có. [Flutter camera cookbook](https://docs.flutter.dev/cookbook/plugins/picture-using-camera)
- App chịu trách nhiệm giải phóng và tạo lại camera theo lifecycle. [camera package](https://pub.dev/packages/camera)
- Photo Picker cần bật trên Android 15 trở xuống với phiên bản plugin hiện dùng. [image_picker_android](https://pub.dev/packages/image_picker_android)
- Android khuyến nghị Photo Picker để cấp quyền cho nội dung người dùng chọn. [Android Photo Picker](https://developer.android.com/training/data-storage/shared/photo-picker)
- Khôi phục ảnh sau process death và PHPicker iOS được mô tả trong tài liệu plugin. [image_picker](https://pub.dev/packages/image_picker)
- Trình tự sao chép muộn được đối chiếu thêm ở ImagePickerDelegate.finishWithSuccess và ImagePickerCache trong phiên bản image_picker_android 0.8.13+25 đang khóa trong pubspec.lock.

## Phần chưa kiểm chứng

Chưa chạy camera, quyền, HEIC và vòng đời trên iPhone hoặc biên dịch bằng Xcode. Chưa chạy trên Android vật lý hoặc các API khác API 33. Các bài kiểm tra giao diện iOS chạy trên Windows. Cần môi trường tương ứng để xác nhận các phần này.

Đã đối chiếu tĩnh cấu hình iOS: deployment target 15.0 đáp ứng camera_avfoundation 0.11.1 (13.0) và image_picker_ios 0.8.13+15 (15.0). Info.plist có hai mô tả quyền cần dùng; camera tắt âm thanh. permission_handler_apple 9.6.5 dùng khóa NSCameraUsageDescription để bật triển khai quyền qua Swift Package Manager. Hướng dẫn khác biệt giữa lệnh Flutter và Xcode.app được ghi ở docs/meal-photo.md. Đây là kiểm tra mã và cấu hình, không thay thế build hoặc kiểm thử native.

## Bổ sung đổi camera

- Thêm icon `ph-camera-rotate` theo mẫu CameraPreview và đặt ở bên phải nút chụp. Nút có vùng chạm 56 dp, nhãn trợ năng và dùng lớp kính media hiện có.
- Đối chiếu lại kích thước với HTML mẫu: nút đóng có vòng hiển thị 44 dp, hai nút phụ 48 dp, nút chụp 80 dp. Hai nút phụ và nút đóng vẫn nằm trong vùng tương tác 56 dp của hệ thống thiết kế.
- `MealCamera` nhận hướng camera qua `MealCameraFacing`, giải phóng phiên hiện tại trước khi mở camera mới. Khi đổi thất bại, app khôi phục hướng cũ và cho phép chụp tiếp.
- Nút bị khóa trong lúc đổi camera. Nếu thiết bị chỉ có một hướng camera, nút được ẩn.
- Thêm 7 bài test cho đổi thành công, đổi thất bại, thiết bị một camera, chụp đang chạy, đưa app ra nền và đóng flow khi phiên mới trả về muộn. Bộ test đầy đủ hiện có 87 bài, tất cả đều qua. `flutter analyze` sạch.
- Trên `emulator-5556` với hai camera Emulated, thao tác thực tế đã chuyển từ camera ID 0 sang ID 1, chụp ảnh mở màn xem lại, chụp lại mở camera và tiếp tục chụp được. Log không có lỗi Flutter hoặc AndroidRuntime.
- Bảng chọn cách ghi bữa ăn trả kết quả về caller và đóng hoàn toàn trước khi mở camera. Khi đóng camera hoặc hủy trong lúc chụp, flow trở về Home và không còn bảng chọn cũ phía sau.
