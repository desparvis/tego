// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/widgets/auth_wrapper.dart';
import 'presentation/bloc/expense_bloc.dart';
import 'presentation/bloc/sales_bloc.dart';
import 'presentation/bloc/sales_cubit.dart';
import 'presentation/bloc/sales_list_bloc.dart';
import 'presentation/bloc/app_state_bloc.dart';
import 'data/repositories/sales_repository_impl.dart';
import 'data/repositories/expense_repository_impl.dart';
import 'domain/usecases/add_sale_usecase.dart';
import 'domain/usecases/get_sales_analytics_usecase.dart';
import 'core/services/firestore_service.dart';
import 'core/state/app_state_manager.dart';
import 'core/state/performance_bloc_observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/utils/preferences_service.dart';
import 'core/utils/theme_notifier.dart';
import 'core/utils/settings_manager.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up performance monitoring for BLoCs
  Bloc.observer = PerformanceBlocObserver();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // ignore: avoid_print
    print('Firebase initialized with DefaultFirebaseOptions');
  } catch (e, st) {
    // ignore: avoid_print
    print('Firebase initialization failed: $e\n$st');
  }

  await PreferencesService.init();
  await SettingsManager.initializeSettings();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    ThemeNotifier().setThemeChangeListener(_loadTheme);
  }

  void _loadTheme() {
    final savedTheme = PreferencesService.getThemeMode();
    setState(() {
      switch (savedTheme) {
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ChangeNotifier for global app state
        ChangeNotifierProvider<AppStateManager>(
          create: (_) => AppStateManager(),
        ),
        // Repository provider for dependency injection
        Provider<SalesRepositoryImpl>(
          create: (_) => SalesRepositoryImpl(
            FirestoreService.instance,
            FirebaseAuth.instance,
          ),
        ),
        Provider<ExpenseRepositoryImpl>(
          create: (_) => ExpenseRepositoryImpl(
            FirestoreService.instance,
            FirebaseAuth.instance,
          ),
        ),
        // Use case providers
        ProxyProvider<SalesRepositoryImpl, AddSaleUseCase>(
          update: (_, repository, __) => AddSaleUseCase(repository),
        ),
        ProxyProvider<SalesRepositoryImpl, GetSalesAnalyticsUseCase>(
          update: (_, repository, __) => GetSalesAnalyticsUseCase(repository),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ExpenseBloc>(
            create: (context) =>
                ExpenseBloc(context.read<ExpenseRepositoryImpl>()),
          ),
          BlocProvider<SalesBloc>(
            create: (context) => SalesBloc(context.read<AddSaleUseCase>()),
          ),
          BlocProvider<SalesCubit>(
            create: (context) => SalesCubit(context.read<AddSaleUseCase>()),
          ),
          BlocProvider<SalesListBloc>(
            create: (context) => SalesListBloc(
              getSalesAnalyticsUseCase: context
                  .read<GetSalesAnalyticsUseCase>(),
              firestoreService: FirestoreService.instance,
              auth: FirebaseAuth.instance,
            ),
          ),
          BlocProvider<AppStateBloc>(
            create: (context) => AppStateBloc()..add(LoadAppDataEvent()),
          ),
        ],
        child: MaterialApp(
          title: 'Tego App',
          themeMode: _themeMode,
          theme: ThemeData(
            primaryColor: const Color(0xFF7B4EFF),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF7B4EFF),
              brightness: Brightness.light,
            ),
            fontFamily: 'Poppins',
            useMaterial3: true,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: ThemeData(
            primaryColor: const Color(0xFF7B4EFF),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF7B4EFF),
              brightness: Brightness.dark,
            ),
            fontFamily: 'Poppins',
            useMaterial3: true,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
