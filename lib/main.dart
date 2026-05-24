import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gas_man_app/app/app_model.dart';
import 'package:the_gas_man_app/pages/new_calender/dispatch_live_board_screen.dart';
import 'package:the_gas_man_app/pages/new_calender/job_calendar_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/cis/view_models/deduction_vm.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/cis/view_models/returns_vm.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/cis/view_models/statement_vm.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/cis/view_models/sub_cintractor_vm.dart';
import 'package:the_gas_man_app/pages/tools/gas_rate_page.dart';
import 'package:the_gas_man_app/pages/tools/pipe_sizing_page.dart';
import 'package:the_gas_man_app/utils_class/network_utils.dart';
import 'package:the_gas_man_app/utils_class/notification_utils.dart';
import 'package:the_gas_man_app/utils_class/pdf_font_helper.dart';
import 'pages/dashboard_page.dart';
import 'pages/calendar_page.dart';
import 'pages/new_calender/engineer_list_screen.dart';
import 'pages/new_calender/job_form_screen.dart';
import 'pages/new_calender/job_scheduler_screen.dart';
import 'pages/new_calender/today_jobs_screen.dart';
import 'pages/new_tax_and_invoice/pages/invite_user/team_provider.dart';
import 'pages/splash_screen/splash_screen.dart';
import 'pages/tools/pipe_sizing_new_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    await NotificationUtils.init();
  } on Exception catch (e) {
    // TODO
  }
  try {
    await PdfFontHelper.loadFonts();
  } on Exception catch (e) {
    // TODO
  }
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kReleaseMode
          ? AndroidPlayIntegrityProvider()
          : AndroidDebugProvider(),

      providerApple: kReleaseMode
          ? AppleAppAttestWithDeviceCheckFallbackProvider()
          : AppleDebugProvider(),
    );
  } on Exception catch (e) {
    // TODO
  }
  runApp(const MyApp());
}

final GlobalKey<NavigatorState>? mainKey = new GlobalKey();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static const Color kTeal = Color(0xFF326E6C);
  static const Color kAmber = Color(0xFFFFB300);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = mainKey?.currentContext;
      if (context != null) {
        NetworkService.instance.start(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: MyApp.kTeal).copyWith(
        primary: MyApp.kTeal,
        secondary: MyApp.kAmber,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: MyApp.kTeal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Color(0xFFF7F9FA),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyApp.kTeal,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        ),
      ),
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppModel()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => TeamProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SubcontractorVM(),
        ),
        ChangeNotifierProvider(
          create: (_) => StatementVM(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReturnsVM(),
        ),
        ChangeNotifierProvider(
          create: (_) => DeductionVM(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Engineer Toolkit',
        navigatorKey: mainKey,
        theme: theme,
        home: const SplashScreen(),
        routes: {
          GasRatePage.route: (_) => const GasRatePage(),
          GasPipeSizingPage.route: (_) => const GasPipeSizingPage(),
          // CalendarPage.route: (_) => const CalendarPage(),
          "/jobs/calendar": (_) => const JobCalendarScreen(),
          "/jobs/scheduler": (_) => const JobSchedulerScreen(),
          "/jobs/today": (_) => const TodayJobsScreen(),
          "/jobs/new": (_) => const JobFormScreen(),
          "/engineers": (_) => const EngineerListScreen(),
          "/dispatch/live-board": (_) => const DispatchLiveBoardScreen(),
        },
      ),
    );
  }
}
