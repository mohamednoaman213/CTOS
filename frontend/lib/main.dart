import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/routes/app_router.dart';
import 'core/services/app_init_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/bloc/auth_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  // Start real initialization; splash screen waits for this to complete
  // before navigating, so the app never shows a blank frame after loading.
  AppInitService.instance.initialize();
  runApp(const CtosApp());
}

class CtosApp extends StatelessWidget {
  const CtosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: MaterialApp.router(
        title: 'CTOS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
