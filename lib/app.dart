import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';

class CampusIncidentApp extends StatelessWidget {
  const CampusIncidentApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Campus Incident Reporter', debugShowCheckedModeBanner: false,
    theme: AppTheme.light, darkTheme: AppTheme.dark,
    themeMode: context.watch<ThemeProvider>().themeMode,
    onGenerateRoute: AppRouter.onGenerateRoute, initialRoute: AppRouter.splash,
  );
}
