import 'package:bumpo/bloc/home_bloc.dart';
import 'package:bumpo/data/repo/settings_repo.dart';
import 'package:bumpo/ui/screens/home.dart';
import 'package:bumpo/utils/constants.dart';
import 'package:bumpo/utils/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'utils/bloc_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(settingsBox);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeBloc(SettingsRepo())..add(CheckLocationPermission()),
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (_, c) => c is AppThemeState,
        builder: (context, state) {
          return MaterialApp(
            title: 'Bumpo',
            theme: ThemeData(
              colorScheme: MaterialTheme.lightScheme().toColorScheme(),
              textTheme: const MaterialTheme(TextTheme()).textTheme,
            ),
            darkTheme: ThemeData(
              colorScheme: MaterialTheme.darkScheme().toColorScheme(),
              textTheme: const MaterialTheme(TextTheme()).textTheme,
            ),
            themeMode:
                state is AppThemeState ? state.themeMode : ThemeMode.light,
            builder: EasyLoading.init(),
            home: const Home(),
          );
        },
      ),
    );
  }
}
