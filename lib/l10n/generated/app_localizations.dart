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
  /// **'Lành ước lượng món trong ảnh'**
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

  /// No description provided for @mealMethodsNotice.
  ///
  /// In vi, this message translates to:
  /// **'Chụp ảnh và ghi bằng giọng nói · Sắp có'**
  String get mealMethodsNotice;

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
