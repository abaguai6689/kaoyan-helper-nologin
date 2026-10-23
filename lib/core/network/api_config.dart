/// 用户后端 API 全局配置。
///
/// 仅连接用户端接口（`/api/v1/{auth,me,dashboard,questions,...}`），
/// 管理端接口（`/api/v1/admin/*`）为管理后台专用，App 永不调用。
/// 生产环境通过 `--dart-define=API_BASE_URL=https://xxx` 注入。
class ApiConfig {
  /// 本地后端：`cd admin && npm run dev -- -p 3001`（当前 dev 环境固定端口）。
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001/api/v1',
  );

  static String get baseUrl => _envBaseUrl;

  /// 免登录版本默认启用本地演示数据（无需后端即可完整体验）。
  ///
  /// 如需联调真实后端，构建时传入 `--dart-define=DEMO_MODE=false`
  /// 并同时指定 `API_BASE_URL`。
  static const bool demoMode = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: true,
  );

  /// Flutter 不使用 Cookie，统一 Bearer 头（契约 §3.3）。
  static const String bearerScheme = 'Bearer';
}
