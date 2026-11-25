/// Public entry for opening the meal-logging task without selecting a tab.
library;

export 'presentation/meal_detail_sheet.dart' show showMealDetailSheet;
export 'presentation/meal_method_sheet.dart' show showMealMethodSheet;
export 'presentation/meal_photo_flow.dart' show restoreMealPhotoFlow;
export 'meal_logging_providers.dart'
    show
        lastSavedMealProvider,
        mealLogRepositoryProvider,
        recentMealLogsProvider,
        todayMealLogsProvider;
export 'domain/meal_log.dart' show MealLog, MealLogSource;
