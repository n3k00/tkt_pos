import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/app/router/app_pages.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:window_manager/window_manager.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Windows app configuration only
  await windowManager.ensureInitialized();
  // Initialize local key-value storage
  await GetStorage.init();

  final options = WindowOptions(backgroundColor: AppColor.background);
  windowManager.waitUntilReadyToShow(options, () async {
    // Open full screen and disable minimize/resize controls
    await windowManager.maximize();
    await windowManager.setMinimizable(false); // disable minimize button
    await windowManager.setMaximizable(false); // disable maximize/resize button
    await windowManager.setResizable(false); // block border/edge resize

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
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColor.primary,
        scaffoldBackgroundColor: AppColor.background,
        cardColor: AppColor.card,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primary,
          brightness: Brightness.light,
          primary: AppColor.primary,
          surface: AppColor.card,
          background: AppColor.background,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColor.card,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          foregroundColor: AppColor.textPrimary,
          iconTheme: IconThemeData(color: AppColor.textPrimary),
          titleTextStyle: TextStyle(
            color: AppColor.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
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
    );
  }
}
