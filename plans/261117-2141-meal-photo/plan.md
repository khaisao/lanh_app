# Ảnh bữa ăn

Trạng thái: đã triển khai và kiểm tra trên Android 13 emulator. Kiểm tra camera và quyền trên iPhone còn cần môi trường iOS.

Luồng đã chốt trong [bản xem trước](../reports/advise-261117-2141-meal-photo-preview.html).

1. Nối bảng chọn ghi bữa ăn với ba màn theo HTML. Dùng design system và giữ thao tác quay lại đúng nguồn.
2. Chụp ảnh và chọn một ảnh thật. Chỉ hỏi quyền camera khi người dùng chọn cấp quyền. Hỗ trợ từ chối, Cài đặt và vòng đời camera. Xem lại ảnh tạm. Nút ước lượng hiển thị thông báo chưa khả dụng.
3. Kiểm tra kích thước 320×700, 360×800, 390×844 và 430×932, các nhánh quyền và điều hướng, rồi chạy phân tích, bộ kiểm thử Flutter và bài kiểm tra thiết bị khả dụng.

Phạm vi kết thúc ở màn xem ảnh. Kết quả chạy iOS cần Xcode và iPhone.

Kết quả kiểm tra được ghi trong [báo cáo](../reports/test-261117-2153-meal-photo.md).
