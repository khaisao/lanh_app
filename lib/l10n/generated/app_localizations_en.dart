// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lành';

  @override
  String get welcomeHeadline => 'A little joy in every nourishing meal.';

  @override
  String get welcomeBody =>
      'Start with the meal you just ate, or set a goal of your own. No need to enter your weight.';

  @override
  String get welcomeGoalUnavailable => 'Set my goal';

  @override
  String get welcomeLogFirstMeal => 'Log my first meal';

  @override
  String get saving => 'Saving…';

  @override
  String get welcomeDisclaimer =>
      'Calorie values in Lành are estimates for reference only.';

  @override
  String get saveIntroductionError =>
      'Your choice could not be saved. Please try again.';

  @override
  String get startupError =>
      'Your settings could not be loaded. Try again to continue.';

  @override
  String get retry => 'Try again';

  @override
  String get today => 'Today';

  @override
  String get progress => 'Progress';

  @override
  String get achievements => 'Achievements';

  @override
  String get menu => 'Menu';

  @override
  String get logMeal => 'Log meal';

  @override
  String get todayHeading => 'Your day';

  @override
  String get todayEmptyTitle => 'Start with one meal';

  @override
  String get todayEmptyBody =>
      'Your journal is empty. Logged meals and calorie totals will appear here.';

  @override
  String get progressEmptyTitle => 'Progress begins with you';

  @override
  String get progressEmptyBody =>
      'There is no data to summarize yet. Days without meal logs will not count as zero calories.';

  @override
  String get achievementsEmptyTitle => 'Small steps matter';

  @override
  String get achievementsEmptyBody =>
      'Milestones will celebrate self-care habits without judging how little or how much you eat.';

  @override
  String get baseNotice =>
      'This is the foundation build. Meal logging and health tracking are not implemented yet.';

  @override
  String get chooseMealMethod => 'How would you like to log your meal?';

  @override
  String get close => 'Close';

  @override
  String get camera => 'Take a photo';

  @override
  String get gallery => 'Choose a photo';

  @override
  String get search => 'Search foods';

  @override
  String get manual => 'Enter manually';

  @override
  String get templates => 'Saved meals';

  @override
  String get mealMethodsNotice =>
      'Meal logging methods will arrive in a later version. This build does not request camera access or upload photos.';

  @override
  String get about => 'About Lành';

  @override
  String get aboutBody =>
      'Lành supports mindful eating and self-care. Your intention may be to lose, gain or maintain weight, or simply understand your meals.';

  @override
  String get privacyBase =>
      'This foundation build stores your goal choice and introduction status on this device. Meal photos and health data are not synced yet.';

  @override
  String get notFound => 'Page not found';

  @override
  String get backToToday => 'Go to Today';
}
