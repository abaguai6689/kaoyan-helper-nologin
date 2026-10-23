import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/user_model.dart';

/// 免登录版本的应用会话状态。
///
/// 原项目通过验证码/密码登录后端并持久化 access/refresh token；
/// 本分支移除了登录环节：应用启动即视为已登录，
/// 使用内置的本地体验用户，直接进入主界面。
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserModel? currentUser;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.currentUser,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserModel? currentUser,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState(isAuthenticated: true, currentUser: UserModel.mock);
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
