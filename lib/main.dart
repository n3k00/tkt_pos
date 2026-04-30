import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/app/router/app_pages.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:window_manager/window_manager.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Windows app configuration only
  await windowManager.ensureInitialized();
  // Initialize local key-value storage
  await GetStorage.init();

  final options = WindowOptions(
    minimumSize: const Size(1300, 700),
    backgroundColor: AppColor.background,
    center: true,
  );

  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.setMinimizable(true);
    await windowManager.setResizable(true);
    await windowManager.setMaximizable(true);

    await windowManager.maximize();
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppString.title,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.noTransition,
      transitionDuration: Duration.zero,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColor.primary,
        scaffoldBackgroundColor: AppColor.background,
        cardColor: AppColor.card,
        dataTableTheme: DataTableThemeData(
          headingRowColor: const WidgetStatePropertyAll(Color(0xFFEFF1F4)),
          headingTextStyle: const TextStyle(fontWeight: FontWeight.w700),
          dividerThickness: 0.8,
          dataRowMinHeight: Dimens.tableRowMinHeight,
          dataRowMaxHeight: Dimens.tableRowMaxHeight,
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColor.drawerItemSelectedBackground;
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColor.surfaceBackground;
            }
            return null;
          }),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primary,
          brightness: Brightness.light,
          primary: AppColor.primary,
          surface: AppColor.card,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColor.card,
          elevation: 0,
          surfaceTintColor: AppColor.transparent,
          foregroundColor: AppColor.textPrimary,
          iconTheme: IconThemeData(color: AppColor.textPrimary),
          titleTextStyle: TextStyle(
            color: AppColor.textPrimary,
            fontSize: Dimens.fontSizeSubtitle,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            foregroundColor: AppColor.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimens.radiusXS),
            ),
          ),
        ),
        dividerColor: AppColor.border,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColor.textPrimary),
          bodyMedium: TextStyle(color: AppColor.textSecondary),
          titleLarge: TextStyle(
            color: AppColor.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      initialRoute: Routes.home,
      getPages: AppPages.routes,
      localizationsDelegates: const [
        fluent.FluentLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return fluent.FluentTheme(
          data: fluent.FluentThemeData(
            accentColor: fluent.Colors.green,
            brightness: Brightness.light,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
