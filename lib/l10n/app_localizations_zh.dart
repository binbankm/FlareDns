// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'FlareDns';

  @override
  String get navDomains => '域名';

  @override
  String get navWorkers => 'Workers';

  @override
  String get navPages => 'Pages';

  @override
  String get navStorage => '存储';

  @override
  String get navSettings => '设置';

  @override
  String get authWelcome => '欢迎使用 FlareDns';

  @override
  String get authSubtitle => '使用 Cloudflare 全局 API Key 登录';

  @override
  String get authEmail => '账户邮箱';

  @override
  String get authApiKey => '全局 API Key';

  @override
  String get authLogin => '登录';

  @override
  String get authRequired => '必填';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSectionAccount => '账户';

  @override
  String get settingsNotLoggedIn => '未登录';

  @override
  String get settingsCloudflareApiKey => 'Cloudflare 全局 API Key';

  @override
  String get settingsSectionAppearance => '外观';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsSectionLanguage => '语言';

  @override
  String get settingsLanguageSystem => '跟随系统';

  @override
  String get settingsLanguageChinese => '中文';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsSectionAbout => '关于';

  @override
  String get settingsVersion => '版本';

  @override
  String get settingsSourceCode => '源代码';

  @override
  String get settingsLogout => '退出登录';

  @override
  String get settingsLogoutConfirmTitle => '退出登录';

  @override
  String get settingsLogoutConfirmContent => '确定要退出登录吗？';

  @override
  String get settingsLogoutConfirm => '退出';

  @override
  String get commonCancel => '取消';

  @override
  String get commonRetry => '重试';

  @override
  String get commonDelete => '删除';

  @override
  String get commonCreate => '创建';

  @override
  String get commonSave => '保存';

  @override
  String commonError(String error) {
    return '错误：$error';
  }

  @override
  String get commonLoading => '加载中...';

  @override
  String get commonRequired => '必填';

  @override
  String get zonesTitle => '域名';

  @override
  String get zonesSearch => '搜索域名...';

  @override
  String get zonesEmpty => '未找到任何域名。';

  @override
  String get zonesNoMatch => '没有匹配的域名。';

  @override
  String get zoneDashboardDns => 'DNS';

  @override
  String get zoneDashboardDnsSubtitle => '管理 DNS 记录';

  @override
  String get zoneDashboardSecurity => '安全';

  @override
  String get zoneDashboardSecuritySubtitle => '攻击防护与开发模式';

  @override
  String get zoneDashboardAnalytics => '分析';

  @override
  String get zoneDashboardAnalyticsSubtitle => '网站流量与使用统计';

  @override
  String get zoneDashboardCaching => '缓存';

  @override
  String get zoneDashboardCachingSubtitle => '清除缓存与相关设置';

  @override
  String get zoneDashboardSslSubtitle => '管理加密模式';

  @override
  String get zoneDashboardSslSubtitleWithCerts => '管理加密模式与证书';

  @override
  String get zoneDashboardSslNoCerts => '无证书';

  @override
  String dnsTitle(String zoneName) {
    return 'DNS：$zoneName';
  }

  @override
  String get dnsSearch => '搜索 DNS 记录...';

  @override
  String get dnsEmpty => '未找到 DNS 记录。';

  @override
  String get dnsNoMatch => '没有匹配的记录。';

  @override
  String get dnsDeleteTitle => '删除记录';

  @override
  String dnsDeleteContent(String name) {
    return '确定要删除 $name 吗？';
  }

  @override
  String dnsPriority(int priority) {
    return '优先级：$priority';
  }

  @override
  String get dnsTtlAuto => '自动';

  @override
  String dnsTtlSec(int sec) {
    return '$sec 秒';
  }

  @override
  String dnsTtlMins(int min) {
    return '$min 分钟';
  }

  @override
  String dnsTtlHours(int hour) {
    return '$hour 小时';
  }

  @override
  String dnsTtlDays(int day) {
    return '$day 天';
  }

  @override
  String get dnsFormEditTitle => '编辑记录';

  @override
  String get dnsFormAddTitle => '添加记录';

  @override
  String get dnsFormType => '类型';

  @override
  String get dnsFormName => '名称';

  @override
  String get dnsFormNameHint => '例如：www 或 @ 表示根域';

  @override
  String get dnsFormNameRequired => '名称不能为空';

  @override
  String get dnsFormContentRequired => '内容不能为空';

  @override
  String get dnsFormContent => '内容';

  @override
  String get dnsFormPriority => '优先级';

  @override
  String get dnsFormPriorityHint => '例如：10';

  @override
  String get dnsFormPriorityRequired => '优先级不能为空';

  @override
  String get dnsFormPriorityInvalid => '请输入有效数字';

  @override
  String get dnsFormTtl => 'TTL';

  @override
  String get dnsFormTtlLocked => '代理开启时 TTL 锁定为自动';

  @override
  String get dnsFormTtlAutoEnforced => '自动（由代理强制设定）';

  @override
  String get dnsFormProxied => '代理';

  @override
  String get dnsFormProxiedSubtitle => '通过 Cloudflare 路由流量';

  @override
  String get dnsFormSaveChanges => '保存更改';

  @override
  String get dnsFormCreateRecord => '创建记录';

  @override
  String get dnsFormInvalidIpv4 => '无效的 IPv4 地址';

  @override
  String get dnsFormInvalidIpv4Segment => '无效的 IPv4 段';

  @override
  String get dnsFormInvalidIpv6 => '无效的 IPv6 地址';

  @override
  String get workersTitle => 'Workers';

  @override
  String get workersSearch => '搜索 Workers...';

  @override
  String get workersEmpty => '账户中未找到任何 Worker。';

  @override
  String get workersNoMatch => '没有匹配的 Worker。';

  @override
  String get workersDeleteTitle => '删除 Worker';

  @override
  String workersDeleteContent(String name) {
    return '确定要删除「$name」吗？此操作不可撤销。';
  }

  @override
  String get workersDeleted => 'Worker 已删除。';

  @override
  String get workersCreateTitle => '创建新 Worker';

  @override
  String get workersCreateNameLabel => 'Worker 名称';

  @override
  String get workersCreateNameHint => '例如：my-awesome-worker';

  @override
  String workersCreateError(String error) {
    return '创建 Worker 失败：$error';
  }

  @override
  String get workersNewTooltip => '新建 Worker';

  @override
  String get pagesTitle => 'Pages';

  @override
  String get pagesSearch => '搜索项目...';

  @override
  String get pagesEmpty => '未找到任何 Pages 项目。';

  @override
  String get pagesNoMatch => '没有匹配的项目。';

  @override
  String securityTitle(String zoneName) {
    return '安全：$zoneName';
  }

  @override
  String get securityUnderAttackTitle => '我正在受到攻击模式';

  @override
  String get securityUnderAttackDesc => '防御 DDoS 攻击。访客将看到 JavaScript 挑战验证。';

  @override
  String get securityUnderAttackTurnOff => '关闭';

  @override
  String get securityUnderAttackEnable => '启用攻击防护模式';

  @override
  String get securityLevelTitle => '安全级别';

  @override
  String get securityLevelDesc => '调整您网站的安全配置。';

  @override
  String get securityLevelUnderAttackNote => '攻击防护模式已启用。如需更改级别，请先关闭该模式。';

  @override
  String get securityLevelEssentiallyOff => '基本关闭';

  @override
  String get securityLevelLow => '低';

  @override
  String get securityLevelMedium => '中';

  @override
  String get securityLevelHigh => '高';

  @override
  String get securityDevModeTitle => '开发模式';

  @override
  String get securityDevModeDesc => '临时绕过缓存，让您实时查看源服务器的更改。3 小时后自动关闭。';

  @override
  String get securityDevModeActive => '已激活（绕过缓存）';

  @override
  String get securityDevModeOff => '关闭';

  @override
  String get securityDevModeEnabled => '开发模式已启用';

  @override
  String get securityDevModeDisabled => '开发模式已关闭';

  @override
  String securityLevelUpdated(String level) {
    return '安全级别已更新为 $level';
  }

  @override
  String securityErrorLoading(String error) {
    return '加载状态失败：$error';
  }

  @override
  String analyticsTitle(String zoneName) {
    return '分析：$zoneName';
  }

  @override
  String get analyticsLast30Days => '近 30 天汇总';

  @override
  String get analyticsTotalRequests => '总请求数';

  @override
  String get analyticsTotalBandwidth => '总带宽';

  @override
  String get analyticsUniqueVisitors => '独立访客';

  @override
  String get analyticsPageViews => '页面浏览量';

  @override
  String get analyticsCached => '已缓存';

  @override
  String get analyticsUncached => '未缓存';

  @override
  String get analyticsUnavailable => '该域名或套餐无法获取分析数据。';

  @override
  String analyticsDetails(String error) {
    return '详情：$error';
  }

  @override
  String cachingTitle(String zoneName) {
    return '缓存：$zoneName';
  }

  @override
  String get cachePurgeTitle => '清除缓存';

  @override
  String get cachePurgeDesc => '清除已缓存的文件，强制 Cloudflare 从您的服务器重新获取最新版本。';

  @override
  String get cachePurgeConfirmTitle => '清除所有缓存？';

  @override
  String get cachePurgeConfirmContent =>
      '此操作将清除该域名的所有缓存资源，可能会临时增加源服务器负载。确定继续吗？';

  @override
  String get cachePurge => '清除';

  @override
  String get cachePurgeButton => '清除全部缓存';

  @override
  String get cachePurging => '清除中...';

  @override
  String get cachePurgeSuccess => '缓存清除成功！';

  @override
  String sslTitle(String zoneName) {
    return 'SSL/TLS：$zoneName';
  }

  @override
  String get sslEncryptionMode => '加密模式';

  @override
  String get sslEncryptionModeDesc => '选择 Cloudflare 连接到源服务器的方式。';

  @override
  String get sslModeOff => '关闭';

  @override
  String get sslModeOffDesc => '不应用任何加密。';

  @override
  String get sslModeFlexible => '灵活';

  @override
  String get sslModeFlexibleDesc => '加密浏览器与 Cloudflare 之间的流量。';

  @override
  String get sslModeFull => '完全';

  @override
  String get sslModeFullDesc => '端到端加密，使用服务器上的自签名证书。';

  @override
  String get sslModeStrict => '完全（严格）';

  @override
  String get sslModeStrictDesc =>
      '端到端加密，要求服务器上安装受信任的 CA 或 Cloudflare Origin CA 证书。';

  @override
  String get sslEdgeCertificates => '边缘证书';

  @override
  String get sslEdgeCertificatesDesc => '保护您域名的有效证书。';

  @override
  String get sslNoCerts => '未找到边缘证书。';

  @override
  String get sslHosts => '主机：';

  @override
  String get sslUpdated => 'SSL/TLS 模式已更新！';

  @override
  String sslCertError(String error) {
    return '加载证书失败：$error';
  }

  @override
  String get storageTitle => '存储';

  @override
  String get storageCreateKV => '创建 KV 命名空间';

  @override
  String get storageCreateD1 => '创建 D1 数据库';

  @override
  String get storageCreateR2 => '创建 R2 存储桶';

  @override
  String get storageCreateHint => '请输入名称';

  @override
  String storageCreateSuccess(String title) {
    return '$title 创建成功！';
  }

  @override
  String get pageDashboardDeployments => '部署';

  @override
  String get pageDashboardDomains => '自定义域';

  @override
  String get pageDashboardBindings => '绑定';

  @override
  String get pageDashboardNoDeployments => '未找到部署记录。';

  @override
  String get pageDashboardProduction => '生产环境';

  @override
  String get pageDashboardPreview => '预览环境';

  @override
  String get pageDashboardNoDomains => '未配置自定义域。';

  @override
  String get pageDashboardAddDomain => '添加自定义域';

  @override
  String get pageDashboardDomainName => '域名';

  @override
  String get pageDashboardDomainHint => '例如：mail.example.com';

  @override
  String get pageDashboardAddDomainSuccess => '自定义域已添加，CNAME 记录已自动配置！';

  @override
  String get pageDashboardAddDomainManual => '自定义域已添加！请手动添加 CNAME 记录。';

  @override
  String get pageDashboardRemoveDomainTitle => '移除自定义域？';

  @override
  String pageDashboardRemoveDomainContent(String name) {
    return '确定要从该项目中移除 \"$name\" 吗？';
  }

  @override
  String get pageDashboardRemoveDomainConfirm => '移除';

  @override
  String get pageDashboardRemoveDomainSuccess => '自定义域已移除。';

  @override
  String get pageDashboardEnvVars => '环境变量';

  @override
  String get pageDashboardNoBindings => '未配置绑定。';

  @override
  String get pageDashboardAddBinding => '添加绑定';

  @override
  String get pageDashboardAddSecret => '添加机密';

  @override
  String get pageDashboardKV => 'KV 命名空间';

  @override
  String get pageDashboardD1 => 'D1 数据库';

  @override
  String get pageDashboardR2 => 'R2 存储桶';

  @override
  String get pageDashboardService => '服务';

  @override
  String get pageDashboardEnvVar => '环境变量';

  @override
  String get pageDashboardSecret => '机密';

  @override
  String get storageEditKVTitle => '编辑 KV 命名空间';

  @override
  String get storageEditKVPrompt => '请输入新名称';

  @override
  String get storageUpdateKVSuccess => 'KV 命名空间更新成功！';

  @override
  String storageDeleteTitle(String item) {
    return '删除 $item';
  }

  @override
  String storageDeleteContent(String name) {
    return '确定要删除 \"$name\" 吗？此操作不可撤销。';
  }

  @override
  String storageDeleteSuccess(String item) {
    return '$item 删除成功！';
  }

  @override
  String storageNoItems(String item) {
    return '未找到 $item';
  }

  @override
  String get storageCopyId => 'ID 已复制到剪贴板';

  @override
  String get storageCopyUuid => 'UUID 已复制到剪贴板';

  @override
  String storageCreated(String date) {
    return '创建于：$date';
  }

  @override
  String get storageRename => '重命名';

  @override
  String get pageDashboardSecretAdded => '机密已添加。';

  @override
  String get pageDashboardSecretDeleted => '机密已删除。';

  @override
  String get pageDashboardDeleteBindingTitle => '删除绑定？';

  @override
  String pageDashboardDeleteBindingContent(String name) {
    return '确定要删除 \"$name\" 吗？';
  }

  @override
  String get pageDashboardBindingDeleted => '绑定已删除。';

  @override
  String get pageDashboardBindingAdded => '绑定已添加。';

  @override
  String get pageDashboardBindingTypeEnv => '纯文本（环境变量）';

  @override
  String get pageDashboardBindingTypeKV => 'KV 命名空间';

  @override
  String get pageDashboardBindingTypeD1 => 'D1 数据库';

  @override
  String get workerDashboardRedeploying => '正在重新部署以移除绑定...';

  @override
  String get workerDashboardPleaseDeploy => '配置触发器前，请先部署 Worker。';

  @override
  String get workerDashboardDeleteScheduleTitle => '删除计划？';

  @override
  String get workerDashboardScheduleDeleted => '计划已删除。';

  @override
  String get workerDashboardDeleteDomainTitle => '删除自定义域？';

  @override
  String get workerDashboardDomainDeleted => '自定义域已删除。';

  @override
  String get workerDashboardAddDomainTitle => '添加自定义域';

  @override
  String get workerDashboardDomainAdded => '自定义域添加成功。';

  @override
  String get workerDashboardDeployCode => '部署代码';

  @override
  String get workerCron1m => '1 分钟';

  @override
  String get workerCron5m => '5 分钟';

  @override
  String get workerCron15m => '15 分钟';

  @override
  String get workerCron30m => '30 分钟';

  @override
  String get workerCronHourly => '每小时';

  @override
  String get workerCronDaily => '每天';

  @override
  String get workerCronWeekly => '每周';

  @override
  String get workerDashboardTabBindings => '绑定与环境变量';

  @override
  String get workerDashboardTabTriggers => '触发器与路由';

  @override
  String get workerDashboardTabHistory => '部署历史';

  @override
  String get workerDashboardTabEditor => '代码编辑器';

  @override
  String get workerDashboardNoHistory => '新 Worker 暂无部署历史。';

  @override
  String get workerDashboardNoDeployments => '暂无部署历史。';

  @override
  String get workerDashboardNoBindings => '未配置任何绑定或机密变量。';

  @override
  String get workerDashboardAddBinding => '添加绑定';

  @override
  String get workerDashboardAddSecret => '添加机密';

  @override
  String get workerDashboardDeleteSecretTitle => '删除机密？';

  @override
  String workerDashboardDeleteSecretContent(String name) {
    return '确定要删除机密 \"$name\" 吗？';
  }

  @override
  String get workerDashboardDeleteBindingTitle => '删除绑定？';

  @override
  String workerDashboardDeleteBindingContent(String name) {
    return '确定要删除绑定 \"$name\" 吗？\n这将会重新部署你的代码。';
  }

  @override
  String workerDashboardDeleteScheduleContent(String name) {
    return '确定要删除定时计划 \"$name\" 吗？';
  }

  @override
  String workerDashboardDeleteDomainContent(String name) {
    return '确定要删除自定义域名 \"$name\" 吗？';
  }

  @override
  String get workerDashboardDeployedSuccess => '部署成功！';

  @override
  String get formSecretNameLabel => '机密名称 (例如 API_KEY)';

  @override
  String get formSecretValueLabel => '机密值';

  @override
  String get formBindingTypeLabel => '绑定类型';

  @override
  String get formBindingNameLabel => '绑定名称 (例如 DB, MY_KV, API_URL)';

  @override
  String get formBindingValueLabel => '值';

  @override
  String get formBindingKvNamespaceLabel => 'KV 命名空间 ID';

  @override
  String get formBindingSelectKvLabel => '选择 KV 命名空间';

  @override
  String get formBindingD1DatabaseLabel => 'D1 数据库 ID';

  @override
  String get formBindingSelectD1Label => '选择 D1 数据库';

  @override
  String get formCronExpressionLabel => 'Cron 表达式';

  @override
  String get formCronExpressionHint => '例如 * * * * * 或 */5 * * * *';

  @override
  String get formHostnameLabel => '域名';

  @override
  String get formHostnameHint => '例如 api.example.com';

  @override
  String get commonOpenSite => '打开网站';

  @override
  String get commonOpenInBrowser => '在浏览器中打开';

  @override
  String get workerCronEveryMinute => '每分钟';

  @override
  String get workerCronEvery5Minutes => '每 5 分钟';

  @override
  String get workerCronEvery15Minutes => '每 15 分钟';

  @override
  String get workerCronEvery30Minutes => '每 30 分钟';

  @override
  String get workerCronEveryHour => '每小时';

  @override
  String get workerCronEvery6Hours => '每 6 小时';

  @override
  String get workerCronEvery12Hours => '每 12 小时';

  @override
  String get workerCronOnceADay => '每天一次 (午夜)';

  @override
  String get workerCronEveryDay9Am => '每天早上 9 点';

  @override
  String get workerCronEverySunday => '每个星期日';

  @override
  String get workerCronFirstDayOfMonth => '每月第一天';

  @override
  String get workerCronCustomSchedule => '自定义计划';

  @override
  String get workerDashboardCustomDomainsRoutes => '自定义域名 / 路由';

  @override
  String get workerDashboardCronSchedules => 'Cron 计划任务';

  @override
  String get workerDashboardNoCustomDomains => '未配置自定义域名。';

  @override
  String get workerDashboardNoCronSchedules => '未配置 Cron 计划任务。';

  @override
  String get workerDashboardEditBinding => '编辑绑定';

  @override
  String get workerDashboardAddDeploy => '添加 (部署)';

  @override
  String get workerDashboardUpdateDeploy => '更新 (部署)';

  @override
  String get workerDashboardEditSecret => '编辑机密';

  @override
  String get formNewSecretValueLabel => '新机密值';

  @override
  String get workerDashboardSecretAdded => '已添加机密。';

  @override
  String get workerDashboardSecretUpdated => '已更新机密。';

  @override
  String get commonAdd => '添加';

  @override
  String get commonUpdate => '更新';

  @override
  String get dnsFormHintSrv =>
      '目标 (例如 example.com)。对于 SRV 请使用数据 API 获取完全控制，或适当地格式化内容。';

  @override
  String get dnsFormHintDefault => '值';
}
