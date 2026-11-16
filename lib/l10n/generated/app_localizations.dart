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
  /// **'Mỗi bữa lành, một mầm vui.'**
  String get welcomeHeadline;

  /// No description provided for @welcomeBody.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu từ bữa bạn vừa ăn, hoặc đặt một hướng riêng. Không cần nhập cân nặng.'**
  String get welcomeBody;

  /// No description provided for @welcomeGoalUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Đặt mục tiêu của tôi (Sắp có)'**
  String get welcomeGoalUnavailable;

  /// No description provided for @welcomeLogFirstMeal.
  ///
  /// In vi, this message translates to:
  /// **'Ghi bữa ăn đầu tiên'**
  String get welcomeLogFirstMeal;

  /// No description provided for @saving.
  ///
  /// In vi, this message translates to:
  /// **'Đang lưu…'**
  String get saving;

  /// No description provided for @welcomeDisclaimer.
  ///
  /// In vi, this message translates to:
  /// **'Mọi con số calo trong Lành là ước tính, chỉ mang tính tham khảo.'**
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
  /// **'Ghi bữa'**
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
  /// **'Bạn muốn ghi bữa bằng cách nào?'**
  String get chooseMealMethod;

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

  /// No description provided for @comingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Sắp có'**
  String get comingSoon;

  /// No description provided for @mealMethodsNotice.
  ///
  /// In vi, this message translates to:
  /// **'Các cách ghi bữa sẽ được phát triển ở phiên bản tiếp theo. Hiện ứng dụng chưa xin quyền camera hoặc gửi ảnh.'**
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
  /// **'Bản nền tảng chỉ lưu việc bạn đã xem phần giới thiệu. Chưa thu thập ảnh bữa ăn, cân nặng hoặc dữ liệu sức khỏe.'**
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
