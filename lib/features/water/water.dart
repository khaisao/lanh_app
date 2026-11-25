/// Water logging: today's glasses against a fixed goal by sex.
library;

export 'domain/water_goal.dart' show waterGlassMilliliters;
export 'presentation/water_card.dart' show WaterCard;
export 'water_providers.dart'
    show
        recentWaterProvider,
        todayWaterProvider,
        waterGoalGlassesProvider,
        waterLogRepositoryProvider;
