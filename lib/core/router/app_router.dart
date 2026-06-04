import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/chat/screens/create_chat_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import 'main_shell_screen.dart';

import '../../features/profile/screens/peer_profile_screen.dart';
import '../../features/chat/models/chat_model.dart';
import '../../../l10n/app_localizations.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _chatsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'chats');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');
final _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<bool>(authProvider, (previous, next) => notifyListeners());
    _ref.listen<bool>(authInitProvider, (previous, next) => notifyListeners());
  }
}

@riverpod
GoRouter appRouter(Ref ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/loading',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isInitializing = ref.read(authInitProvider);
      if (isInitializing) {
        return state.matchedLocation == '/loading' ? null : '/loading';
      }

      final isAuthenticated = ref.read(authProvider);
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      final isGoingToLoading = state.matchedLocation == '/loading';

      if (!isAuthenticated && !isGoingToLogin && !isGoingToRegister) {
        return '/login';
      }

      if (isAuthenticated &&
          (isGoingToLogin ||
              isGoingToRegister ||
              isGoingToLoading ||
              state.matchedLocation == '/')) {
        return '/chats';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A1931),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/app_logo.png', width: 80, height: 80),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _chatsNavigatorKey,
            routes: [
              GoRoute(
                path: '/chats',
                builder: (context, state) => const ChatListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/create-chat',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateChatScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final chatId = state.pathParameters['id']!;
          
          String defaultTitle = 'Secure Chat';
          try {
            defaultTitle = AppLocalizations.of(context)?.secureChat ?? defaultTitle;
          } catch (_) {}
          
          final chatName = state.extra as String? ?? defaultTitle;
          return ChatScreen(chatId: chatId, chatName: chatName);
        },
      ),
      GoRoute(
        path: '/peer-profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final chat = state.extra as ChatModel;
          return PeerProfileScreen(chat: chat);
        },
      ),
    ],
  );
}
