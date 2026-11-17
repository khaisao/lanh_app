import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/today/presentation/today_dashboard.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final captureDirectory = Platform.environment['LANH_PREVIEW_DIR'];
  if (captureDirectory != null) {
    setUpAll(() async {
      await (FontLoader(AppFonts.body)
            ..addFont(rootBundle.load('assets/fonts/BeVietnamPro-Regular.ttf'))
            ..addFont(
              rootBundle.load('assets/fonts/BeVietnamPro-SemiBold.ttf'),
            ))
          .load();
      await (FontLoader(
        AppFonts.heading,
      )..addFont(rootBundle.load('assets/fonts/Nunito-Variable.ttf'))).load();
    });
  }

  for (final (mode, heading, progress, footer) in const [
    (
      GoalType.gain,
      'Mục tiêu tăng cân · 2.500 kcal',
      .392,
      'Còn 1.520 kcal để đạt mục tiêu',
    ),
    (
      GoalType.lose,
      'Kế hoạch hôm nay · 1.800 kcal',
      .544,
      'Còn 820 kcal trong kế hoạch',
    ),
    (
      GoalType.maintain,
      'Dải duy trì · 1.900–2.300 kcal',
      .327,
      'Bữa tối vẫn có thể ghi thêm',
    ),
  ]) {
    for (final (size, scale) in const [
      (Size(320, 700), 1.0),
      (Size(360, 800), 1.0),
      (Size(390, 844), 1.0),
      (Size(430, 932), 1.0),
      (Size(320, 700), 2.0),
    ]) {
      testWidgets('${mode.name} preview fits ${size.width} at ${scale}x', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const captureKey = Key('today-preview-capture');
        const photo = AssetImage('assets/design/images/dzdAuAChai1.jpeg');
        var detailsOpened = false;
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: const Locale('vi'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            home: Builder(
              builder: (context) => RepaintBoundary(
                key: captureKey,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale),
                    disableAnimations: true,
                  ),
                  child: Scaffold(
                    extendBody: true,
                    body: TodayDashboard(
                      energy: TodayEnergyCard(
                        mode: mode,
                        heading: heading,
                        value: '980',
                        footer: footer,
                        progress: progress,
                        range: mode == GoalType.maintain ? (.633, .767) : null,
                        estimated: true,
                      ),
                      water: const TodayWaterCard(
                        value: '750 / 2.000 ml',
                        filled: 3,
                      ),
                      journal: TodayJournal(
                        onDetails: () => detailsOpened = true,
                        entries: const [
                          TodayCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                TodayMealRow(
                                  name: 'Cơm gà xào rau',
                                  time: '12:30',
                                  energy: '580 kcal',
                                  photo: photo,
                                ),
                                Divider(
                                  height: AppBorders.hairline,
                                  color: AppColors.border,
                                ),
                                TodayMealRow(
                                  name: 'Cháo trắng với trứng',
                                  time: '07:10',
                                  energy: '400 kcal',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    bottomNavigationBar: AppBottomBar(
                      actionKey: const Key('preview-log'),
                      destinations: const [
                        AppBottomBarDestination(
                          key: Key('preview-today'),
                          label: 'Hôm nay',
                          icon: Icons.home_outlined,
                          selectedIcon: Icons.home_rounded,
                        ),
                        AppBottomBarDestination(
                          key: Key('preview-progress'),
                          label: 'Tiến trình',
                          icon: Icons.leaderboard_outlined,
                          selectedIcon: Icons.leaderboard_rounded,
                        ),
                        AppBottomBarDestination(
                          key: Key('preview-achievements'),
                          label: 'Thành tựu',
                          icon: Icons.workspace_premium_outlined,
                          selectedIcon: Icons.workspace_premium_rounded,
                        ),
                        AppBottomBarDestination(
                          key: Key('preview-menu'),
                          label: 'Menu',
                          icon: Icons.grid_view_outlined,
                          selectedIcon: Icons.grid_view_rounded,
                        ),
                      ],
                      selectedIndex: 0,
                      onSelect: (_) {},
                      actionLabel: 'Ghi bữa',
                      onAction: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (captureDirectory != null && size.width == 390) {
          final context = tester.element(find.byKey(captureKey));
          await tester.runAsync(
            () => Future.wait([
              precacheImage(photo, context),
              precacheImage(
                const AssetImage('assets/design/images/welcome-broccoli.png'),
                context,
              ),
            ]),
          );
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(captureKey),
            );
            final image = await boundary.toImage(pixelRatio: 2);
            try {
              final png = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await File('$captureDirectory/today-${mode.name}.png')
                  .writeAsBytes(png!.buffer.asUint8List());
            } finally {
              image.dispose();
            }
          });
        }
        expect(find.text(heading), findsOneWidget);
        expect(find.text(footer), findsOneWidget);
        final details = find.text('Chi tiết');
        await tester.scrollUntilVisible(details, 180);
        await tester.ensureVisible(details);
        await tester.pumpAndSettle();
        await tester.tap(details);
        expect(detailsOpened, isTrue);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
