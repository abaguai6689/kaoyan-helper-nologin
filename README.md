# 登科 · kaoyan-helper（免登录版）

基于原项目 [AlkaidSTART/kaoyan-helper](https://github.com/AlkaidSTART/kaoyan-helper) 改造的
Flutter 考研助手，**移除了登录环节**：应用启动后直接进入看板，无需手机号/邮箱验证码。

## 本次改造内容

- 删除登录页、验证码/密码登录表单、OAuth 按钮与登录态路由守卫。
- 应用启动即为「本地体验用户」，直接进入 `/dashboard`。
- 移除顶部用户菜单中的「退出登录」入口。
- 新增**本地演示数据层**（`lib/core/network/demo_api_interceptor.dart`）：
  - 看板、刷题、错题、择校、背诵、打卡、个人档案等接口全部由本地返回结构化数据；
  - 无需部署后端、无需网络即可完整体验各功能模块；
  - 刷题判题、错题重做、卡片复习、目标院校收藏等交互均可在本地闭环。
- 默认构建开启演示模式；如需连接真实后端：

```bash
flutter build apk --release \
  --dart-define=DEMO_MODE=false \
  --dart-define=API_BASE_URL=https://your-backend.example.com/api/v1
```

## 本地运行

```bash
flutter pub get
flutter run
```

## 打包

GitHub Actions 会在推送 `main`（涉及 `pubspec.yaml`）或手动触发 `Release Pipeline` 时：

1. 校验版本号并避免重复 Release；
2. 构建 Android APK 与 Windows 便携版；
3. 创建 `v<version>` GitHub Release 并上传安装包。

本地打包：

```bash
flutter build apk --release
```

产物：`build/app/outputs/flutter-apk/app-release.apk`。

## 目录速览

```
lib/
  core/network/        网络层 + 本地演示数据拦截器
  core/router/         go_router 路由（已移除登录路由）
  features/            按领域拆分的 repository / provider
  ui/                  看板、刷题、错题、择校、背诵、休息等页面
```

## 说明

本项目仅用于学习与个人体验，原项目版权归原作者所有。
