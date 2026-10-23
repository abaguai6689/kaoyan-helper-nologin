import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/features/dashboard/dashboard_view.dart';
import '../../ui/features/flashcards/flashcards_view.dart';
import '../../ui/features/mistakes/mistakes_view.dart';
import '../../ui/features/quiz/quiz_view.dart';
import '../../ui/features/rest/rest_view.dart';
import '../../ui/features/schools/schools_view.dart';
import '../../ui/shell/app_shell.dart';

abstract final class AppRoutes {
  static const dashboard = '/dashboard';
  static const quiz = '/quiz';
  static const mistakes = '/mistakes';
  static const schools = '/schools';
  static const flashcards = '/flashcards';
  static const rest = '/rest';
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// 免登录路由：不再挂载登录页，也不做登录态重定向，
/// 应用启动后直接进入看板。
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(path: '/', redirect: (_, _) => AppRoutes.dashboard),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.quiz,
                builder: (context, state) => const QuizView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.mistakes,
                builder: (context, state) => const MistakesView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.schools,
                builder: (context, state) => const SchoolsView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.flashcards,
                builder: (context, state) => const FlashcardsView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.rest,
                builder: (context, state) => const RestView(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
