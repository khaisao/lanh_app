// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get mealPhotoSwitchCamera => 'Switch front or rear camera';

  @override
  String get mealPhotoSwitching => 'Switching camera…';

  @override
  String get mealPhotoSwitchError =>
      'Could not switch cameras. Please try again.';

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
  String get mealPhotoDescription => 'Take or choose a meal photo';

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
  String get mealPhotoBack => 'Back';

  @override
  String get mealPhotoPermissionTitle => 'Allow Lành to use your camera?';

  @override
  String get mealPhotoPermissionBody =>
      'Lành uses the camera to take a meal photo. You can also choose a photo from your library.';

  @override
  String get mealPhotoPermissionDenied =>
      'Camera access was declined. You can try again or choose a photo from your library.';

  @override
  String get mealPhotoPermissionBlocked =>
      'Camera access is turned off for Lành. You can enable it in Settings or choose a photo from your library.';

  @override
  String get mealPhotoPermissionRestricted =>
      'Your device restricts camera access. You can still choose a photo from your library.';

  @override
  String get mealPhotoCameraUnavailable =>
      'Lành couldn’t open the camera. Try again or choose a photo from your library.';

  @override
  String get mealPhotoAllowCamera => 'Allow camera';

  @override
  String get mealPhotoOpenSettings => 'Open Settings';

  @override
  String get mealPhotoChoose => 'Choose from photo library';

  @override
  String get mealPhotoCameraLoading => 'Opening camera';

  @override
  String get mealPhotoReviewLabel => 'Meal photo preview';

  @override
  String get mealPhotoCaptured => 'Photo captured';

  @override
  String get mealPhotoReadyTitle => 'Your photo is ready';

  @override
  String get mealPhotoReadyBody =>
      'Lành will estimate calories from this photo. Results are estimates; review them before saving.';

  @override
  String get mealPhotoEstimate => 'Estimate meal';

  @override
  String get mealPhotoRetake => 'Retake photo';

  @override
  String get mealPhotoReplace => 'Choose another photo';

  @override
  String get mealPhotoPickError =>
      'Lành couldn’t open this photo. Choose another photo.';

  @override
  String get mealPhotoCaptureError =>
      'Lành couldn’t take the photo. Please try again.';

  @override
  String get mealPhotoCaptureTimeout =>
      'The camera did not return a photo. Try again or choose a photo from your library.';

  @override
  String get mealPhotoCapturing => 'Taking photo…';

  @override
  String get mealPhotoLoading => 'Opening photo…';

  @override
  String get mealPhotoSettingsError =>
      'Lành couldn’t open Settings. You can open Settings on your device.';

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
  String get profileBmiAdultUnderweight => 'Below the healthy range';

  @override
  String get profileBmiAdultHealthy => 'Within the common range';

  @override
  String get profileBmiAdultOverweight => 'Above the healthy range';

  @override
  String get profileBmiAdultObesity => 'Needs professional review';

  @override
  String get profileBmiTeenHint =>
      'Ages 13–19: Lành reads BMI for age and sex (CDC), not adult ranges.';

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
  String get profileEstimate => 'Estimate';

  @override
  String get profileEstimateCaption => 'For planning only, not medical advice.';

  @override
  String get profileActivity => 'Daily activity';

  @override
  String get profileActivityHeading => 'A typical day';

  @override
  String get profileActivityCaption =>
      'Pick the closest match so Lành can estimate your daily energy.';

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
  String get profileInvalidAge => 'That age doesn\'t look right';

  @override
  String get profileAgeTooYoung => 'Lành is for ages 13 and up';

  @override
  String get profileMissingSex => 'Choose an option to continue.';

  @override
  String get profileReview => 'Review your information';

  @override
  String get profileReviewNotice =>
      'This information will be saved on your device.';

  @override
  String get profileTeenGuidanceTitle => 'A safer goal while you grow';

  @override
  String get profileTeenUnderweightGain =>
      'Your age-based measure is below the reference range. Prioritize enough food and talk with a trusted adult or health professional; Lành will not set an automatic gain rate for a growing body.';

  @override
  String get profileTeenUnderweightLose =>
      'Lành does not recommend setting a weight-loss goal when the age-based measure is below the reference range. Talk with a trusted adult or health professional.';

  @override
  String get profileTeenHealthy =>
      'Your age-based measure is in the reference range. While you are growing, Lành prioritizes steady routines and healthy growth over forcing a weight change.';

  @override
  String get profileTeenOverweightLose =>
      'Lành will focus on healthy routines and growth over time. Any weight-change goal should be discussed with family and a health professional.';

  @override
  String get profileTeenOverweightGain =>
      'Lành will not set an automatic gain goal when the age-based measure is above the reference range. Talk with family and a health professional.';

  @override
  String get profileTeenBmiStatusUnderweight =>
      'Below the age-based reference range';

  @override
  String get profileTeenBmiStatusHealthy =>
      'Within the age-based reference range';

  @override
  String get profileTeenBmiStatusOverweight =>
      'Above the age-based reference range';

  @override
  String get profileTeenBmiStatusObesity => 'Needs professional review';

  @override
  String profileEstimateDate(String date) {
    return 'Expected $date';
  }

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
  String get todayMealReadError => 'Could not load today’s food journal.';

  @override
  String get todayJournal => 'Food journal';

  @override
  String get todayDetails => 'Details';

  @override
  String get todayEstimated => 'Estimated';

  @override
  String get mealEstimationNotice => 'Results are estimates';

  @override
  String get mealEstimatingTitle => 'Lành is estimating';

  @override
  String get mealEstimatingBody =>
      'This usually takes a few seconds. You’ll review the result before saving.';

  @override
  String get mealEstimationErrorTitle => 'Couldn’t estimate this meal';

  @override
  String get mealEstimationErrorBody =>
      'Lành couldn’t see this meal clearly. Try taking a closer photo or using better lighting. Your photo is still here.';

  @override
  String get mealEstimationCancel => 'Cancel analysis';

  @override
  String get mealEstimationReceived => 'Photo received';

  @override
  String get mealEstimationRecognizing => 'Identifying foods in the photo';

  @override
  String get mealEstimationPortion => 'Estimating portions';

  @override
  String get mealEstimationCalories => 'Calculating estimated calories';

  @override
  String get mealEstimationDone => 'Done';

  @override
  String get mealEstimationWorking => 'Working';

  @override
  String get mealEstimationWaiting => 'Waiting';

  @override
  String get mealEstimationNetworkBody =>
      'Lành couldn’t reach the analysis server. Check your connection and try again. Your photo is still here.';

  @override
  String get mealEstimationUnavailableBody =>
      'The analysis server is busy or took too long. Please try again in a few minutes. Your photo is still here.';

  @override
  String get mealEstimationInvalidPhotoBody =>
      'Lành couldn’t read this photo. Retake it or choose another photo.';

  @override
  String get mealEstimationNotConfiguredBody =>
      'This build has no meal analysis server configured.';

  @override
  String get mealReviewTitle => 'Review meal';

  @override
  String get mealReviewPhotoLabel => 'Meal photo';

  @override
  String get mealReviewEstimateBadge => 'Estimate';

  @override
  String get mealReviewKcal => 'kcal';

  @override
  String get mealReviewUnknown => 'Unknown';

  @override
  String mealReviewItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get mealReviewPortionGroup => 'Choose the whole-meal portion';

  @override
  String get mealReviewPortionHalf => 'Half';

  @override
  String get mealReviewPortionOne => '1 portion';

  @override
  String get mealReviewPortionOneHalf => '1.5 portions';

  @override
  String get mealReviewItemsTitle => 'Items';

  @override
  String mealReviewMissingCalories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items have no calories and aren’t in the total.',
      one: '1 item has no calories and isn’t in the total.',
    );
    return '$_temp0';
  }

  @override
  String get mealReviewDisclaimer =>
      'These numbers are estimated from the photo and may differ from what you actually ate.';

  @override
  String get mealReviewSaveSoon => 'Save meal · Coming soon';

  @override
  String get mealReviewSave => 'Save meal';

  @override
  String get mealReviewSaveError =>
      'Could not save this meal. Please try again.';

  @override
  String get mealReviewDiscard => 'Cancel, don’t save';

  @override
  String get mealUnitGram => 'g';

  @override
  String get mealUnitMilliliter => 'ml';

  @override
  String get mealUnitServing => 'serving';

  @override
  String get mealUnitPiece => 'piece';

  @override
  String get mealReviewClose => 'Close without saving';

  @override
  String get mealReviewEnergy => 'Total energy';

  @override
  String get mealReviewNutrients => 'Nutrients';

  @override
  String mealReviewNutrientsLabel(String protein, String carbs, String fat) {
    return 'Protein $protein, carbs $carbs, fat $fat';
  }

  @override
  String get mealReviewProtein => 'Protein';

  @override
  String get mealReviewCarbs => 'Carbs';

  @override
  String get mealReviewFat => 'Fat';

  @override
  String get mealReviewFatShort => 'Fat';

  @override
  String mealReviewNameJoin(String first, String last) {
    return '$first and $last';
  }

  @override
  String get mealReviewAddToday => 'Add to today';

  @override
  String mealReviewMacroChip(String label, String value) {
    return '$label $value';
  }

  @override
  String get mealVoiceTitle => 'Voice log';

  @override
  String mealVoiceTimerLabel(Object seconds) {
    return 'Recorded $seconds seconds';
  }

  @override
  String get mealVoiceHeading => 'Tell us what you just ate';

  @override
  String get mealVoiceExample =>
      'Example: “A bowl of rare beef pho and an iced tea”';

  @override
  String get mealVoiceFinishing => 'Turning speech into text…';

  @override
  String get mealVoiceCancel => 'Cancel recording';

  @override
  String get mealVoiceNoSpeech =>
      'Lành didn’t hear any words. Tap the mic and try again.';

  @override
  String get mealVoiceLanguageUnavailable =>
      'This device can’t recognize speech in this language yet. You can type instead.';

  @override
  String get mealVoiceRecognitionError =>
      'Lành couldn’t recognize your voice. Check your connection and try again, or type instead.';

  @override
  String get mealVoiceTypeInstead => 'Type instead';

  @override
  String get mealVoiceUnavailable =>
      'Voice logging isn’t available on this device. You can type instead.';

  @override
  String get mealVoiceConfirmTitle => 'Check the transcript';

  @override
  String get mealVoiceTypedTitle => 'Describe your meal';

  @override
  String get mealVoiceBackToRecording => 'Back to recording';

  @override
  String get mealVoiceConfirmHeading => 'Lành heard you';

  @override
  String get mealVoiceConfirmBody => 'Fix any words before sending.';

  @override
  String get mealVoiceConfirmHint =>
      'This is an estimate. Check it before saving.';

  @override
  String get mealVoiceTypedBody =>
      'Write the dishes and how much you ate for Lành to estimate.';

  @override
  String get mealVoiceTranscriptLabel => 'Text from your voice';

  @override
  String get mealVoiceTypedLabel => 'Your description';

  @override
  String mealVoiceWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return '$_temp0';
  }

  @override
  String mealVoiceTooLong(int max) {
    return 'Use at most $max characters.';
  }

  @override
  String get mealVoicePrivacy =>
      'Only this text is sent to Lành to estimate the dishes.';

  @override
  String get mealVoiceSend => 'Send for analysis';

  @override
  String get mealVoiceRecordAgain => 'Record again';

  @override
  String get mealEstimationReceivedText => 'Description received';

  @override
  String get mealEstimationRecognizingText =>
      'Recognizing dishes in your description';

  @override
  String get mealEstimationTextErrorBody =>
      'Lành couldn’t find any dish in your description. Try naming each dish and amount. Your description is kept.';

  @override
  String get mealEstimationTextNetworkBody =>
      'Lành couldn’t reach the analysis server. Check your connection and try again. Your description is kept.';

  @override
  String get mealEstimationTextUnavailableBody =>
      'The analysis server is busy or too slow. Please try again in a few minutes. Your description is kept.';

  @override
  String get mealReviewTextDisclaimer =>
      'These numbers are estimates from your description and may differ from what you actually ate.';

  @override
  String get mealReviewVoiceLabel => 'Meal from your description';

  @override
  String get mealVoicePreparing => 'Opening the microphone…';

  @override
  String get mealVoiceNoAccess =>
      'Tap the mic to try again, turn it on in Settings, or type instead.';

  @override
  String get mealVoiceSpeakHint => 'Say the dishes and how much you ate';

  @override
  String get mealVoiceStartAction => 'Start speaking';

  @override
  String get mealVoiceAllowAction => 'Allow microphone';

  @override
  String get mealVoiceReadyTitle => 'Lành is ready to listen';

  @override
  String get mealVoiceNotHeardTitle => 'Lành didn’t catch that';

  @override
  String get mealVoiceNoAccessTitle => 'Lành can’t use the microphone';

  @override
  String get mealVoiceRecording => 'Recording';

  @override
  String get mealVoiceStop => 'Stop recording';

  @override
  String get mealVoiceStopCaption => 'Tap to stop and check the text';

  @override
  String get mealVoiceStartCaption => 'Tap to start speaking';

  @override
  String get mealVoiceAllowCaption => 'Tap to allow the microphone';

  @override
  String get profileBodyTapCaption => 'Tap a card to enter a value.';

  @override
  String get profileBmiEstimateTitle => 'Estimated BMI';

  @override
  String get profileBmiDisclaimer => 'An estimate, not a health check-up.';

  @override
  String get profileBmiAsianNote =>
      'WHO cut-offs for Asian adults: normal 18.5–22.9.';

  @override
  String get profileReadingAdult => 'Lành reads this with adult ranges.';

  @override
  String get profileHeightRange => 'Height should be 100–250 cm';

  @override
  String get profileWeightRange => 'Weight should be 25–350 kg';

  @override
  String profileTargetSubtitle(String goal, String weight) {
    return '$goal · now $weight kg';
  }

  @override
  String get profileTargetModeLabel => 'How to set the target';

  @override
  String get profileTargetModeSuggested => 'Lành\'s suggestion';

  @override
  String get profileTargetModeCustom => 'Choose myself';

  @override
  String profileTargetSuggestedFrom(String weight) {
    return 'Calculated from your current $weight kg';
  }

  @override
  String profileTargetPlanGentle(String percent) {
    return 'Gentle · $percent%';
  }

  @override
  String profileTargetPlanGainGentle(String percent) {
    return 'Gentle gain · $percent%';
  }

  @override
  String profileTargetPlanLonger(String percent) {
    return 'Longer milestone · $percent%';
  }

  @override
  String profileTargetRateApprox(String value) {
    return '~$value kg/week';
  }

  @override
  String profileTargetWeeksShort(int count) {
    return '$count weeks';
  }

  @override
  String get profileTargetCustomTitle => 'Your target';

  @override
  String profileTargetCustomDeltaLose(String delta, String current) {
    return '$delta kg less than your current $current kg';
  }

  @override
  String profileTargetCustomDeltaGain(String delta, String current) {
    return '$delta kg more than your current $current kg';
  }

  @override
  String get profileTargetCustomEmpty => 'Pick a target below.';

  @override
  String get profileTargetPickerLabel => 'Choose a target weight (kg)';

  @override
  String profileTargetPickerRangeLose(String min) {
    return 'From $min kg (BMI 18.5 for your height) to below your current weight.';
  }

  @override
  String profileTargetPickerRangeGain(String max) {
    return 'From above your current weight to $max kg (BMI 24.9 for your height).';
  }

  @override
  String get profileTargetWhenTitle => 'When do you want to get there?';

  @override
  String get profileTargetWhenLabel => 'Timing';

  @override
  String get profileTargetNoDate => 'No date';

  @override
  String get profileTargetNoDateNote =>
      'Lành follows the trend without a fixed date.';

  @override
  String get profileTargetDateRequired => 'Choose a target date.';

  @override
  String profileTargetEarliestDate(String date) {
    return 'Earliest date at a safe pace: $date';
  }

  @override
  String get profilePlanEstimateTitle => 'Plan estimate';

  @override
  String get profilePlanRate => 'Pace';

  @override
  String get profilePlanDuration => 'Duration';

  @override
  String profilePlanDurationValue(int count) {
    return 'about $count weeks';
  }

  @override
  String get profilePaceGentle => 'A gentle pace that is easy to keep';

  @override
  String get profilePaceCommonLose =>
      'Within the 0.5–1 kg/week range NHS and CDC describe as safe';

  @override
  String get profilePaceCommonGain =>
      'Within a gradual 0.25–0.5% of body weight per week';

  @override
  String get profilePaceTooFast =>
      'Faster than a safe pace — choose a later date';

  @override
  String get profileTargetUnavailableLose =>
      'Your weight is already at BMI 18.5 for your height. Lành won\'t suggest losing more; consider Maintain or ask a professional.';

  @override
  String get profileTargetUnavailableGain =>
      'Your weight is already at BMI 22.9 for your height. Lành won\'t suggest gaining more; consider Maintain or ask a professional.';

  @override
  String get profileTargetPreviousKept =>
      'Your previous goal stays until you confirm at the last step.';

  @override
  String get profileActivitySittingHint => 'Desk work, little walking';

  @override
  String get profileActivityLightHint => 'Light walking and housework';

  @override
  String get profileActivityModerateHint => 'Retail, service, lots of walking';

  @override
  String get profileActivityHeavyHint => 'Construction, farming, hard training';

  @override
  String get profileActivityVariableHint =>
      'Lành uses the low end to stay safe';

  @override
  String get profileEnergyTitle => 'Your body uses about';

  @override
  String profileEnergyValue(String kcal) {
    return '$kcal kcal/day';
  }

  @override
  String profileEnergyRange(String low, String high) {
    return '$low–$high kcal/day';
  }

  @override
  String get profileEnergyCaption =>
      'Estimated from age, sex, height, weight and activity (Mifflin‑St Jeor × FAO/WHO activity level). Not a substitute for nutrition advice.';

  @override
  String get profileEnergyPickActivity =>
      'Choose a level to see the estimated energy.';

  @override
  String get profilePregnancyLabel => 'Pregnant or breastfeeding';

  @override
  String get profilePregnancyHint =>
      'Lành will not calculate kcal or a weight target.';

  @override
  String get profilePregnancyNote =>
      'During pregnancy or breastfeeding, needs change by stage. Lành does not plan weight or kcal; ask a doctor or dietitian.';

  @override
  String profileTargetDailyKcal(String kcal) {
    return '≈ $kcal kcal/day';
  }

  @override
  String profileTargetEnergyLimited(String kcal) {
    return 'Lành stretches the plan so you still eat at least about $kcal kcal/day.';
  }

  @override
  String profileTargetUnavailableEnergy(String kcal) {
    return 'At this activity level, losing weight would mean eating below the safe floor (about $kcal kcal/day). Consider Maintain, more activity, or a professional\'s advice.';
  }

  @override
  String get profilePlanDailyKcal => 'Eat about';

  @override
  String profileTargetPlanModerate(String percent) {
    return 'Moderate · $percent%';
  }

  @override
  String get profileAgeEmpty => 'Enter your age';

  @override
  String get profileHeightEmpty => 'Enter your height';

  @override
  String get profileWeightEmpty => 'Enter your weight';

  @override
  String get planTitle => 'Your plan';

  @override
  String get planDailyLabel => 'Eat each day';

  @override
  String planBodyUsesApprox(String kcal) {
    return 'Body uses ~$kcal';
  }

  @override
  String planBodyUses(String kcal) {
    return 'Body uses $kcal';
  }

  @override
  String planEat(String kcal) {
    return 'Eat $kcal';
  }

  @override
  String planCut(String kcal) {
    return 'Cut $kcal';
  }

  @override
  String planAdd(String kcal) {
    return 'Add $kcal';
  }

  @override
  String get planMatchesBody => 'Same as your body uses';

  @override
  String get planTileTarget => 'Target';

  @override
  String get planTilePerWeek => 'per week';

  @override
  String get planTileDue => 'Expected';

  @override
  String get planTileHold => 'Stay near';

  @override
  String get planTileActivity => 'Activity';

  @override
  String get planTileGoal => 'Goal';

  @override
  String get planTileNow => 'Now';

  @override
  String get planNoKcalTitle => 'Track, no kcal count';

  @override
  String get planNoKcalTeen =>
      'This stage needs enough energy. Ask a professional when needed.';

  @override
  String get planNoKcalPregnant =>
      'Needs change at each stage. Ask your doctor when needed.';

  @override
  String get planStart => 'Start';

  @override
  String get planEdit => 'Edit';

  @override
  String get profileActivityShortSitting => 'Mostly sitting';

  @override
  String get profileActivityShortLight => 'Some walking';

  @override
  String get profileActivityShortModerate => 'On your feet';

  @override
  String get profileActivityShortHeavy => 'Physical work';

  @override
  String get profileActivityShortVariable => 'Varies';

  @override
  String todayOfTarget(String target) {
    return '/ $target kcal';
  }

  @override
  String todayLeftKcal(String kcal) {
    return '$kcal kcal left';
  }

  @override
  String todayOverKcal(String kcal) {
    return '$kcal kcal over';
  }

  @override
  String get todayReachedKcal => 'Target reached';

  @override
  String get todayFirstMealTitle => 'Log today\'s first meal';

  @override
  String get todayFirstMealBody =>
      'Snap, speak or search — Lành estimates the kcal.';

  @override
  String get profileSwitchToMaintain => 'Switch to Maintain';
}
