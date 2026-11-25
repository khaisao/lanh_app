import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @mealPhotoSwitchCamera.
  ///
  /// In vi, this message translates to:
  /// **'Đổi sang camera trước hoặc sau'**
  String get mealPhotoSwitchCamera;

  /// No description provided for @mealPhotoSwitching.
  ///
  /// In vi, this message translates to:
  /// **'Đang đổi camera…'**
  String get mealPhotoSwitching;

  /// No description provided for @mealPhotoSwitchError.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đổi được camera. Vui lòng thử lại.'**
  String get mealPhotoSwitchError;

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lành'**
  String get appTitle;

  /// No description provided for @welcomeHeadline.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi bữa lành,\nmột mầm vui.'**
  String get welcomeHeadline;

  /// No description provided for @welcomeBody.
  ///
  /// In vi, this message translates to:
  /// **'Hiểu bữa ăn của bạn từng chút một. Không cần cân nặng để bắt đầu.'**
  String get welcomeBody;

  /// No description provided for @welcomeGoalAction.
  ///
  /// In vi, this message translates to:
  /// **'Đặt mục tiêu của tôi'**
  String get welcomeGoalAction;

  /// No description provided for @saving.
  ///
  /// In vi, this message translates to:
  /// **'Đang lưu…'**
  String get saving;

  /// No description provided for @welcomeDisclaimer.
  ///
  /// In vi, this message translates to:
  /// **'Mọi con số calo trong Lành là ước tính.'**
  String get welcomeDisclaimer;

  /// No description provided for @startupError.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đọc được thiết lập của bạn. Thử lại để tiếp tục.'**
  String get startupError;

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// No description provided for @today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// No description provided for @progress.
  ///
  /// In vi, this message translates to:
  /// **'Tiến trình'**
  String get progress;

  /// No description provided for @achievements.
  ///
  /// In vi, this message translates to:
  /// **'Thành tựu'**
  String get achievements;

  /// No description provided for @menu.
  ///
  /// In vi, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @logMeal.
  ///
  /// In vi, this message translates to:
  /// **'Ghi bữa ăn'**
  String get logMeal;

  /// No description provided for @todayEmptyBody.
  ///
  /// In vi, this message translates to:
  /// **'Nhật ký của bạn đang trống. Sau khi ghi bữa, tổng calo và các món sẽ xuất hiện ở đây.'**
  String get todayEmptyBody;

  /// No description provided for @baseNotice.
  ///
  /// In vi, this message translates to:
  /// **'Đây là bản nền tảng. Ghi bữa và theo dõi sức khỏe chưa được triển khai.'**
  String get baseNotice;

  /// No description provided for @chooseMealMethod.
  ///
  /// In vi, this message translates to:
  /// **'Ghi bữa ăn'**
  String get chooseMealMethod;

  /// No description provided for @mealMethodSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn cách bắt đầu'**
  String get mealMethodSubtitle;

  /// No description provided for @mealPhotoDescription.
  ///
  /// In vi, this message translates to:
  /// **'Chụp hoặc chọn ảnh bữa ăn'**
  String get mealPhotoDescription;

  /// No description provided for @mealVoice.
  ///
  /// In vi, this message translates to:
  /// **'Ghi bằng giọng nói'**
  String get mealVoice;

  /// No description provided for @mealVoiceDescription.
  ///
  /// In vi, this message translates to:
  /// **'Nói tên món và lượng ăn'**
  String get mealVoiceDescription;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get close;

  /// No description provided for @camera.
  ///
  /// In vi, this message translates to:
  /// **'Chụp ảnh'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ảnh'**
  String get gallery;

  /// No description provided for @mealPhotoBack.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get mealPhotoBack;

  /// No description provided for @mealPhotoPermissionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cho Lành dùng camera?'**
  String get mealPhotoPermissionTitle;

  /// No description provided for @mealPhotoPermissionBody.
  ///
  /// In vi, this message translates to:
  /// **'Lành dùng camera để bạn chụp ảnh bữa ăn. Bạn cũng có thể chọn ảnh có sẵn trong thư viện.'**
  String get mealPhotoPermissionBody;

  /// No description provided for @mealPhotoPermissionDenied.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa cấp quyền camera. Bạn có thể thử lại hoặc chọn ảnh từ thư viện.'**
  String get mealPhotoPermissionDenied;

  /// No description provided for @mealPhotoPermissionBlocked.
  ///
  /// In vi, this message translates to:
  /// **'Camera đang bị tắt cho Lành. Bạn có thể cấp quyền trong Cài đặt hoặc chọn ảnh từ thư viện.'**
  String get mealPhotoPermissionBlocked;

  /// No description provided for @mealPhotoPermissionRestricted.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị đang hạn chế quyền camera. Bạn vẫn có thể chọn ảnh từ thư viện.'**
  String get mealPhotoPermissionRestricted;

  /// No description provided for @mealPhotoCameraUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Lành chưa mở được camera. Bạn có thể thử lại hoặc chọn ảnh từ thư viện.'**
  String get mealPhotoCameraUnavailable;

  /// No description provided for @mealPhotoAllowCamera.
  ///
  /// In vi, this message translates to:
  /// **'Cho phép camera'**
  String get mealPhotoAllowCamera;

  /// No description provided for @mealPhotoOpenSettings.
  ///
  /// In vi, this message translates to:
  /// **'Mở Cài đặt'**
  String get mealPhotoOpenSettings;

  /// No description provided for @mealPhotoChoose.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ảnh từ thư viện'**
  String get mealPhotoChoose;

  /// No description provided for @mealPhotoCameraLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang mở camera'**
  String get mealPhotoCameraLoading;

  /// No description provided for @mealPhotoReviewLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh bữa ăn đang xem lại'**
  String get mealPhotoReviewLabel;

  /// No description provided for @mealPhotoCaptured.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh đã chụp'**
  String get mealPhotoCaptured;

  /// No description provided for @mealPhotoReadyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh đã sẵn sàng'**
  String get mealPhotoReadyTitle;

  /// No description provided for @mealPhotoReadyBody.
  ///
  /// In vi, this message translates to:
  /// **'Lành sẽ ước lượng calo từ ảnh này. Kết quả là ước tính, bạn kiểm tra lại trước khi lưu.'**
  String get mealPhotoReadyBody;

  /// No description provided for @mealPhotoEstimate.
  ///
  /// In vi, this message translates to:
  /// **'Ước lượng bữa ăn'**
  String get mealPhotoEstimate;

  /// No description provided for @mealPhotoRetake.
  ///
  /// In vi, this message translates to:
  /// **'Chụp lại'**
  String get mealPhotoRetake;

  /// No description provided for @mealPhotoReplace.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ảnh khác'**
  String get mealPhotoReplace;

  /// No description provided for @mealPhotoPickError.
  ///
  /// In vi, this message translates to:
  /// **'Lành chưa mở được ảnh này. Vui lòng chọn ảnh khác.'**
  String get mealPhotoPickError;

  /// No description provided for @mealPhotoCaptureError.
  ///
  /// In vi, this message translates to:
  /// **'Lành chưa chụp được ảnh. Vui lòng thử lại.'**
  String get mealPhotoCaptureError;

  /// No description provided for @mealPhotoCaptureTimeout.
  ///
  /// In vi, this message translates to:
  /// **'Camera chưa trả ảnh. Bạn có thể thử lại hoặc chọn ảnh từ thư viện.'**
  String get mealPhotoCaptureTimeout;

  /// No description provided for @mealPhotoCapturing.
  ///
  /// In vi, this message translates to:
  /// **'Đang chụp ảnh…'**
  String get mealPhotoCapturing;

  /// No description provided for @mealPhotoLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang mở ảnh…'**
  String get mealPhotoLoading;

  /// No description provided for @mealPhotoSettingsError.
  ///
  /// In vi, this message translates to:
  /// **'Lành chưa mở được Cài đặt. Bạn có thể mở Cài đặt trên thiết bị.'**
  String get mealPhotoSettingsError;

  /// No description provided for @about.
  ///
  /// In vi, this message translates to:
  /// **'Về Lành'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In vi, this message translates to:
  /// **'Lành đồng hành cùng bạn trong việc ăn uống có ý thức và chăm sóc bản thân. Bạn có thể muốn giảm cân, tăng cân, giữ cân hoặc đơn giản là hiểu bữa ăn của mình.'**
  String get aboutBody;

  /// No description provided for @notFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy trang'**
  String get notFound;

  /// No description provided for @backToToday.
  ///
  /// In vi, this message translates to:
  /// **'Về Hôm nay'**
  String get backToToday;

  /// No description provided for @profileGoal.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu'**
  String get profileGoal;

  /// No description provided for @profileGoalHeading.
  ///
  /// In vi, this message translates to:
  /// **'Bạn muốn gì?'**
  String get profileGoalHeading;

  /// No description provided for @profileGain.
  ///
  /// In vi, this message translates to:
  /// **'Tăng cân'**
  String get profileGain;

  /// No description provided for @profileLose.
  ///
  /// In vi, this message translates to:
  /// **'Giảm cân'**
  String get profileLose;

  /// No description provided for @profileMaintain.
  ///
  /// In vi, this message translates to:
  /// **'Giữ cân'**
  String get profileMaintain;

  /// No description provided for @profileBody.
  ///
  /// In vi, this message translates to:
  /// **'Về bạn'**
  String get profileBody;

  /// No description provided for @profileAge.
  ///
  /// In vi, this message translates to:
  /// **'Tuổi'**
  String get profileAge;

  /// No description provided for @profileHeight.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao'**
  String get profileHeight;

  /// No description provided for @profileCurrentWeight.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng hiện tại'**
  String get profileCurrentWeight;

  /// No description provided for @profileSex.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính'**
  String get profileSex;

  /// No description provided for @profileBmiAdultUnderweight.
  ///
  /// In vi, this message translates to:
  /// **'Dưới vùng khỏe mạnh'**
  String get profileBmiAdultUnderweight;

  /// No description provided for @profileBmiAdultHealthy.
  ///
  /// In vi, this message translates to:
  /// **'Trong khoảng thường gặp'**
  String get profileBmiAdultHealthy;

  /// No description provided for @profileBmiAdultOverweight.
  ///
  /// In vi, this message translates to:
  /// **'Cao hơn vùng khỏe mạnh'**
  String get profileBmiAdultOverweight;

  /// No description provided for @profileBmiAdultObesity.
  ///
  /// In vi, this message translates to:
  /// **'Cần được chuyên gia đánh giá'**
  String get profileBmiAdultObesity;

  /// No description provided for @profileBmiTeenHint.
  ///
  /// In vi, this message translates to:
  /// **'Tuổi 13–19: Lành đọc theo tuổi và giới (CDC), không dùng ngưỡng người lớn.'**
  String get profileBmiTeenHint;

  /// No description provided for @profileFemale.
  ///
  /// In vi, this message translates to:
  /// **'Nữ'**
  String get profileFemale;

  /// No description provided for @profileMale.
  ///
  /// In vi, this message translates to:
  /// **'Nam'**
  String get profileMale;

  /// No description provided for @profileTarget.
  ///
  /// In vi, this message translates to:
  /// **'Mong muốn'**
  String get profileTarget;

  /// No description provided for @profileTargetWeight.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng mong muốn'**
  String get profileTargetWeight;

  /// No description provided for @profileTargetDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày muốn đạt'**
  String get profileTargetDate;

  /// No description provided for @profileEstimate.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính'**
  String get profileEstimate;

  /// No description provided for @profileActivity.
  ///
  /// In vi, this message translates to:
  /// **'Vận động thường ngày'**
  String get profileActivity;

  /// No description provided for @profileActivityHeading.
  ///
  /// In vi, this message translates to:
  /// **'Một ngày thường'**
  String get profileActivityHeading;

  /// No description provided for @profileSitting.
  ///
  /// In vi, this message translates to:
  /// **'Chủ yếu ngồi'**
  String get profileSitting;

  /// No description provided for @profileLight.
  ///
  /// In vi, this message translates to:
  /// **'Đứng và đi lại xen kẽ'**
  String get profileLight;

  /// No description provided for @profileModerate.
  ///
  /// In vi, this message translates to:
  /// **'Đứng hoặc đi lại phần lớn ngày'**
  String get profileModerate;

  /// No description provided for @profileHeavy.
  ///
  /// In vi, this message translates to:
  /// **'Thường xuyên làm việc thể lực'**
  String get profileHeavy;

  /// No description provided for @profileVariable.
  ///
  /// In vi, this message translates to:
  /// **'Lịch thay đổi / Chưa rõ'**
  String get profileVariable;

  /// No description provided for @profileContinue.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get profileContinue;

  /// No description provided for @profileConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get profileConfirm;

  /// No description provided for @profileBack.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get profileBack;

  /// No description provided for @profileStepStatus.
  ///
  /// In vi, this message translates to:
  /// **'Bước {step} trên 4'**
  String profileStepStatus(int step);

  /// No description provided for @profileEditStep.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa: {title}'**
  String profileEditStep(String title);

  /// No description provided for @profileInvalidAge.
  ///
  /// In vi, this message translates to:
  /// **'Tuổi chưa hợp lệ'**
  String get profileInvalidAge;

  /// No description provided for @profileAgeTooYoung.
  ///
  /// In vi, this message translates to:
  /// **'Lành dành cho người từ 13 tuổi'**
  String get profileAgeTooYoung;

  /// No description provided for @profileMissingSex.
  ///
  /// In vi, this message translates to:
  /// **'Chọn giới tính để tiếp tục.'**
  String get profileMissingSex;

  /// No description provided for @profileTeenGuidanceTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu an toàn trong giai đoạn lớn'**
  String get profileTeenGuidanceTitle;

  /// No description provided for @profileTeenUnderweightGain.
  ///
  /// In vi, this message translates to:
  /// **'Cơ thể bạn đang ở dưới vùng tham chiếu theo tuổi. Hãy ưu tiên ăn đủ và trao đổi với người lớn hoặc chuyên gia; Lành không tự đặt tốc độ tăng cân cho tuổi đang lớn.'**
  String get profileTeenUnderweightGain;

  /// No description provided for @profileTeenUnderweightLose.
  ///
  /// In vi, this message translates to:
  /// **'Lành không khuyến nghị đặt mục tiêu giảm cân khi chỉ số theo tuổi đang dưới vùng tham chiếu. Hãy trao đổi với người lớn hoặc chuyên gia.'**
  String get profileTeenUnderweightLose;

  /// No description provided for @profileTeenHealthy.
  ///
  /// In vi, this message translates to:
  /// **'Cơ thể bạn đang ở vùng tham chiếu theo tuổi. Trong giai đoạn lớn, Lành ưu tiên thói quen đều đặn và giữ nhịp tăng trưởng thay vì ép cân.'**
  String get profileTeenHealthy;

  /// No description provided for @profileTeenOverweightLose.
  ///
  /// In vi, this message translates to:
  /// **'Lành sẽ tập trung vào thói quen lành mạnh và nhịp tăng trưởng. Mục tiêu thay đổi cân nặng nên được trao đổi cùng gia đình và chuyên gia.'**
  String get profileTeenOverweightLose;

  /// No description provided for @profileTeenOverweightGain.
  ///
  /// In vi, this message translates to:
  /// **'Lành không tự đặt mục tiêu tăng cân khi chỉ số theo tuổi đang cao hơn vùng tham chiếu. Hãy trao đổi với gia đình và chuyên gia.'**
  String get profileTeenOverweightGain;

  /// No description provided for @profileTeenBmiStatusUnderweight.
  ///
  /// In vi, this message translates to:
  /// **'Dưới vùng tham chiếu theo tuổi'**
  String get profileTeenBmiStatusUnderweight;

  /// No description provided for @profileTeenBmiStatusHealthy.
  ///
  /// In vi, this message translates to:
  /// **'Trong vùng tham chiếu theo tuổi'**
  String get profileTeenBmiStatusHealthy;

  /// No description provided for @profileTeenBmiStatusOverweight.
  ///
  /// In vi, this message translates to:
  /// **'Cao hơn vùng tham chiếu theo tuổi'**
  String get profileTeenBmiStatusOverweight;

  /// No description provided for @profileTeenBmiStatusObesity.
  ///
  /// In vi, this message translates to:
  /// **'Cần được chuyên gia đánh giá'**
  String get profileTeenBmiStatusObesity;

  /// No description provided for @profileEstimateDate.
  ///
  /// In vi, this message translates to:
  /// **'Dự kiến {date}'**
  String profileEstimateDate(String date);

  /// No description provided for @profileSaveError.
  ///
  /// In vi, this message translates to:
  /// **'Chưa lưu xong hồ sơ. Vui lòng thử lại.'**
  String get profileSaveError;

  /// No description provided for @todayGreeting.
  ///
  /// In vi, this message translates to:
  /// **'Chào bạn'**
  String get todayGreeting;

  /// No description provided for @todayEnergy.
  ///
  /// In vi, this message translates to:
  /// **'Năng lượng hôm nay'**
  String get todayEnergy;

  /// No description provided for @todayTargetUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có mục tiêu kcal.'**
  String get todayTargetUnavailable;

  /// No description provided for @todayRangeUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dải kcal duy trì.'**
  String get todayRangeUnavailable;

  /// No description provided for @todayLoadingProfile.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải hồ sơ…'**
  String get todayLoadingProfile;

  /// No description provided for @todayProfileReadError.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đọc được hồ sơ.'**
  String get todayProfileReadError;

  /// No description provided for @todayNoEnergy.
  ///
  /// In vi, this message translates to:
  /// **'—'**
  String get todayNoEnergy;

  /// No description provided for @todayLoggedKcal.
  ///
  /// In vi, this message translates to:
  /// **'kcal đã ghi'**
  String get todayLoggedKcal;

  /// No description provided for @todayNoWater.
  ///
  /// In vi, this message translates to:
  /// **'Chưa ghi'**
  String get todayNoWater;

  /// No description provided for @todayWater.
  ///
  /// In vi, this message translates to:
  /// **'Nước'**
  String get todayWater;

  /// No description provided for @todayMealReadError.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đọc được nhật ký hôm nay.'**
  String get todayMealReadError;

  /// No description provided for @todayJournal.
  ///
  /// In vi, this message translates to:
  /// **'Nhật ký ăn uống'**
  String get todayJournal;

  /// No description provided for @todayDetails.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết'**
  String get todayDetails;

  /// No description provided for @todayEstimated.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính'**
  String get todayEstimated;

  /// No description provided for @mealEstimationNotice.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả là ước tính'**
  String get mealEstimationNotice;

  /// No description provided for @mealEstimatingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lành đang ước lượng'**
  String get mealEstimatingTitle;

  /// No description provided for @mealEstimatingBody.
  ///
  /// In vi, this message translates to:
  /// **'Thường mất vài giây. Bạn sẽ kiểm tra lại trước khi lưu.'**
  String get mealEstimatingBody;

  /// No description provided for @mealEstimationErrorTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa ước lượng được'**
  String get mealEstimationErrorTitle;

  /// No description provided for @mealEstimationErrorBody.
  ///
  /// In vi, this message translates to:
  /// **'Lành chưa nhìn rõ bữa này. Thử chụp gần hơn hoặc dưới ánh sáng tốt hơn. Ảnh vẫn được giữ lại.'**
  String get mealEstimationErrorBody;

  /// No description provided for @mealEstimationCancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy phân tích'**
  String get mealEstimationCancel;

  /// No description provided for @mealEstimationReceived.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận ảnh'**
  String get mealEstimationReceived;

  /// No description provided for @mealEstimationRecognizing.
  ///
  /// In vi, this message translates to:
  /// **'Nhận diện món trong ảnh'**
  String get mealEstimationRecognizing;

  /// No description provided for @mealEstimationPortion.
  ///
  /// In vi, this message translates to:
  /// **'Ước lượng khẩu phần'**
  String get mealEstimationPortion;

  /// No description provided for @mealEstimationCalories.
  ///
  /// In vi, this message translates to:
  /// **'Tính calo ước tính'**
  String get mealEstimationCalories;

  /// No description provided for @mealEstimationDone.
  ///
  /// In vi, this message translates to:
  /// **'Xong'**
  String get mealEstimationDone;

  /// No description provided for @mealEstimationWorking.
  ///
  /// In vi, this message translates to:
  /// **'Đang làm'**
  String get mealEstimationWorking;

  /// No description provided for @mealEstimationWaiting.
  ///
  /// In vi, this message translates to:
  /// **'Chờ'**
  String get mealEstimationWaiting;

  /// No description provided for @mealEstimationNetworkBody.
  ///
  /// In vi, this message translates to:
  /// **'Lành chưa kết nối được máy chủ phân tích. Kiểm tra mạng rồi thử lại. Ảnh vẫn được giữ lại.'**
  String get mealEstimationNetworkBody;

  /// No description provided for @mealEstimationUnavailableBody.
  ///
  /// In vi, this message translates to:
  /// **'Máy chủ phân tích đang bận hoặc phản hồi quá lâu. Vui lòng thử lại sau ít phút. Ảnh vẫn được giữ lại.'**
  String get mealEstimationUnavailableBody;

  /// No description provided for @mealEstimationInvalidPhotoBody.
  ///
  /// In vi, this message translates to:
  /// **'Lành chưa đọc được ảnh này. Hãy chụp lại hoặc chọn ảnh khác.'**
  String get mealEstimationInvalidPhotoBody;

  /// No description provided for @mealEstimationNotConfiguredBody.
  ///
  /// In vi, this message translates to:
  /// **'Bản ứng dụng này chưa được cấu hình máy chủ phân tích bữa ăn.'**
  String get mealEstimationNotConfiguredBody;

  /// No description provided for @mealReviewTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra bữa ăn'**
  String get mealReviewTitle;

  /// No description provided for @mealReviewPhotoLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh bữa ăn'**
  String get mealReviewPhotoLabel;

  /// No description provided for @mealReviewEstimateBadge.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính'**
  String get mealReviewEstimateBadge;

  /// No description provided for @mealReviewKcal.
  ///
  /// In vi, this message translates to:
  /// **'kcal'**
  String get mealReviewKcal;

  /// No description provided for @mealReviewUnknown.
  ///
  /// In vi, this message translates to:
  /// **'Chưa rõ'**
  String get mealReviewUnknown;

  /// No description provided for @mealReviewItemCount.
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, other{{count} món}}'**
  String mealReviewItemCount(int count);

  /// No description provided for @mealReviewPortionGroup.
  ///
  /// In vi, this message translates to:
  /// **'Chọn khẩu phần cả bữa'**
  String get mealReviewPortionGroup;

  /// No description provided for @mealReviewPortionHalf.
  ///
  /// In vi, this message translates to:
  /// **'Nửa phần'**
  String get mealReviewPortionHalf;

  /// No description provided for @mealReviewPortionOne.
  ///
  /// In vi, this message translates to:
  /// **'1 phần'**
  String get mealReviewPortionOne;

  /// No description provided for @mealReviewPortionOneHalf.
  ///
  /// In vi, this message translates to:
  /// **'1,5 phần'**
  String get mealReviewPortionOneHalf;

  /// No description provided for @mealReviewItemsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Các món'**
  String get mealReviewItemsTitle;

  /// No description provided for @mealReviewMissingCalories.
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, other{{count} món chưa có calo nên chưa được tính vào tổng.}}'**
  String mealReviewMissingCalories(int count);

  /// No description provided for @mealReviewDisclaimer.
  ///
  /// In vi, this message translates to:
  /// **'Số liệu là ước tính từ ảnh, có thể lệch so với phần bạn thực ăn.'**
  String get mealReviewDisclaimer;

  /// No description provided for @mealReviewSave.
  ///
  /// In vi, this message translates to:
  /// **'Lưu bữa ăn'**
  String get mealReviewSave;

  /// No description provided for @mealReviewSaveError.
  ///
  /// In vi, this message translates to:
  /// **'Chưa lưu được bữa ăn. Vui lòng thử lại.'**
  String get mealReviewSaveError;

  /// No description provided for @mealReviewDiscard.
  ///
  /// In vi, this message translates to:
  /// **'Hủy, không lưu'**
  String get mealReviewDiscard;

  /// No description provided for @mealUnitGram.
  ///
  /// In vi, this message translates to:
  /// **'g'**
  String get mealUnitGram;

  /// No description provided for @mealUnitMilliliter.
  ///
  /// In vi, this message translates to:
  /// **'ml'**
  String get mealUnitMilliliter;

  /// No description provided for @mealUnitServing.
  ///
  /// In vi, this message translates to:
  /// **'phần'**
  String get mealUnitServing;

  /// No description provided for @mealUnitPiece.
  ///
  /// In vi, this message translates to:
  /// **'cái'**
  String get mealUnitPiece;

  /// No description provided for @mealReviewClose.
  ///
  /// In vi, this message translates to:
  /// **'Đóng, không lưu'**
  String get mealReviewClose;

  /// No description provided for @mealReviewEnergy.
  ///
  /// In vi, this message translates to:
  /// **'Tổng năng lượng'**
  String get mealReviewEnergy;

  /// No description provided for @mealReviewNutrients.
  ///
  /// In vi, this message translates to:
  /// **'Chất dinh dưỡng'**
  String get mealReviewNutrients;

  /// No description provided for @mealReviewNutrientsLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đạm {protein}, tinh bột {carbs}, chất béo {fat}'**
  String mealReviewNutrientsLabel(String protein, String carbs, String fat);

  /// No description provided for @mealReviewProtein.
  ///
  /// In vi, this message translates to:
  /// **'Đạm'**
  String get mealReviewProtein;

  /// No description provided for @mealReviewCarbs.
  ///
  /// In vi, this message translates to:
  /// **'Tinh bột'**
  String get mealReviewCarbs;

  /// No description provided for @mealReviewFat.
  ///
  /// In vi, this message translates to:
  /// **'Chất béo'**
  String get mealReviewFat;

  /// No description provided for @mealReviewFatShort.
  ///
  /// In vi, this message translates to:
  /// **'Béo'**
  String get mealReviewFatShort;

  /// No description provided for @mealReviewNameJoin.
  ///
  /// In vi, this message translates to:
  /// **'{first} và {last}'**
  String mealReviewNameJoin(String first, String last);

  /// No description provided for @mealReviewAddToday.
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào hôm nay'**
  String get mealReviewAddToday;

  /// No description provided for @mealReviewMacroChip.
  ///
  /// In vi, this message translates to:
  /// **'{label} {value}'**
  String mealReviewMacroChip(String label, String value);

  /// No description provided for @mealVoiceTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ghi giọng nói'**
  String get mealVoiceTitle;

  /// No description provided for @mealVoiceTimerLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đã ghi {seconds} giây'**
  String mealVoiceTimerLabel(Object seconds);

  /// No description provided for @mealVoiceHeading.
  ///
  /// In vi, this message translates to:
  /// **'Kể bữa bạn vừa ăn'**
  String get mealVoiceHeading;

  /// No description provided for @mealVoiceExample.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: “Ăn một tô phở bò tái, thêm ly trà đá”'**
  String get mealVoiceExample;

  /// No description provided for @mealVoiceFinishing.
  ///
  /// In vi, this message translates to:
  /// **'Đang chuyển thành chữ…'**
  String get mealVoiceFinishing;

  /// No description provided for @mealVoiceCancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy ghi'**
  String get mealVoiceCancel;

  /// No description provided for @mealVoiceNoSpeech.
  ///
  /// In vi, this message translates to:
  /// **'Lành chưa nghe thấy lời nào. Chạm micro và kể lại nhé.'**
  String get mealVoiceNoSpeech;

  /// No description provided for @mealVoiceLanguageUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị chưa hỗ trợ nhận giọng nói tiếng Việt. Bạn có thể nhập bằng chữ.'**
  String get mealVoiceLanguageUnavailable;

  /// No description provided for @mealVoiceRecognitionError.
  ///
  /// In vi, this message translates to:
  /// **'Lành chưa nhận được giọng nói. Kiểm tra mạng rồi thử lại, hoặc nhập bằng chữ.'**
  String get mealVoiceRecognitionError;

  /// No description provided for @mealVoiceTypeInstead.
  ///
  /// In vi, this message translates to:
  /// **'Nhập bằng chữ'**
  String get mealVoiceTypeInstead;

  /// No description provided for @mealVoiceUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị này chưa hỗ trợ ghi giọng nói. Bạn có thể nhập bằng chữ.'**
  String get mealVoiceUnavailable;

  /// No description provided for @mealVoiceAccessDeniedBody.
  ///
  /// In vi, this message translates to:
  /// **'Bật quyền micro trong Cài đặt để ghi bữa ăn bằng giọng nói.'**
  String get mealVoiceAccessDeniedBody;

  /// No description provided for @mealVoiceDeviceUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị này chưa hỗ trợ ghi giọng nói.'**
  String get mealVoiceDeviceUnavailable;

  /// No description provided for @mealVoiceConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra lời nói'**
  String get mealVoiceConfirmTitle;

  /// No description provided for @mealVoiceTypedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả bữa ăn'**
  String get mealVoiceTypedTitle;

  /// No description provided for @mealVoiceBackToRecording.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại ghi âm'**
  String get mealVoiceBackToRecording;

  /// No description provided for @mealVoiceConfirmHeading.
  ///
  /// In vi, this message translates to:
  /// **'Lành nghe rồi'**
  String get mealVoiceConfirmHeading;

  /// No description provided for @mealVoiceConfirmHint.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả chỉ là ước lượng, bạn kiểm tra trước khi lưu.'**
  String get mealVoiceConfirmHint;

  /// No description provided for @mealVoiceTranscriptLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chữ chuyển từ giọng nói'**
  String get mealVoiceTranscriptLabel;

  /// No description provided for @mealVoiceTypedLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả của bạn'**
  String get mealVoiceTypedLabel;

  /// No description provided for @mealVoiceWordCount.
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, other{{count} từ}}'**
  String mealVoiceWordCount(int count);

  /// No description provided for @mealVoiceTooLong.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả tối đa {max} ký tự.'**
  String mealVoiceTooLong(int max);

  /// No description provided for @mealVoicePrivacy.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ chữ này được gửi lên Lành để ước lượng món. Kết quả chỉ là ước lượng.'**
  String get mealVoicePrivacy;

  /// No description provided for @mealVoiceSend.
  ///
  /// In vi, this message translates to:
  /// **'Gửi phân tích'**
  String get mealVoiceSend;

  /// No description provided for @mealVoiceRecordAgain.
  ///
  /// In vi, this message translates to:
  /// **'Ghi lại'**
  String get mealVoiceRecordAgain;

  /// No description provided for @mealEstimationReceivedText.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận lời kể'**
  String get mealEstimationReceivedText;

  /// No description provided for @mealEstimationRecognizingText.
  ///
  /// In vi, this message translates to:
  /// **'Nhận diện món từ lời kể'**
  String get mealEstimationRecognizingText;

  /// No description provided for @mealEstimationTextErrorBody.
  ///
  /// In vi, this message translates to:
  /// **'Lành chưa nhận ra món nào trong lời kể. Thử ghi rõ tên món và lượng ăn. Lời kể vẫn được giữ lại.'**
  String get mealEstimationTextErrorBody;

  /// No description provided for @mealEstimationTextNetworkBody.
  ///
  /// In vi, this message translates to:
  /// **'Lành chưa kết nối được máy chủ phân tích. Kiểm tra mạng rồi thử lại. Lời kể vẫn được giữ lại.'**
  String get mealEstimationTextNetworkBody;

  /// No description provided for @mealEstimationTextUnavailableBody.
  ///
  /// In vi, this message translates to:
  /// **'Máy chủ phân tích đang bận hoặc phản hồi quá lâu. Vui lòng thử lại sau ít phút. Lời kể vẫn được giữ lại.'**
  String get mealEstimationTextUnavailableBody;

  /// No description provided for @mealReviewTextDisclaimer.
  ///
  /// In vi, this message translates to:
  /// **'Số liệu là ước tính từ lời kể, có thể lệch so với phần bạn thực ăn.'**
  String get mealReviewTextDisclaimer;

  /// No description provided for @mealReviewVoiceLabel.
  ///
  /// In vi, this message translates to:
  /// **'Bữa ăn từ lời kể'**
  String get mealReviewVoiceLabel;

  /// No description provided for @mealVoicePreparing.
  ///
  /// In vi, this message translates to:
  /// **'Đang mở micro…'**
  String get mealVoicePreparing;

  /// No description provided for @mealVoiceNoAccess.
  ///
  /// In vi, this message translates to:
  /// **'Chạm micro để thử lại, bật quyền trong Cài đặt, hoặc nhập bằng chữ.'**
  String get mealVoiceNoAccess;

  /// No description provided for @mealVoiceSpeakHint.
  ///
  /// In vi, this message translates to:
  /// **'Kể tên món và lượng ăn'**
  String get mealVoiceSpeakHint;

  /// No description provided for @mealVoiceStartAction.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu nói'**
  String get mealVoiceStartAction;

  /// No description provided for @mealVoiceAllowAction.
  ///
  /// In vi, this message translates to:
  /// **'Cho phép micro'**
  String get mealVoiceAllowAction;

  /// No description provided for @mealVoiceReadyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lành sẵn sàng nghe'**
  String get mealVoiceReadyTitle;

  /// No description provided for @mealVoiceNotHeardTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lành chưa nghe rõ'**
  String get mealVoiceNotHeardTitle;

  /// No description provided for @mealVoiceNoAccessTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lành chưa được dùng micro'**
  String get mealVoiceNoAccessTitle;

  /// No description provided for @mealVoiceRecording.
  ///
  /// In vi, this message translates to:
  /// **'Đang ghi âm'**
  String get mealVoiceRecording;

  /// No description provided for @mealVoiceStop.
  ///
  /// In vi, this message translates to:
  /// **'Dừng ghi âm'**
  String get mealVoiceStop;

  /// No description provided for @mealVoiceStopCaption.
  ///
  /// In vi, this message translates to:
  /// **'Chạm để dừng và kiểm tra chữ'**
  String get mealVoiceStopCaption;

  /// No description provided for @mealVoiceStartCaption.
  ///
  /// In vi, this message translates to:
  /// **'Chạm để bắt đầu nói'**
  String get mealVoiceStartCaption;

  /// No description provided for @mealVoiceAllowCaption.
  ///
  /// In vi, this message translates to:
  /// **'Chạm để cho phép micro'**
  String get mealVoiceAllowCaption;

  /// No description provided for @profileBmiEstimateTitle.
  ///
  /// In vi, this message translates to:
  /// **'BMI ước tính'**
  String get profileBmiEstimateTitle;

  /// No description provided for @profileBmiDisclaimer.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính, không thay thế khám sức khỏe.'**
  String get profileBmiDisclaimer;

  /// No description provided for @profileBmiAsianNote.
  ///
  /// In vi, this message translates to:
  /// **'Theo ngưỡng WHO cho người châu Á: bình thường 18,5–22,9.'**
  String get profileBmiAsianNote;

  /// No description provided for @profileReadingAdult.
  ///
  /// In vi, this message translates to:
  /// **'Lành đọc theo người lớn.'**
  String get profileReadingAdult;

  /// No description provided for @profileHeightRange.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao trong khoảng 100–250 cm'**
  String get profileHeightRange;

  /// No description provided for @profileWeightRange.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng trong khoảng 25–350 kg'**
  String get profileWeightRange;

  /// No description provided for @profileTargetModeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Cách đặt mốc'**
  String get profileTargetModeLabel;

  /// No description provided for @profileTargetModeSuggested.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý'**
  String get profileTargetModeSuggested;

  /// No description provided for @profileTargetModeCustom.
  ///
  /// In vi, this message translates to:
  /// **'Tự chọn'**
  String get profileTargetModeCustom;

  /// No description provided for @profileTargetSuggestedFrom.
  ///
  /// In vi, this message translates to:
  /// **'Tính từ cân nặng hiện tại {weight} kg'**
  String profileTargetSuggestedFrom(String weight);

  /// No description provided for @profileTargetPlanGentle.
  ///
  /// In vi, this message translates to:
  /// **'Nhẹ nhàng · {percent}%'**
  String profileTargetPlanGentle(String percent);

  /// No description provided for @profileTargetPlanGainGentle.
  ///
  /// In vi, this message translates to:
  /// **'Tăng nhẹ · {percent}%'**
  String profileTargetPlanGainGentle(String percent);

  /// No description provided for @profileTargetPlanLonger.
  ///
  /// In vi, this message translates to:
  /// **'Mốc dài hơn · {percent}%'**
  String profileTargetPlanLonger(String percent);

  /// No description provided for @profileTargetRateApprox.
  ///
  /// In vi, this message translates to:
  /// **'~{value} kg/tuần'**
  String profileTargetRateApprox(String value);

  /// No description provided for @profileTargetWeeksShort.
  ///
  /// In vi, this message translates to:
  /// **'{count} tuần'**
  String profileTargetWeeksShort(int count);

  /// No description provided for @profileTargetCustomEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chọn một mốc bên dưới.'**
  String get profileTargetCustomEmpty;

  /// No description provided for @profilePlanEstimateTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính kế hoạch'**
  String get profilePlanEstimateTitle;

  /// No description provided for @profileTargetSetDate.
  ///
  /// In vi, this message translates to:
  /// **'Hẹn ngày đạt mục tiêu'**
  String get profileTargetSetDate;

  /// No description provided for @profileTargetDateMoved.
  ///
  /// In vi, this message translates to:
  /// **'Lành đã lùi ngày để vừa sức hơn'**
  String get profileTargetDateMoved;

  /// No description provided for @profileTargetDecrease.
  ///
  /// In vi, this message translates to:
  /// **'Giảm 0,5 kg'**
  String get profileTargetDecrease;

  /// No description provided for @profileTargetIncrease.
  ///
  /// In vi, this message translates to:
  /// **'Tăng 0,5 kg'**
  String get profileTargetIncrease;

  /// No description provided for @profileTargetPerWeek.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi tuần'**
  String get profileTargetPerWeek;

  /// No description provided for @profileTargetNeeds.
  ///
  /// In vi, this message translates to:
  /// **'Cần khoảng'**
  String get profileTargetNeeds;

  /// No description provided for @profileTargetEatPerDay.
  ///
  /// In vi, this message translates to:
  /// **'Ăn mỗi ngày'**
  String get profileTargetEatPerDay;

  /// No description provided for @profileUnitWeeks.
  ///
  /// In vi, this message translates to:
  /// **'tuần'**
  String get profileUnitWeeks;

  /// No description provided for @profilePaceTooFast.
  ///
  /// In vi, this message translates to:
  /// **'Nhanh hơn mức an toàn — chọn ngày muộn hơn'**
  String get profilePaceTooFast;

  /// No description provided for @profileTargetUnavailableLose.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng hiện tại đã ở mức BMI 18,5 theo chiều cao. Lành không gợi ý giảm thêm; hãy cân nhắc Giữ cân hoặc hỏi chuyên gia.'**
  String get profileTargetUnavailableLose;

  /// No description provided for @profileTargetUnavailableGain.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng hiện tại đã ở mức BMI 22,9 theo chiều cao. Lành không gợi ý tăng thêm; hãy cân nhắc Giữ cân hoặc hỏi chuyên gia.'**
  String get profileTargetUnavailableGain;

  /// No description provided for @profileTargetPreviousKept.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu cũ được giữ cho đến khi bạn xác nhận ở bước cuối.'**
  String get profileTargetPreviousKept;

  /// No description provided for @profileActivitySittingHint.
  ///
  /// In vi, this message translates to:
  /// **'Làm văn phòng, ít đi lại'**
  String get profileActivitySittingHint;

  /// No description provided for @profileActivityLightHint.
  ///
  /// In vi, this message translates to:
  /// **'Đi lại nhẹ, làm việc nhà'**
  String get profileActivityLightHint;

  /// No description provided for @profileActivityModerateHint.
  ///
  /// In vi, this message translates to:
  /// **'Bán hàng, phục vụ, đi bộ nhiều'**
  String get profileActivityModerateHint;

  /// No description provided for @profileActivityHeavyHint.
  ///
  /// In vi, this message translates to:
  /// **'Xây dựng, làm nông, tập luyện nặng'**
  String get profileActivityHeavyHint;

  /// No description provided for @profileActivityVariableHint.
  ///
  /// In vi, this message translates to:
  /// **'Lành tính theo mức thấp để an toàn'**
  String get profileActivityVariableHint;

  /// No description provided for @profileEnergyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cơ thể bạn dùng khoảng'**
  String get profileEnergyTitle;

  /// No description provided for @profileEnergyUnit.
  ///
  /// In vi, this message translates to:
  /// **'kcal/ngày'**
  String get profileEnergyUnit;

  /// No description provided for @profileEnergyCaption.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính, không thay thế tư vấn dinh dưỡng.'**
  String get profileEnergyCaption;

  /// No description provided for @profileEnergyPickActivity.
  ///
  /// In vi, this message translates to:
  /// **'Chọn một mức để xem năng lượng ước tính.'**
  String get profileEnergyPickActivity;

  /// No description provided for @profileTargetDailyKcal.
  ///
  /// In vi, this message translates to:
  /// **'≈ {kcal} kcal/ngày'**
  String profileTargetDailyKcal(String kcal);

  /// No description provided for @profileTargetEnergyLimited.
  ///
  /// In vi, this message translates to:
  /// **'Lành kéo dài kế hoạch để bạn vẫn ăn ít nhất khoảng {kcal} kcal/ngày.'**
  String profileTargetEnergyLimited(String kcal);

  /// No description provided for @profileTargetUnavailableEnergy.
  ///
  /// In vi, this message translates to:
  /// **'Với mức vận động này, giảm cân sẽ cần ăn dưới mức an toàn (khoảng {kcal} kcal/ngày). Hãy cân nhắc Giữ cân, vận động nhiều hơn hoặc hỏi chuyên gia.'**
  String profileTargetUnavailableEnergy(String kcal);

  /// No description provided for @profileTargetPlanModerate.
  ///
  /// In vi, this message translates to:
  /// **'Vừa phải · {percent}%'**
  String profileTargetPlanModerate(String percent);

  /// No description provided for @profileAgeEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tuổi của bạn'**
  String get profileAgeEmpty;

  /// No description provided for @profileHeightEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Nhập chiều cao của bạn'**
  String get profileHeightEmpty;

  /// No description provided for @profileWeightEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Nhập cân nặng của bạn'**
  String get profileWeightEmpty;

  /// No description provided for @planTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kế hoạch của bạn'**
  String get planTitle;

  /// No description provided for @planDailyLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi ngày nên nạp'**
  String get planDailyLabel;

  /// No description provided for @planBodyUsesApprox.
  ///
  /// In vi, this message translates to:
  /// **'Cơ thể dùng ~{kcal}'**
  String planBodyUsesApprox(String kcal);

  /// No description provided for @planBodyUses.
  ///
  /// In vi, this message translates to:
  /// **'Cơ thể dùng {kcal}'**
  String planBodyUses(String kcal);

  /// No description provided for @planEat.
  ///
  /// In vi, this message translates to:
  /// **'Nạp {kcal}'**
  String planEat(String kcal);

  /// No description provided for @planCut.
  ///
  /// In vi, this message translates to:
  /// **'Bớt {kcal}'**
  String planCut(String kcal);

  /// No description provided for @planAdd.
  ///
  /// In vi, this message translates to:
  /// **'Thêm {kcal}'**
  String planAdd(String kcal);

  /// No description provided for @planMatchesBody.
  ///
  /// In vi, this message translates to:
  /// **'Bằng mức cơ thể dùng'**
  String get planMatchesBody;

  /// No description provided for @planTileTarget.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu'**
  String get planTileTarget;

  /// No description provided for @planTilePerWeek.
  ///
  /// In vi, this message translates to:
  /// **'mỗi tuần'**
  String get planTilePerWeek;

  /// No description provided for @planTileDue.
  ///
  /// In vi, this message translates to:
  /// **'Dự kiến'**
  String get planTileDue;

  /// No description provided for @planTileHold.
  ///
  /// In vi, this message translates to:
  /// **'Giữ quanh'**
  String get planTileHold;

  /// No description provided for @planTileActivity.
  ///
  /// In vi, this message translates to:
  /// **'Vận động'**
  String get planTileActivity;

  /// No description provided for @planTileGoal.
  ///
  /// In vi, this message translates to:
  /// **'Mong muốn'**
  String get planTileGoal;

  /// No description provided for @planTileNow.
  ///
  /// In vi, this message translates to:
  /// **'Hiện tại'**
  String get planTileNow;

  /// No description provided for @planTileBmi.
  ///
  /// In vi, this message translates to:
  /// **'BMI'**
  String get planTileBmi;

  /// No description provided for @planBmiShortUnderweight.
  ///
  /// In vi, this message translates to:
  /// **'Dưới vùng khỏe'**
  String get planBmiShortUnderweight;

  /// No description provided for @planBmiShortHealthy.
  ///
  /// In vi, this message translates to:
  /// **'Thường gặp'**
  String get planBmiShortHealthy;

  /// No description provided for @planBmiShortOverweight.
  ///
  /// In vi, this message translates to:
  /// **'Cao hơn'**
  String get planBmiShortOverweight;

  /// No description provided for @planBmiShortObesity.
  ///
  /// In vi, this message translates to:
  /// **'Cần đánh giá'**
  String get planBmiShortObesity;

  /// No description provided for @planNoKcalTitle.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi, không đếm kcal'**
  String get planNoKcalTitle;

  /// No description provided for @planNoKcalTeen.
  ///
  /// In vi, this message translates to:
  /// **'Giai đoạn này cần đủ năng lượng. Hỏi chuyên gia khi cần.'**
  String get planNoKcalTeen;

  /// No description provided for @planStart.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu'**
  String get planStart;

  /// No description provided for @planEdit.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh lại'**
  String get planEdit;

  /// No description provided for @profileActivityShortSitting.
  ///
  /// In vi, this message translates to:
  /// **'Chủ yếu ngồi'**
  String get profileActivityShortSitting;

  /// No description provided for @profileActivityShortLight.
  ///
  /// In vi, this message translates to:
  /// **'Đi lại vừa'**
  String get profileActivityShortLight;

  /// No description provided for @profileActivityShortModerate.
  ///
  /// In vi, this message translates to:
  /// **'Đi lại nhiều'**
  String get profileActivityShortModerate;

  /// No description provided for @profileActivityShortHeavy.
  ///
  /// In vi, this message translates to:
  /// **'Lao động nặng'**
  String get profileActivityShortHeavy;

  /// No description provided for @profileActivityShortVariable.
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi'**
  String get profileActivityShortVariable;

  /// No description provided for @todayOfTarget.
  ///
  /// In vi, this message translates to:
  /// **'/ {target} kcal'**
  String todayOfTarget(String target);

  /// No description provided for @todayFirstMealTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ghi bữa đầu tiên hôm nay'**
  String get todayFirstMealTitle;

  /// No description provided for @todayFirstMealBody.
  ///
  /// In vi, this message translates to:
  /// **'Chụp ảnh, nói hoặc tìm món — Lành ước tính kcal cho bạn.'**
  String get todayFirstMealBody;

  /// No description provided for @profileSwitchToMaintain.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển sang Giữ cân'**
  String get profileSwitchToMaintain;

  /// No description provided for @todayGoalGain.
  ///
  /// In vi, this message translates to:
  /// **'Tăng cân'**
  String get todayGoalGain;

  /// No description provided for @todayGoalLose.
  ///
  /// In vi, this message translates to:
  /// **'Giảm cân'**
  String get todayGoalLose;

  /// No description provided for @todayGoalMaintain.
  ///
  /// In vi, this message translates to:
  /// **'Giữ cân'**
  String get todayGoalMaintain;

  /// No description provided for @todayKcal.
  ///
  /// In vi, this message translates to:
  /// **'kcal'**
  String get todayKcal;

  /// No description provided for @todayGainLeft.
  ///
  /// In vi, this message translates to:
  /// **'Còn {kcal} kcal nữa là đạt mục tiêu'**
  String todayGainLeft(String kcal);

  /// No description provided for @todayGainReached.
  ///
  /// In vi, this message translates to:
  /// **'Đã đạt mục tiêu hôm nay'**
  String get todayGainReached;

  /// No description provided for @todayLoseLeft.
  ///
  /// In vi, this message translates to:
  /// **'Còn {kcal} kcal trong kế hoạch'**
  String todayLoseLeft(String kcal);

  /// No description provided for @todayLoseAtPlan.
  ///
  /// In vi, this message translates to:
  /// **'Vừa đủ kế hoạch hôm nay'**
  String get todayLoseAtPlan;

  /// No description provided for @todayLoseOver.
  ///
  /// In vi, this message translates to:
  /// **'Hơn kế hoạch {kcal} kcal hôm nay'**
  String todayLoseOver(String kcal);

  /// No description provided for @todayMaintainBelow.
  ///
  /// In vi, this message translates to:
  /// **'Thêm {range} kcal là vào dải'**
  String todayMaintainBelow(String range);

  /// No description provided for @todayMaintainWithin.
  ///
  /// In vi, this message translates to:
  /// **'Đang trong dải duy trì'**
  String get todayMaintainWithin;

  /// No description provided for @todayMaintainAbove.
  ///
  /// In vi, this message translates to:
  /// **'Hơn dải {kcal} kcal hôm nay'**
  String todayMaintainAbove(String kcal);

  /// No description provided for @todayMaintainRangeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Dải duy trì {range}'**
  String todayMaintainRangeLabel(String range);

  /// No description provided for @todaySavedMeal.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu {meal} · {kcal} kcal'**
  String todaySavedMeal(String meal, String kcal);

  /// No description provided for @todaySavedMealNoKcal.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu {meal}'**
  String todaySavedMealNoKcal(String meal);

  /// No description provided for @waterAmount.
  ///
  /// In vi, this message translates to:
  /// **'{amount} / {goal} ml'**
  String waterAmount(String amount, String goal);

  /// No description provided for @waterReached.
  ///
  /// In vi, this message translates to:
  /// **'Đã đủ nước hôm nay'**
  String get waterReached;

  /// No description provided for @waterGlassEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Cốc {number}, chưa uống. Chạm để thêm 250 ml'**
  String waterGlassEmpty(String number);

  /// No description provided for @waterGlassFull.
  ///
  /// In vi, this message translates to:
  /// **'Cốc {number}, đã uống. Chạm để bỏ'**
  String waterGlassFull(String number);

  /// No description provided for @waterReadError.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đọc được nước hôm nay.'**
  String get waterReadError;

  /// No description provided for @waterSaveError.
  ///
  /// In vi, this message translates to:
  /// **'Chưa lưu được nước. Thử lại nhé.'**
  String get waterSaveError;

  /// No description provided for @menuHabits.
  ///
  /// In vi, this message translates to:
  /// **'Thói quen'**
  String get menuHabits;

  /// No description provided for @menuApp.
  ///
  /// In vi, this message translates to:
  /// **'Ứng dụng'**
  String get menuApp;

  /// No description provided for @menuGoal.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu'**
  String get menuGoal;

  /// No description provided for @menuGoalSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'{goal} · đổi hoặc bỏ bất cứ lúc nào'**
  String menuGoalSubtitle(String goal);

  /// No description provided for @menuGoalNone.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đặt mục tiêu · đặt bất cứ lúc nào'**
  String get menuGoalNone;

  /// No description provided for @menuPrivacy.
  ///
  /// In vi, this message translates to:
  /// **'Riêng tư'**
  String get menuPrivacy;

  /// No description provided for @menuHelp.
  ///
  /// In vi, this message translates to:
  /// **'Trợ giúp'**
  String get menuHelp;

  /// No description provided for @menuHelpSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Hỏi đáp và gửi phản hồi'**
  String get menuHelpSubtitle;

  /// No description provided for @waterReminderTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc uống nước'**
  String get waterReminderTitle;

  /// No description provided for @waterReminderSchedule.
  ///
  /// In vi, this message translates to:
  /// **'{start} – {end} · mỗi {hours} giờ'**
  String waterReminderSchedule(String start, String end, int hours);

  /// No description provided for @waterReminderNext.
  ///
  /// In vi, this message translates to:
  /// **'Đang bật · lần tới {time}'**
  String waterReminderNext(String time);

  /// No description provided for @waterReminderEnabled.
  ///
  /// In vi, this message translates to:
  /// **'Đã bật nhắc uống nước'**
  String get waterReminderEnabled;

  /// No description provided for @waterReminderDenied.
  ///
  /// In vi, this message translates to:
  /// **'Lành chưa được gửi thông báo. Bật trong Cài đặt để nhận nhắc.'**
  String get waterReminderDenied;

  /// No description provided for @waterReminderOpenSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get waterReminderOpenSettings;

  /// No description provided for @waterReminderError.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đổi được nhắc uống nước. Thử lại nhé.'**
  String get waterReminderError;

  /// No description provided for @waterReminderChannel.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc uống nước'**
  String get waterReminderChannel;

  /// No description provided for @waterReminderNotificationTitle.
  ///
  /// In vi, this message translates to:
  /// **'Uống một cốc nước nhé 💧'**
  String get waterReminderNotificationTitle;

  /// No description provided for @waterReminderNotificationBody.
  ///
  /// In vi, this message translates to:
  /// **'Chạm để ghi vào Lành.'**
  String get waterReminderNotificationBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
