# Chuyển màn và chụp ảnh

Trạng thái: đã sửa và xác nhận trên Android 13 emulator. Đang chờ môi trường để kiểm chứng native iOS.

## Kết quả cần đạt

- Khi chuyển màn, nội dung màn cũ không nhìn xuyên qua nền màn mới. Giữ hành vi quay lại, điều hướng tab và hỗ trợ giảm chuyển động.
- Bấm chụp có phản hồi ngay, chỉ chạy một lần chụp, mở đúng ảnh vừa chụp khi thành công và có đường phục hồi khi camera lỗi hoặc không trả kết quả.
- Quyền camera, Cài đặt, thư viện hệ thống, khôi phục ảnh Android và vòng đời được rà soát theo tài liệu chính thức, kiểm tra lại qua lối vào Home.
- Giữ ba màn và design system đã chốt, cấu trúc Flutter của dự án và thông báo AI chưa khả dụng.

## Các bước

1. Scout code, log thiết bị và tài liệu, chứng minh nguyên nhân.
2. Sửa nền của route, trạng thái chụp và quản lý tài nguyên. Bổ sung kiểm thử hồi quy cho chuyển cảnh và các tác vụ bất đồng bộ.
3. Chạy phân tích, toàn bộ test, build và kiểm tra native có ghi nhận thiết bị, trường hợp, kết quả.
4. Rà soát diff và cập nhật hướng dẫn sở hữu hành vi đã thay đổi.

## Bằng chứng ban đầu

- AppBackground nằm ngoài router, các Scaffold trong suốt. MaterialPageRoute chỉ che route cũ khi chuyển cảnh kết thúc.
- CameraX nhận takePicture nhưng emulator trả các frame có timestamp âm lặp lại, ảnh không hoàn tất.
- Nút chụp thiếu trạng thái tiến trình rõ ràng. close đợi pending capture vô thời hạn.
- image_picker_android hiện cần bật Photo Picker trên Android 15 trở xuống.

## Xác nhận hoàn tất

Đối chiếu yêu cầu ở trên bằng test giữa các frame chuyển cảnh, kiểm thử tác vụ thành công/lỗi/hủy/timeout/lifecycle, ảnh hiển thị thật và log native. Các nền tảng chưa có môi trường phải được ghi rõ và tiếp tục theo dõi.

Kết quả trong [báo cáo nghiên cứu và kiểm thử](../reports/debug-261117-2219-photo-flow-reliability.md).
