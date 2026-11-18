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

  /// No description provided for @saveIntroductionError.
  ///
  /// In vi, this message translates to:
  /// **'Chưa lưu được lựa chọn. Vui lòng thử lại.'**
  String get saveIntroductionError;

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

  /// No description provided for @todayHeading.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay của bạn'**
  String get todayHeading;

  /// No description provided for @todayEmptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu từ một bữa ăn'**
  String get todayEmptyTitle;

  /// No description provided for @todayEmptyBody.
  ///
  /// In vi, this message translates to:
  /// **'Nhật ký của bạn đang trống. Sau khi ghi bữa, tổng calo và các món sẽ xuất hiện ở đây.'**
  String get todayEmptyBody;

  /// No description provided for @progressEmptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tiến trình bắt đầu từ bạn'**
  String get progressEmptyTitle;

  /// No description provided for @progressEmptyBody.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu để tổng hợp. Ngày chưa ghi bữa sẽ không được tính là 0 calo.'**
  String get progressEmptyBody;

  /// No description provided for @achievementsEmptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi bước nhỏ đều đáng nhớ'**
  String get achievementsEmptyTitle;

  /// No description provided for @achievementsEmptyBody.
  ///
  /// In vi, this message translates to:
  /// **'Các cột mốc sẽ ghi nhận thói quen chăm sóc bản thân, không đánh giá việc ăn ít hay nhiều.'**
  String get achievementsEmptyBody;

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

  /// No description provided for @search.
  ///
  /// In vi, this message translates to:
  /// **'Tìm món ăn'**
  String get search;

  /// No description provided for @manual.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tay'**
  String get manual;

  /// No description provided for @templates.
  ///
  /// In vi, this message translates to:
  /// **'Bữa quen'**
  String get templates;

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

  /// No description provided for @privacyBase.
  ///
  /// In vi, this message translates to:
  /// **'Bản nền tảng lưu lựa chọn mục tiêu và việc bạn đã xem phần giới thiệu trên thiết bị. Ảnh bữa ăn và dữ liệu sức khỏe chưa được đồng bộ.'**
  String get privacyBase;

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

  /// No description provided for @profileGoalCaption.
  ///
  /// In vi, this message translates to:
  /// **'Đổi được bất cứ lúc nào.'**
  String get profileGoalCaption;

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

  /// No description provided for @profileBodyCaption.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ để ước tính.'**
  String get profileBodyCaption;

  /// No description provided for @profileAge.
  ///
  /// In vi, this message translates to:
  /// **'Tuổi'**
  String get profileAge;

  /// No description provided for @profileYears.
  ///
  /// In vi, this message translates to:
  /// **'năm'**
  String get profileYears;

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

  /// No description provided for @profilePickDate.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày'**
  String get profilePickDate;

  /// No description provided for @profileWeeklyEstimate.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính mỗi tuần'**
  String get profileWeeklyEstimate;

  /// No description provided for @profileEstimate.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính'**
  String get profileEstimate;

  /// No description provided for @profileEstimateCaption.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ để lên kế hoạch, không phải chỉ dẫn y tế.'**
  String get profileEstimateCaption;

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

  /// No description provided for @profileActivityCaption.
  ///
  /// In vi, this message translates to:
  /// **'Chọn mức gần nhất.'**
  String get profileActivityCaption;

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
  /// **'Nhập tuổi bằng số nguyên dương.'**
  String get profileInvalidAge;

  /// No description provided for @profileInvalidNumber.
  ///
  /// In vi, this message translates to:
  /// **'Nhập một số lớn hơn 0.'**
  String get profileInvalidNumber;

  /// No description provided for @profileMissingSex.
  ///
  /// In vi, this message translates to:
  /// **'Chọn giới tính để tiếp tục.'**
  String get profileMissingSex;

  /// No description provided for @profileLowerTarget.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng mong muốn phải thấp hơn cân hiện tại.'**
  String get profileLowerTarget;

  /// No description provided for @profileHigherTarget.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng mong muốn phải cao hơn cân hiện tại.'**
  String get profileHigherTarget;

  /// No description provided for @profileFutureDate.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày sau hôm nay.'**
  String get profileFutureDate;

  /// No description provided for @profileReview.
  ///
  /// In vi, this message translates to:
  /// **'Xem lại thông tin'**
  String get profileReview;

  /// No description provided for @profileReviewNotice.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin này sẽ được lưu trên thiết bị.'**
  String get profileReviewNotice;

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

  /// No description provided for @todayGainGoal.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu tăng cân'**
  String get todayGainGoal;

  /// No description provided for @todayLosePlan.
  ///
  /// In vi, this message translates to:
  /// **'Kế hoạch hôm nay'**
  String get todayLosePlan;

  /// No description provided for @todayMaintainRange.
  ///
  /// In vi, this message translates to:
  /// **'Dải duy trì'**
  String get todayMaintainRange;

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

  /// No description provided for @todayNoMeals.
  ///
  /// In vi, this message translates to:
  /// **'Chưa ghi món nào hôm nay.'**
  String get todayNoMeals;

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

  /// No description provided for @mealReviewSaveSoon.
  ///
  /// In vi, this message translates to:
  /// **'Lưu bữa ăn · Sắp có'**
  String get mealReviewSaveSoon;

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
  /// **'Lành nghe xong rồi'**
  String get mealVoiceConfirmHeading;

  /// No description provided for @mealVoiceConfirmBody.
  ///
  /// In vi, this message translates to:
  /// **'Sửa chữ nếu chưa đúng trước khi gửi.'**
  String get mealVoiceConfirmBody;

  /// No description provided for @mealVoiceConfirmHint.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả chỉ là ước lượng, bạn kiểm tra trước khi lưu.'**
  String get mealVoiceConfirmHint;

  /// No description provided for @mealVoiceTypedBody.
  ///
  /// In vi, this message translates to:
  /// **'Ghi tên món và lượng ăn để Lành ước lượng.'**
  String get mealVoiceTypedBody;

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
  /// **'Chỉ chữ này được gửi lên Lành để ước lượng món.'**
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
