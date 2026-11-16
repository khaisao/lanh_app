// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Lành';

  @override
  String get welcomeHeadline => 'Mỗi bữa lành, một mầm vui.';

  @override
  String get welcomeBody =>
      'Bắt đầu từ bữa bạn vừa ăn, hoặc đặt một hướng riêng. Không cần nhập cân nặng.';

  @override
  String get welcomeGoalUnavailable => 'Đặt mục tiêu của tôi';

  @override
  String get welcomeLogFirstMeal => 'Ghi bữa ăn đầu tiên';

  @override
  String get saving => 'Đang lưu…';

  @override
  String get welcomeDisclaimer =>
      'Mọi con số calo trong Lành là ước tính, chỉ mang tính tham khảo.';

  @override
  String get saveIntroductionError =>
      'Chưa lưu được lựa chọn. Vui lòng thử lại.';

  @override
  String get startupError =>
      'Chưa đọc được thiết lập của bạn. Thử lại để tiếp tục.';

  @override
  String get retry => 'Thử lại';

  @override
  String get today => 'Hôm nay';

  @override
  String get progress => 'Tiến trình';

  @override
  String get achievements => 'Thành tựu';

  @override
  String get menu => 'Menu';

  @override
  String get logMeal => 'Ghi bữa ăn';

  @override
  String get todayHeading => 'Hôm nay của bạn';

  @override
  String get todayEmptyTitle => 'Bắt đầu từ một bữa ăn';

  @override
  String get todayEmptyBody =>
      'Nhật ký của bạn đang trống. Sau khi ghi bữa, tổng calo và các món sẽ xuất hiện ở đây.';

  @override
  String get progressEmptyTitle => 'Tiến trình bắt đầu từ bạn';

  @override
  String get progressEmptyBody =>
      'Chưa có dữ liệu để tổng hợp. Ngày chưa ghi bữa sẽ không được tính là 0 calo.';

  @override
  String get achievementsEmptyTitle => 'Mỗi bước nhỏ đều đáng nhớ';

  @override
  String get achievementsEmptyBody =>
      'Các cột mốc sẽ ghi nhận thói quen chăm sóc bản thân, không đánh giá việc ăn ít hay nhiều.';

  @override
  String get baseNotice =>
      'Đây là bản nền tảng. Ghi bữa và theo dõi sức khỏe chưa được triển khai.';

  @override
  String get chooseMealMethod => 'Ghi bữa ăn';

  @override
  String get close => 'Đóng';

  @override
  String get camera => 'Chụp ảnh';

  @override
  String get gallery => 'Chọn ảnh';

  @override
  String get search => 'Tìm món ăn';

  @override
  String get manual => 'Nhập tay';

  @override
  String get templates => 'Bữa quen';

  @override
  String get mealMethodsNotice =>
      'Các cách ghi bữa sẽ được phát triển ở phiên bản tiếp theo. Hiện ứng dụng chưa xin quyền camera hoặc gửi ảnh.';

  @override
  String get about => 'Về Lành';

  @override
  String get aboutBody =>
      'Lành đồng hành cùng bạn trong việc ăn uống có ý thức và chăm sóc bản thân. Bạn có thể muốn giảm cân, tăng cân, giữ cân hoặc đơn giản là hiểu bữa ăn của mình.';

  @override
  String get privacyBase =>
      'Bản nền tảng lưu lựa chọn mục tiêu và việc bạn đã xem phần giới thiệu trên thiết bị. Ảnh bữa ăn và dữ liệu sức khỏe chưa được đồng bộ.';

  @override
  String get notFound => 'Không tìm thấy trang';

  @override
  String get backToToday => 'Về Hôm nay';
}
