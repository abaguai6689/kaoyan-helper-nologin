import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';
import 'auth_token_store.dart';
import 'demo_api_interceptor.dart';
import 'dio_client.dart';
import 'shared_prefs_auth_token_store.dart';

/// 令牌存储：默认持久化到本地，测试中 Override 为 `MemoryAuthTokenStore`。
final authTokenStoreProvider = Provider<AuthTokenStore>((ref) {
  return SharedPrefsAuthTokenStore();
});

/// 用户后端网络层单例（仅连接 `/api/v1` 用户端接口，不含 `/admin/*`）。
///
/// 免登录版本默认挂载 [DemoApiInterceptor]：请求不离开设备，
/// 由本地演示数据完成响应，保证无后端时仍可完整浏览各模块。
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    tokenStore: ref.watch(authTokenStoreProvider),
    interceptors: ApiConfig.demoMode
        ? <DemoApiInterceptor>[DemoApiInterceptor()]
        : const [],
  );
});
