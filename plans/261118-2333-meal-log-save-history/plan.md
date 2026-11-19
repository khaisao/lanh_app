# Kế hoạch: lưu bữa ăn và hiển thị lịch sử hôm nay

## Status
Complete — implementation and Android validation finished.

## Outcome
Nút Lưu trên màn kết quả tạo bản ghi meal độc lập trong SQLite, giữ ảnh cục bộ nếu có, và Home hiển thị các bữa của hôm nay theo thứ tự mới nhất trước.

## Acceptance criteria
- [x] Lưu kết quả từ cả luồng ảnh và voice theo khẩu phần đã chọn.
- [x] SQLite ghi meal và item trong một transaction; đọc lại được sau khởi động lại app.
- [x] Ảnh được copy vào thư mục documents/database; lỗi copy không làm mất meal.
- [x] Nút lưu chống bấm lặp, hiển thị loading/lỗi, và đóng flow sau thành công.
- [x] Home cập nhật sau lưu; ngày khác không xuất hiện trong danh sách hôm nay.
- [x] Fallback giả chỉ có hiệu lực khi bật cờ build/test.
- [x] Có unit/widget/integration coverage cho happy path, save error, duplicate tap, persistence, date filter, photo fallback và API fallback seam.
- [x] `flutter analyze`, focused tests, full tests và Android debug build pass.

## Validation report
See [implementation report](../reports/implementation-261118-2333-meal-log-save-history.md).
