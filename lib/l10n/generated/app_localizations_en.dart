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
      'Get to know your meals a little at a time. No weight needed to get started.';

  @override
  String get welcomeGoalAction => 'Set my goal';

  @override
  String get saving => 'Saving…';

  @override
  String get welcomeDisclaimer => 'All calorie counts in Lành are estimates.';

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
  String get chooseMealMethod => 'Log a meal';

  @override
  String get mealMethodSubtitle => 'Choose how to start';

  @override
  String get mealPhotoDescription => 'Lành estimates the food in your photo';

  @override
  String get mealVoice => 'Log by voice';

  @override
  String get mealVoiceDescription => 'Say what you ate and how much';

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
  String get mealMethodsNotice => 'Photo and voice logging · Coming soon';

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

  @override
  String get profileGoal => 'Goal';

  @override
  String get profileGoalHeading => 'What would you like?';

  @override
  String get profileGoalCaption => 'You can change this any time.';

  @override
  String get profileGain => 'Gain weight';

  @override
  String get profileLose => 'Lose weight';

  @override
  String get profileMaintain => 'Maintain weight';

  @override
  String get profileBody => 'About you';

  @override
  String get profileBodyCaption => 'Used for estimates only.';

  @override
  String get profileAge => 'Age';

  @override
  String get profileYears => 'years';

  @override
  String get profileHeight => 'Height';

  @override
  String get profileCurrentWeight => 'Current weight';

  @override
  String get profileSex => 'Sex';

  @override
  String get profileFemale => 'Female';

  @override
  String get profileMale => 'Male';

  @override
  String get profileTarget => 'Your target';

  @override
  String get profileTargetWeight => 'Target weight';

  @override
  String get profileTargetDate => 'Target date';

  @override
  String get profilePickDate => 'Choose a date';

  @override
  String get profileWeeklyEstimate => 'Weekly estimate';

  @override
  String get profileEstimate => 'Estimate';

  @override
  String get profileEstimateCaption => 'For planning only, not medical advice.';

  @override
  String get profileActivity => 'Daily activity';

  @override
  String get profileActivityHeading => 'A typical day';

  @override
  String get profileActivityCaption => 'Choose the closest match.';

  @override
  String get profileSitting => 'Mostly sitting';

  @override
  String get profileLight => 'Some standing and walking';

  @override
  String get profileModerate => 'Standing or walking most of the day';

  @override
  String get profileHeavy => 'Regular physical work';

  @override
  String get profileVariable => 'Schedule varies / Not sure';

  @override
  String get profileContinue => 'Continue';

  @override
  String get profileConfirm => 'Confirm';

  @override
  String get profileBack => 'Go back';

  @override
  String profileStepStatus(int step) {
    return 'Step $step of 4';
  }

  @override
  String profileEditStep(String title) {
    return 'Edit: $title';
  }

  @override
  String get profileInvalidAge => 'Enter an age in whole years.';

  @override
  String get profileInvalidNumber => 'Enter a number greater than zero.';

  @override
  String get profileMissingSex => 'Choose an option to continue.';

  @override
  String get profileLowerTarget =>
      'Target weight must be below current weight.';

  @override
  String get profileHigherTarget =>
      'Target weight must be above current weight.';

  @override
  String get profileFutureDate => 'Choose a date after today.';

  @override
  String get profileReview => 'Review your information';

  @override
  String get profileReviewNotice =>
      'This information will be saved on your device.';

  @override
  String get profileSaveError =>
      'Could not finish saving your profile. Try again.';

  @override
  String get todayGreeting => 'Hello';

  @override
  String get todayGainGoal => 'Weight gain goal';

  @override
  String get todayLosePlan => 'Today’s plan';

  @override
  String get todayMaintainRange => 'Maintenance range';

  @override
  String get todayEnergy => 'Today’s energy';

  @override
  String get todayTargetUnavailable => 'No calorie target yet.';

  @override
  String get todayRangeUnavailable => 'No maintenance range yet.';

  @override
  String get todayLoadingProfile => 'Loading profile…';

  @override
  String get todayProfileReadError => 'Could not load your profile.';

  @override
  String get todayNoEnergy => '—';

  @override
  String get todayLoggedKcal => 'kcal logged';

  @override
  String get todayNoWater => 'Nothing logged';

  @override
  String get todayWater => 'Water';

  @override
  String get todayNoMeals => 'No food logged today.';

  @override
  String get todayJournal => 'Food journal';

  @override
  String get todayDetails => 'Details';

  @override
  String get todayEstimated => 'Estimated';
}
