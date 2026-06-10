// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FlareDns';

  @override
  String get navDomains => 'Domains';

  @override
  String get navWorkers => 'Workers';

  @override
  String get navPages => 'Pages';

  @override
  String get navStorage => 'Storage';

  @override
  String get navSettings => 'Settings';

  @override
  String get authWelcome => 'Welcome to FlareDns';

  @override
  String get authSubtitle => 'Sign in with your Cloudflare Global API Key';

  @override
  String get authEmail => 'Account Email';

  @override
  String get authApiKey => 'Global API Key';

  @override
  String get authLogin => 'Login';

  @override
  String get authRequired => 'Required';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAccount => 'ACCOUNT';

  @override
  String get settingsNotLoggedIn => 'Not logged in';

  @override
  String get settingsCloudflareApiKey => 'Cloudflare Global API Key';

  @override
  String get settingsSectionAppearance => 'APPEARANCE';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsSectionLanguage => 'LANGUAGE';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsLanguageChinese => '中文';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsSectionAbout => 'ABOUT';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsSourceCode => 'Source Code';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsLogoutConfirmTitle => 'Logout';

  @override
  String get settingsLogoutConfirmContent => 'Are you sure you want to logout?';

  @override
  String get settingsLogoutConfirm => 'Logout';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonSave => 'Save';

  @override
  String commonError(String error) {
    return 'Error: $error';
  }

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonRequired => 'Required';

  @override
  String get zonesTitle => 'Domains';

  @override
  String get zonesSearch => 'Search domains...';

  @override
  String get zonesEmpty => 'No zones found.';

  @override
  String get zonesNoMatch => 'No domains match your search.';

  @override
  String get zoneDashboardDns => 'DNS';

  @override
  String get zoneDashboardDnsSubtitle => 'Manage DNS records';

  @override
  String get zoneDashboardSecurity => 'Security';

  @override
  String get zoneDashboardSecuritySubtitle => 'Under attack mode & Dev mode';

  @override
  String get zoneDashboardAnalytics => 'Analytics';

  @override
  String get zoneDashboardAnalyticsSubtitle => 'Web traffic & usage metrics';

  @override
  String get zoneDashboardCaching => 'Caching';

  @override
  String get zoneDashboardCachingSubtitle => 'Purge cache & settings';

  @override
  String get zoneDashboardSslSubtitle => 'Manage encryption mode';

  @override
  String get zoneDashboardSslSubtitleWithCerts =>
      'Manage encryption mode & certificates';

  @override
  String get zoneDashboardSslNoCerts => 'NO CERTS FOUND';

  @override
  String dnsTitle(String zoneName) {
    return 'DNS: $zoneName';
  }

  @override
  String get dnsSearch => 'Search DNS records...';

  @override
  String get dnsEmpty => 'No DNS records found.';

  @override
  String get dnsNoMatch => 'No records match your search.';

  @override
  String get dnsDeleteTitle => 'Delete Record';

  @override
  String dnsDeleteContent(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String dnsPriority(int priority) {
    return 'Pri: $priority';
  }

  @override
  String get dnsTtlAuto => 'Auto';

  @override
  String dnsTtlSec(int sec) {
    return '$sec sec';
  }

  @override
  String dnsTtlMins(int min) {
    return '$min mins';
  }

  @override
  String dnsTtlHours(int hour) {
    return '$hour hours';
  }

  @override
  String dnsTtlDays(int day) {
    return '$day days';
  }

  @override
  String get dnsFormEditTitle => 'Edit Record';

  @override
  String get dnsFormAddTitle => 'Add Record';

  @override
  String get dnsFormType => 'Type';

  @override
  String get dnsFormName => 'Name';

  @override
  String get dnsFormNameHint => 'e.g., www or @ for root';

  @override
  String get dnsFormNameRequired => 'Name is required';

  @override
  String get dnsFormContentRequired => 'Content is required';

  @override
  String get dnsFormContent => 'Content';

  @override
  String get dnsFormPriority => 'Priority';

  @override
  String get dnsFormPriorityHint => 'e.g., 10';

  @override
  String get dnsFormPriorityRequired => 'Priority is required';

  @override
  String get dnsFormPriorityInvalid => 'Must be a valid number';

  @override
  String get dnsFormTtl => 'TTL';

  @override
  String get dnsFormTtlLocked => 'TTL is locked to Auto when proxied';

  @override
  String get dnsFormTtlAutoEnforced => 'Auto (Enforced by Proxy)';

  @override
  String get dnsFormProxied => 'Proxied';

  @override
  String get dnsFormProxiedSubtitle => 'Route traffic through Cloudflare';

  @override
  String get dnsFormSaveChanges => 'Save Changes';

  @override
  String get dnsFormCreateRecord => 'Create Record';

  @override
  String get dnsFormInvalidIpv4 => 'Invalid IPv4 address';

  @override
  String get dnsFormInvalidIpv4Segment => 'Invalid IPv4 segment';

  @override
  String get dnsFormInvalidIpv6 => 'Invalid IPv6 address';

  @override
  String get workersTitle => 'Workers';

  @override
  String get workersSearch => 'Search workers...';

  @override
  String get workersEmpty => 'No Workers found in your account.';

  @override
  String get workersNoMatch => 'No workers match your search.';

  @override
  String get workersDeleteTitle => 'Delete Worker';

  @override
  String workersDeleteContent(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get workersDeleted => 'Worker deleted.';

  @override
  String get workersCreateTitle => 'Create New Worker';

  @override
  String get workersCreateNameLabel => 'Worker Name';

  @override
  String get workersCreateNameHint => 'e.g. my-awesome-worker';

  @override
  String workersCreateError(String error) {
    return 'Error creating worker: $error';
  }

  @override
  String get workersNewTooltip => 'New Worker';

  @override
  String get pagesTitle => 'Pages';

  @override
  String get pagesSearch => 'Search projects...';

  @override
  String get pagesEmpty => 'No Pages projects found.';

  @override
  String get pagesNoMatch => 'No projects match your search.';

  @override
  String securityTitle(String zoneName) {
    return 'Security: $zoneName';
  }

  @override
  String get securityUnderAttackTitle => 'I\'m Under Attack Mode';

  @override
  String get securityUnderAttackDesc =>
      'Defend against DDoS attacks. Visitors will see a JavaScript challenge.';

  @override
  String get securityUnderAttackTurnOff => 'TURN OFF';

  @override
  String get securityUnderAttackEnable => 'ENABLE UNDER ATTACK MODE';

  @override
  String get securityLevelTitle => 'Security Level';

  @override
  String get securityLevelDesc => 'Adjust your website\'s security profile.';

  @override
  String get securityLevelUnderAttackNote =>
      'Under Attack mode is enabled. To change the level, please turn it off first.';

  @override
  String get securityLevelEssentiallyOff => 'Essentially Off';

  @override
  String get securityLevelLow => 'Low';

  @override
  String get securityLevelMedium => 'Medium';

  @override
  String get securityLevelHigh => 'High';

  @override
  String get securityDevModeTitle => 'Development Mode';

  @override
  String get securityDevModeDesc =>
      'Temporarily bypass our cache. Allows you to see changes to your origin server in real-time. Automatically turns off after 3 hours.';

  @override
  String get securityDevModeActive => 'Active (Bypassing Cache)';

  @override
  String get securityDevModeOff => 'Off';

  @override
  String get securityDevModeEnabled => 'Development Mode Enabled';

  @override
  String get securityDevModeDisabled => 'Development Mode Disabled';

  @override
  String securityLevelUpdated(String level) {
    return 'Security Level updated to $level';
  }

  @override
  String securityErrorLoading(String error) {
    return 'Error loading status: $error';
  }

  @override
  String analyticsTitle(String zoneName) {
    return 'Analytics: $zoneName';
  }

  @override
  String get analyticsLast30Days => 'Last 30 Days Summary';

  @override
  String get analyticsTotalRequests => 'Total Requests';

  @override
  String get analyticsTotalBandwidth => 'Total Bandwidth';

  @override
  String get analyticsUniqueVisitors => 'Unique Visitors';

  @override
  String get analyticsPageViews => 'Page Views';

  @override
  String get analyticsCached => 'Cached';

  @override
  String get analyticsUncached => 'Uncached';

  @override
  String get analyticsUnavailable =>
      'Analytics data is not available for this zone or plan.';

  @override
  String analyticsDetails(String error) {
    return 'Details: $error';
  }

  @override
  String cachingTitle(String zoneName) {
    return 'Caching: $zoneName';
  }

  @override
  String get cachePurgeTitle => 'Purge Cache';

  @override
  String get cachePurgeDesc =>
      'Clear cached files to force Cloudflare to fetch a fresh version of those files from your web server.';

  @override
  String get cachePurgeConfirmTitle => 'Purge Everything?';

  @override
  String get cachePurgeConfirmContent =>
      'This will clear all cached resources for this zone. It may temporarily increase load on your origin server. Are you sure?';

  @override
  String get cachePurge => 'Purge';

  @override
  String get cachePurgeButton => 'Purge Everything';

  @override
  String get cachePurging => 'Purging...';

  @override
  String get cachePurgeSuccess => 'Cache successfully purged!';

  @override
  String sslTitle(String zoneName) {
    return 'SSL/TLS: $zoneName';
  }

  @override
  String get sslEncryptionMode => 'Encryption Mode';

  @override
  String get sslEncryptionModeDesc =>
      'Choose how Cloudflare connects to your origin server.';

  @override
  String get sslModeOff => 'Off';

  @override
  String get sslModeOffDesc => 'No encryption applied.';

  @override
  String get sslModeFlexible => 'Flexible';

  @override
  String get sslModeFlexibleDesc =>
      'Encrypts traffic between the browser and Cloudflare.';

  @override
  String get sslModeFull => 'Full';

  @override
  String get sslModeFullDesc =>
      'Encrypts end-to-end, using a self-signed cert on the server.';

  @override
  String get sslModeStrict => 'Full (strict)';

  @override
  String get sslModeStrictDesc =>
      'Encrypts end-to-end, requires a trusted CA or Cloudflare Origin CA cert on the server.';

  @override
  String get sslEdgeCertificates => 'Edge Certificates';

  @override
  String get sslEdgeCertificatesDesc =>
      'Active certificates protecting your domain.';

  @override
  String get sslNoCerts => 'No edge certificates found.';

  @override
  String get sslHosts => 'Hosts:';

  @override
  String get sslUpdated => 'SSL/TLS mode updated!';

  @override
  String sslCertError(String error) {
    return 'Error loading certificates: $error';
  }

  @override
  String get storageTitle => 'Storage';

  @override
  String get storageCreateKV => 'Create KV Namespace';

  @override
  String get storageCreateD1 => 'Create D1 Database';

  @override
  String get storageCreateR2 => 'Create R2 Bucket';

  @override
  String get storageCreateHint => 'Enter name';

  @override
  String storageCreateSuccess(String title) {
    return '$title created successfully!';
  }

  @override
  String get pageDashboardDeployments => 'Deployments';

  @override
  String get pageDashboardDomains => 'Domains';

  @override
  String get pageDashboardBindings => 'Bindings';

  @override
  String get pageDashboardNoDeployments => 'No deployments found.';

  @override
  String get pageDashboardProduction => 'Production';

  @override
  String get pageDashboardPreview => 'Preview';

  @override
  String get pageDashboardNoDomains => 'No custom domains configured.';

  @override
  String get pageDashboardAddDomain => 'Add Custom Domain';

  @override
  String get pageDashboardDomainName => 'Domain name';

  @override
  String get pageDashboardDomainHint => 'e.g. mail.example.com';

  @override
  String get pageDashboardAddDomainSuccess =>
      'Domain added and CNAME auto-configured!';

  @override
  String get pageDashboardAddDomainManual =>
      'Domain added! Please add the CNAME manually.';

  @override
  String get pageDashboardRemoveDomainTitle => 'Remove Domain?';

  @override
  String pageDashboardRemoveDomainContent(String name) {
    return 'Remove \"$name\" from this project?';
  }

  @override
  String get pageDashboardRemoveDomainConfirm => 'Remove';

  @override
  String get pageDashboardRemoveDomainSuccess => 'Domain removed.';

  @override
  String get pageDashboardEnvVars => 'Environment Variables';

  @override
  String get pageDashboardNoBindings => 'No bindings configured.';

  @override
  String get pageDashboardAddBinding => 'Add Binding';

  @override
  String get pageDashboardAddSecret => 'Add Secret';

  @override
  String get pageDashboardKV => 'KV Namespace';

  @override
  String get pageDashboardD1 => 'D1 Database';

  @override
  String get pageDashboardR2 => 'R2 Bucket';

  @override
  String get pageDashboardService => 'Service';

  @override
  String get pageDashboardEnvVar => 'Env Var';

  @override
  String get pageDashboardSecret => 'Secret';

  @override
  String get storageEditKVTitle => 'Edit KV Namespace';

  @override
  String get storageEditKVPrompt => 'Enter new title';

  @override
  String get storageUpdateKVSuccess => 'KV Namespace updated successfully!';

  @override
  String storageDeleteTitle(String item) {
    return 'Delete $item';
  }

  @override
  String storageDeleteContent(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String storageDeleteSuccess(String item) {
    return '$item deleted successfully!';
  }

  @override
  String storageNoItems(String item) {
    return 'No $item found';
  }

  @override
  String get storageCopyId => 'ID copied to clipboard';

  @override
  String get storageCopyUuid => 'UUID copied to clipboard';

  @override
  String storageCreated(String date) {
    return 'Created: $date';
  }

  @override
  String get storageRename => 'Rename';

  @override
  String get pageDashboardSecretAdded => 'Secret added.';

  @override
  String get pageDashboardSecretDeleted => 'Secret deleted.';

  @override
  String get pageDashboardDeleteBindingTitle => 'Delete Binding?';

  @override
  String pageDashboardDeleteBindingContent(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get pageDashboardBindingDeleted => 'Binding deleted.';

  @override
  String get pageDashboardBindingAdded => 'Binding added.';

  @override
  String get pageDashboardBindingTypeEnv => 'Plain Text (Env Var)';

  @override
  String get pageDashboardBindingTypeKV => 'KV Namespace';

  @override
  String get pageDashboardBindingTypeD1 => 'D1 Database';

  @override
  String get workerDashboardRedeploying => 'Redeploying to remove binding...';

  @override
  String get workerDashboardPleaseDeploy =>
      'Please deploy the worker first to configure triggers.';

  @override
  String get workerDashboardDeleteScheduleTitle => 'Delete Schedule?';

  @override
  String get workerDashboardScheduleDeleted => 'Schedule deleted.';

  @override
  String get workerDashboardDeleteDomainTitle => 'Delete Domain?';

  @override
  String get workerDashboardDomainDeleted => 'Domain deleted.';

  @override
  String get workerDashboardAddDomainTitle => 'Add Custom Domain';

  @override
  String get workerDashboardDomainAdded => 'Domain added successfully.';

  @override
  String get workerDashboardDeployCode => 'Deploy Code';

  @override
  String get workerCron1m => '1 min';

  @override
  String get workerCron5m => '5 mins';

  @override
  String get workerCron15m => '15 mins';

  @override
  String get workerCron30m => '30 mins';

  @override
  String get workerCronHourly => 'Hourly';

  @override
  String get workerCronDaily => 'Daily';

  @override
  String get workerCronWeekly => 'Weekly';

  @override
  String get workerDashboardTabBindings => 'Bindings & Secrets';

  @override
  String get workerDashboardTabTriggers => 'Triggers & Routes';

  @override
  String get workerDashboardTabHistory => 'History';

  @override
  String get workerDashboardTabEditor => 'Editor';

  @override
  String get workerDashboardNoHistory => 'No history for new worker.';

  @override
  String get workerDashboardNoDeployments => 'No deployment history.';

  @override
  String get workerDashboardNoBindings => 'No bindings or secrets configured.';

  @override
  String get workerDashboardAddBinding => 'Add Binding';

  @override
  String get workerDashboardAddSecret => 'Add Secret';

  @override
  String get workerDashboardDeleteSecretTitle => 'Delete Secret?';

  @override
  String workerDashboardDeleteSecretContent(String name) {
    return 'Are you sure you want to delete the secret \"$name\"?';
  }

  @override
  String get workerDashboardDeleteBindingTitle => 'Delete Binding?';

  @override
  String workerDashboardDeleteBindingContent(String name) {
    return 'Are you sure you want to delete the binding \"$name\"?\nThis will redeploy your code.';
  }

  @override
  String workerDashboardDeleteScheduleContent(String name) {
    return 'Are you sure you want to delete the schedule \"$name\"?';
  }

  @override
  String workerDashboardDeleteDomainContent(String name) {
    return 'Are you sure you want to delete the domain \"$name\"?';
  }

  @override
  String get workerDashboardDeployedSuccess => 'Deployed Successfully!';

  @override
  String get formSecretNameLabel => 'Secret Name (e.g. API_KEY)';

  @override
  String get formSecretValueLabel => 'Secret Value';

  @override
  String get formBindingTypeLabel => 'Binding Type';

  @override
  String get formBindingNameLabel => 'Binding Name (e.g. DB, MY_KV, API_URL)';

  @override
  String get formBindingValueLabel => 'Value';

  @override
  String get formBindingKvNamespaceLabel => 'KV Namespace ID';

  @override
  String get formBindingSelectKvLabel => 'Select KV Namespace';

  @override
  String get formBindingD1DatabaseLabel => 'D1 Database ID';

  @override
  String get formBindingSelectD1Label => 'Select D1 Database';

  @override
  String get formCronExpressionLabel => 'Cron Expression';

  @override
  String get formCronExpressionHint => 'e.g. * * * * * or */5 * * * *';

  @override
  String get formHostnameLabel => 'Hostname';

  @override
  String get formHostnameHint => 'e.g. api.example.com';

  @override
  String get commonOpenSite => 'Open site';

  @override
  String get commonOpenInBrowser => 'Open in browser';

  @override
  String get workerCronEveryMinute => 'Every minute';

  @override
  String get workerCronEvery5Minutes => 'Every 5 minutes';

  @override
  String get workerCronEvery15Minutes => 'Every 15 minutes';

  @override
  String get workerCronEvery30Minutes => 'Every 30 minutes';

  @override
  String get workerCronEveryHour => 'Every hour';

  @override
  String get workerCronEvery6Hours => 'Every 6 hours';

  @override
  String get workerCronEvery12Hours => 'Every 12 hours';

  @override
  String get workerCronOnceADay => 'Once a day (midnight)';

  @override
  String get workerCronEveryDay9Am => 'Every day at 9 AM';

  @override
  String get workerCronEverySunday => 'Every Sunday';

  @override
  String get workerCronFirstDayOfMonth => 'First day of each month';

  @override
  String get workerCronCustomSchedule => 'Custom schedule';

  @override
  String get workerDashboardCustomDomainsRoutes => 'Custom Domains / Routes';

  @override
  String get workerDashboardCronSchedules => 'Cron Schedules';

  @override
  String get workerDashboardNoCustomDomains => 'No custom domains configured.';

  @override
  String get workerDashboardNoCronSchedules => 'No cron schedules configured.';

  @override
  String get workerDashboardEditBinding => 'Edit Binding';

  @override
  String get workerDashboardAddDeploy => 'Add (Deploy)';

  @override
  String get workerDashboardUpdateDeploy => 'Update (Deploy)';

  @override
  String get workerDashboardEditSecret => 'Edit Secret';

  @override
  String get formNewSecretValueLabel => 'New Secret Value';

  @override
  String get workerDashboardSecretAdded => 'Secret added.';

  @override
  String get workerDashboardSecretUpdated => 'Secret updated.';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonUpdate => 'Update';

  @override
  String get dnsFormHintSrv =>
      'Target (e.g. example.com). For SRV use data API for full control, or format content appropriately.';

  @override
  String get dnsFormHintDefault => 'Value';
}
