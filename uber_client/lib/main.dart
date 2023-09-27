import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:bsahtak/repositories/cache.dart';
import 'package:bsahtak/repositories/messages_remote.dart';
import 'package:bsahtak/repositories/server.dart';
import 'package:bsahtak/route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'cubits/app_cubit.dart';
import 'cubits/bags_cubit.dart';
import 'cubits/home_cubit.dart';
import 'cubits/static_provider.dart';
import 'repositories/notifications.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Cache.init();
  await Server.init();
  await Notifications.createChannels();
  await RemoteMessages().initMessages();

  if (kDebugMode == false) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => StaticProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppCubit()),
      ],
      child: MaterialApp.router(
        routerConfig: goRouter,
        supportedLocales: [
          Locale('en'),
          Locale('fr'),
          Locale('ar'),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate, // Add this line

          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        locale: context.watch<StaticProvider>().locale,
        title: 'Bsahtak',
        theme: ThemeData(
          textTheme: GoogleFonts.rubikTextTheme(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xff39783A),
            primary: Color(0xff39783A),
            tertiary: Color(0xffB0A448),
          ),
          canvasColor: Color.fromARGB(255, 246, 246, 242),
        ),
      ),
    );
  }
}
