import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// App title
  ///
  /// In en, this message translates to:
  /// **'FlareDns'**
  String get appTitle;

  /// No description provided for @navDomains.
  ///
  /// In en, this message translates to:
  /// **'Domains'**
  String get navDomains;

  /// No description provided for @navWorkers.
  ///
  /// In en, this message translates to:
  /// **'Workers'**
  String get navWorkers;

  /// No description provided for @navPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get navPages;

  /// No description provided for @navStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get navStorage;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FlareDns'**
  String get authWelcome;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your Cloudflare Global API Key'**
  String get authSubtitle;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Account Email'**
  String get authEmail;

  /// No description provided for @authApiKey.
  ///
  /// In en, this message translates to:
  /// **'Global API Key'**
  String get authApiKey;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get authRequired;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get settingsSectionAccount;

  /// No description provided for @settingsNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get settingsNotLoggedIn;

  /// No description provided for @settingsCloudflareApiKey.
  ///
  /// In en, this message translates to:
  /// **'Cloudflare Global API Key'**
  String get settingsCloudflareApiKey;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get settingsLanguageChinese;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get settingsSectionAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get settingsSourceCode;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogoutConfirmTitle;

  /// No description provided for @settingsLogoutConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get settingsLogoutConfirmContent;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogoutConfirm;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String commonError(String error);

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// No description provided for @zonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Domains'**
  String get zonesTitle;

  /// No description provided for @zonesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search domains...'**
  String get zonesSearch;

  /// No description provided for @zonesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No zones found.'**
  String get zonesEmpty;

  /// No description provided for @zonesNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No domains match your search.'**
  String get zonesNoMatch;

  /// No description provided for @zoneDashboardDns.
  ///
  /// In en, this message translates to:
  /// **'DNS'**
  String get zoneDashboardDns;

  /// No description provided for @zoneDashboardDnsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage DNS records'**
  String get zoneDashboardDnsSubtitle;

  /// No description provided for @zoneDashboardSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get zoneDashboardSecurity;

  /// No description provided for @zoneDashboardSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Under attack mode & Dev mode'**
  String get zoneDashboardSecuritySubtitle;

  /// No description provided for @zoneDashboardAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get zoneDashboardAnalytics;

  /// No description provided for @zoneDashboardAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Web traffic & usage metrics'**
  String get zoneDashboardAnalyticsSubtitle;

  /// No description provided for @zoneDashboardCaching.
  ///
  /// In en, this message translates to:
  /// **'Caching'**
  String get zoneDashboardCaching;

  /// No description provided for @zoneDashboardCachingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Purge cache & settings'**
  String get zoneDashboardCachingSubtitle;

  /// No description provided for @zoneDashboardSslSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage encryption mode'**
  String get zoneDashboardSslSubtitle;

  /// No description provided for @zoneDashboardSslSubtitleWithCerts.
  ///
  /// In en, this message translates to:
  /// **'Manage encryption mode & certificates'**
  String get zoneDashboardSslSubtitleWithCerts;

  /// No description provided for @zoneDashboardSslNoCerts.
  ///
  /// In en, this message translates to:
  /// **'NO CERTS FOUND'**
  String get zoneDashboardSslNoCerts;

  /// No description provided for @dnsTitle.
  ///
  /// In en, this message translates to:
  /// **'DNS: {zoneName}'**
  String dnsTitle(String zoneName);

  /// No description provided for @dnsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search DNS records...'**
  String get dnsSearch;

  /// No description provided for @dnsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No DNS records found.'**
  String get dnsEmpty;

  /// No description provided for @dnsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No records match your search.'**
  String get dnsNoMatch;

  /// No description provided for @dnsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get dnsDeleteTitle;

  /// No description provided for @dnsDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String dnsDeleteContent(String name);

  /// No description provided for @dnsPriority.
  ///
  /// In en, this message translates to:
  /// **'Pri: {priority}'**
  String dnsPriority(int priority);

  /// No description provided for @dnsTtlAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get dnsTtlAuto;

  /// No description provided for @dnsTtlSec.
  ///
  /// In en, this message translates to:
  /// **'{sec} sec'**
  String dnsTtlSec(int sec);

  /// No description provided for @dnsTtlMins.
  ///
  /// In en, this message translates to:
  /// **'{min} mins'**
  String dnsTtlMins(int min);

  /// No description provided for @dnsTtlHours.
  ///
  /// In en, this message translates to:
  /// **'{hour} hours'**
  String dnsTtlHours(int hour);

  /// No description provided for @dnsTtlDays.
  ///
  /// In en, this message translates to:
  /// **'{day} days'**
  String dnsTtlDays(int day);

  /// No description provided for @dnsFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Record'**
  String get dnsFormEditTitle;

  /// No description provided for @dnsFormAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Record'**
  String get dnsFormAddTitle;

  /// No description provided for @dnsFormType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get dnsFormType;

  /// No description provided for @dnsFormName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get dnsFormName;

  /// No description provided for @dnsFormNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., www or @ for root'**
  String get dnsFormNameHint;

  /// No description provided for @dnsFormNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get dnsFormNameRequired;

  /// No description provided for @dnsFormContentRequired.
  ///
  /// In en, this message translates to:
  /// **'Content is required'**
  String get dnsFormContentRequired;

  /// No description provided for @dnsFormContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get dnsFormContent;

  /// No description provided for @dnsFormPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get dnsFormPriority;

  /// No description provided for @dnsFormPriorityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 10'**
  String get dnsFormPriorityHint;

  /// No description provided for @dnsFormPriorityRequired.
  ///
  /// In en, this message translates to:
  /// **'Priority is required'**
  String get dnsFormPriorityRequired;

  /// No description provided for @dnsFormPriorityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Must be a valid number'**
  String get dnsFormPriorityInvalid;

  /// No description provided for @dnsFormTtl.
  ///
  /// In en, this message translates to:
  /// **'TTL'**
  String get dnsFormTtl;

  /// No description provided for @dnsFormTtlLocked.
  ///
  /// In en, this message translates to:
  /// **'TTL is locked to Auto when proxied'**
  String get dnsFormTtlLocked;

  /// No description provided for @dnsFormTtlAutoEnforced.
  ///
  /// In en, this message translates to:
  /// **'Auto (Enforced by Proxy)'**
  String get dnsFormTtlAutoEnforced;

  /// No description provided for @dnsFormProxied.
  ///
  /// In en, this message translates to:
  /// **'Proxied'**
  String get dnsFormProxied;

  /// No description provided for @dnsFormProxiedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Route traffic through Cloudflare'**
  String get dnsFormProxiedSubtitle;

  /// No description provided for @dnsFormSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get dnsFormSaveChanges;

  /// No description provided for @dnsFormCreateRecord.
  ///
  /// In en, this message translates to:
  /// **'Create Record'**
  String get dnsFormCreateRecord;

  /// No description provided for @dnsFormInvalidIpv4.
  ///
  /// In en, this message translates to:
  /// **'Invalid IPv4 address'**
  String get dnsFormInvalidIpv4;

  /// No description provided for @dnsFormInvalidIpv4Segment.
  ///
  /// In en, this message translates to:
  /// **'Invalid IPv4 segment'**
  String get dnsFormInvalidIpv4Segment;

  /// No description provided for @dnsFormInvalidIpv6.
  ///
  /// In en, this message translates to:
  /// **'Invalid IPv6 address'**
  String get dnsFormInvalidIpv6;

  /// No description provided for @workersTitle.
  ///
  /// In en, this message translates to:
  /// **'Workers'**
  String get workersTitle;

  /// No description provided for @workersSearch.
  ///
  /// In en, this message translates to:
  /// **'Search workers...'**
  String get workersSearch;

  /// No description provided for @workersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Workers found in your account.'**
  String get workersEmpty;

  /// No description provided for @workersNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No workers match your search.'**
  String get workersNoMatch;

  /// No description provided for @workersDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Worker'**
  String get workersDeleteTitle;

  /// No description provided for @workersDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String workersDeleteContent(String name);

  /// No description provided for @workersDeleted.
  ///
  /// In en, this message translates to:
  /// **'Worker deleted.'**
  String get workersDeleted;

  /// No description provided for @workersCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Worker'**
  String get workersCreateTitle;

  /// No description provided for @workersCreateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Worker Name'**
  String get workersCreateNameLabel;

  /// No description provided for @workersCreateNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. my-awesome-worker'**
  String get workersCreateNameHint;

  /// No description provided for @workersCreateError.
  ///
  /// In en, this message translates to:
  /// **'Error creating worker: {error}'**
  String workersCreateError(String error);

  /// No description provided for @workersNewTooltip.
  ///
  /// In en, this message translates to:
  /// **'New Worker'**
  String get workersNewTooltip;

  /// No description provided for @pagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pagesTitle;

  /// No description provided for @pagesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search projects...'**
  String get pagesSearch;

  /// No description provided for @pagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Pages projects found.'**
  String get pagesEmpty;

  /// No description provided for @pagesNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No projects match your search.'**
  String get pagesNoMatch;

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security: {zoneName}'**
  String securityTitle(String zoneName);

  /// No description provided for @securityUnderAttackTitle.
  ///
  /// In en, this message translates to:
  /// **'I\'m Under Attack Mode'**
  String get securityUnderAttackTitle;

  /// No description provided for @securityUnderAttackDesc.
  ///
  /// In en, this message translates to:
  /// **'Defend against DDoS attacks. Visitors will see a JavaScript challenge.'**
  String get securityUnderAttackDesc;

  /// No description provided for @securityUnderAttackTurnOff.
  ///
  /// In en, this message translates to:
  /// **'TURN OFF'**
  String get securityUnderAttackTurnOff;

  /// No description provided for @securityUnderAttackEnable.
  ///
  /// In en, this message translates to:
  /// **'ENABLE UNDER ATTACK MODE'**
  String get securityUnderAttackEnable;

  /// No description provided for @securityLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Level'**
  String get securityLevelTitle;

  /// No description provided for @securityLevelDesc.
  ///
  /// In en, this message translates to:
  /// **'Adjust your website\'s security profile.'**
  String get securityLevelDesc;

  /// No description provided for @securityLevelUnderAttackNote.
  ///
  /// In en, this message translates to:
  /// **'Under Attack mode is enabled. To change the level, please turn it off first.'**
  String get securityLevelUnderAttackNote;

  /// No description provided for @securityLevelEssentiallyOff.
  ///
  /// In en, this message translates to:
  /// **'Essentially Off'**
  String get securityLevelEssentiallyOff;

  /// No description provided for @securityLevelLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get securityLevelLow;

  /// No description provided for @securityLevelMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get securityLevelMedium;

  /// No description provided for @securityLevelHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get securityLevelHigh;

  /// No description provided for @securityDevModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Development Mode'**
  String get securityDevModeTitle;

  /// No description provided for @securityDevModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Temporarily bypass our cache. Allows you to see changes to your origin server in real-time. Automatically turns off after 3 hours.'**
  String get securityDevModeDesc;

  /// No description provided for @securityDevModeActive.
  ///
  /// In en, this message translates to:
  /// **'Active (Bypassing Cache)'**
  String get securityDevModeActive;

  /// No description provided for @securityDevModeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get securityDevModeOff;

  /// No description provided for @securityDevModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Development Mode Enabled'**
  String get securityDevModeEnabled;

  /// No description provided for @securityDevModeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Development Mode Disabled'**
  String get securityDevModeDisabled;

  /// No description provided for @securityLevelUpdated.
  ///
  /// In en, this message translates to:
  /// **'Security Level updated to {level}'**
  String securityLevelUpdated(String level);

  /// No description provided for @securityErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading status: {error}'**
  String securityErrorLoading(String error);

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics: {zoneName}'**
  String analyticsTitle(String zoneName);

  /// No description provided for @analyticsLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days Summary'**
  String get analyticsLast30Days;

  /// No description provided for @analyticsTotalRequests.
  ///
  /// In en, this message translates to:
  /// **'Total Requests'**
  String get analyticsTotalRequests;

  /// No description provided for @analyticsTotalBandwidth.
  ///
  /// In en, this message translates to:
  /// **'Total Bandwidth'**
  String get analyticsTotalBandwidth;

  /// No description provided for @analyticsUniqueVisitors.
  ///
  /// In en, this message translates to:
  /// **'Unique Visitors'**
  String get analyticsUniqueVisitors;

  /// No description provided for @analyticsPageViews.
  ///
  /// In en, this message translates to:
  /// **'Page Views'**
  String get analyticsPageViews;

  /// No description provided for @analyticsCached.
  ///
  /// In en, this message translates to:
  /// **'Cached'**
  String get analyticsCached;

  /// No description provided for @analyticsUncached.
  ///
  /// In en, this message translates to:
  /// **'Uncached'**
  String get analyticsUncached;

  /// No description provided for @analyticsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Analytics data is not available for this zone or plan.'**
  String get analyticsUnavailable;

  /// No description provided for @analyticsDetails.
  ///
  /// In en, this message translates to:
  /// **'Details: {error}'**
  String analyticsDetails(String error);

  /// No description provided for @cachingTitle.
  ///
  /// In en, this message translates to:
  /// **'Caching: {zoneName}'**
  String cachingTitle(String zoneName);

  /// No description provided for @cachePurgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Purge Cache'**
  String get cachePurgeTitle;

  /// No description provided for @cachePurgeDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear cached files to force Cloudflare to fetch a fresh version of those files from your web server.'**
  String get cachePurgeDesc;

  /// No description provided for @cachePurgeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Purge Everything?'**
  String get cachePurgeConfirmTitle;

  /// No description provided for @cachePurgeConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'This will clear all cached resources for this zone. It may temporarily increase load on your origin server. Are you sure?'**
  String get cachePurgeConfirmContent;

  /// No description provided for @cachePurge.
  ///
  /// In en, this message translates to:
  /// **'Purge'**
  String get cachePurge;

  /// No description provided for @cachePurgeButton.
  ///
  /// In en, this message translates to:
  /// **'Purge Everything'**
  String get cachePurgeButton;

  /// No description provided for @cachePurging.
  ///
  /// In en, this message translates to:
  /// **'Purging...'**
  String get cachePurging;

  /// No description provided for @cachePurgeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cache successfully purged!'**
  String get cachePurgeSuccess;

  /// No description provided for @sslTitle.
  ///
  /// In en, this message translates to:
  /// **'SSL/TLS: {zoneName}'**
  String sslTitle(String zoneName);

  /// No description provided for @sslEncryptionMode.
  ///
  /// In en, this message translates to:
  /// **'Encryption Mode'**
  String get sslEncryptionMode;

  /// No description provided for @sslEncryptionModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose how Cloudflare connects to your origin server.'**
  String get sslEncryptionModeDesc;

  /// No description provided for @sslModeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get sslModeOff;

  /// No description provided for @sslModeOffDesc.
  ///
  /// In en, this message translates to:
  /// **'No encryption applied.'**
  String get sslModeOffDesc;

  /// No description provided for @sslModeFlexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get sslModeFlexible;

  /// No description provided for @sslModeFlexibleDesc.
  ///
  /// In en, this message translates to:
  /// **'Encrypts traffic between the browser and Cloudflare.'**
  String get sslModeFlexibleDesc;

  /// No description provided for @sslModeFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get sslModeFull;

  /// No description provided for @sslModeFullDesc.
  ///
  /// In en, this message translates to:
  /// **'Encrypts end-to-end, using a self-signed cert on the server.'**
  String get sslModeFullDesc;

  /// No description provided for @sslModeStrict.
  ///
  /// In en, this message translates to:
  /// **'Full (strict)'**
  String get sslModeStrict;

  /// No description provided for @sslModeStrictDesc.
  ///
  /// In en, this message translates to:
  /// **'Encrypts end-to-end, requires a trusted CA or Cloudflare Origin CA cert on the server.'**
  String get sslModeStrictDesc;

  /// No description provided for @sslEdgeCertificates.
  ///
  /// In en, this message translates to:
  /// **'Edge Certificates'**
  String get sslEdgeCertificates;

  /// No description provided for @sslEdgeCertificatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Active certificates protecting your domain.'**
  String get sslEdgeCertificatesDesc;

  /// No description provided for @sslNoCerts.
  ///
  /// In en, this message translates to:
  /// **'No edge certificates found.'**
  String get sslNoCerts;

  /// No description provided for @sslHosts.
  ///
  /// In en, this message translates to:
  /// **'Hosts:'**
  String get sslHosts;

  /// No description provided for @sslUpdated.
  ///
  /// In en, this message translates to:
  /// **'SSL/TLS mode updated!'**
  String get sslUpdated;

  /// No description provided for @sslCertError.
  ///
  /// In en, this message translates to:
  /// **'Error loading certificates: {error}'**
  String sslCertError(String error);

  /// No description provided for @storageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageTitle;

  /// No description provided for @storageCreateKV.
  ///
  /// In en, this message translates to:
  /// **'Create KV Namespace'**
  String get storageCreateKV;

  /// No description provided for @storageCreateD1.
  ///
  /// In en, this message translates to:
  /// **'Create D1 Database'**
  String get storageCreateD1;

  /// No description provided for @storageCreateR2.
  ///
  /// In en, this message translates to:
  /// **'Create R2 Bucket'**
  String get storageCreateR2;

  /// No description provided for @storageCreateHint.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get storageCreateHint;

  /// No description provided for @storageCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'{title} created successfully!'**
  String storageCreateSuccess(String title);

  /// No description provided for @pageDashboardDeployments.
  ///
  /// In en, this message translates to:
  /// **'Deployments'**
  String get pageDashboardDeployments;

  /// No description provided for @pageDashboardDomains.
  ///
  /// In en, this message translates to:
  /// **'Domains'**
  String get pageDashboardDomains;

  /// No description provided for @pageDashboardBindings.
  ///
  /// In en, this message translates to:
  /// **'Bindings'**
  String get pageDashboardBindings;

  /// No description provided for @pageDashboardNoDeployments.
  ///
  /// In en, this message translates to:
  /// **'No deployments found.'**
  String get pageDashboardNoDeployments;

  /// No description provided for @pageDashboardProduction.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get pageDashboardProduction;

  /// No description provided for @pageDashboardPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get pageDashboardPreview;

  /// No description provided for @pageDashboardNoDomains.
  ///
  /// In en, this message translates to:
  /// **'No custom domains configured.'**
  String get pageDashboardNoDomains;

  /// No description provided for @pageDashboardAddDomain.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Domain'**
  String get pageDashboardAddDomain;

  /// No description provided for @pageDashboardDomainName.
  ///
  /// In en, this message translates to:
  /// **'Domain name'**
  String get pageDashboardDomainName;

  /// No description provided for @pageDashboardDomainHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. mail.example.com'**
  String get pageDashboardDomainHint;

  /// No description provided for @pageDashboardAddDomainSuccess.
  ///
  /// In en, this message translates to:
  /// **'Domain added and CNAME auto-configured!'**
  String get pageDashboardAddDomainSuccess;

  /// No description provided for @pageDashboardAddDomainManual.
  ///
  /// In en, this message translates to:
  /// **'Domain added! Please add the CNAME manually.'**
  String get pageDashboardAddDomainManual;

  /// No description provided for @pageDashboardRemoveDomainTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Domain?'**
  String get pageDashboardRemoveDomainTitle;

  /// No description provided for @pageDashboardRemoveDomainContent.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from this project?'**
  String pageDashboardRemoveDomainContent(String name);

  /// No description provided for @pageDashboardRemoveDomainConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get pageDashboardRemoveDomainConfirm;

  /// No description provided for @pageDashboardRemoveDomainSuccess.
  ///
  /// In en, this message translates to:
  /// **'Domain removed.'**
  String get pageDashboardRemoveDomainSuccess;

  /// No description provided for @pageDashboardEnvVars.
  ///
  /// In en, this message translates to:
  /// **'Environment Variables'**
  String get pageDashboardEnvVars;

  /// No description provided for @pageDashboardNoBindings.
  ///
  /// In en, this message translates to:
  /// **'No bindings configured.'**
  String get pageDashboardNoBindings;

  /// No description provided for @pageDashboardAddBinding.
  ///
  /// In en, this message translates to:
  /// **'Add Binding'**
  String get pageDashboardAddBinding;

  /// No description provided for @pageDashboardAddSecret.
  ///
  /// In en, this message translates to:
  /// **'Add Secret'**
  String get pageDashboardAddSecret;

  /// No description provided for @pageDashboardKV.
  ///
  /// In en, this message translates to:
  /// **'KV Namespace'**
  String get pageDashboardKV;

  /// No description provided for @pageDashboardD1.
  ///
  /// In en, this message translates to:
  /// **'D1 Database'**
  String get pageDashboardD1;

  /// No description provided for @pageDashboardR2.
  ///
  /// In en, this message translates to:
  /// **'R2 Bucket'**
  String get pageDashboardR2;

  /// No description provided for @pageDashboardService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get pageDashboardService;

  /// No description provided for @pageDashboardEnvVar.
  ///
  /// In en, this message translates to:
  /// **'Env Var'**
  String get pageDashboardEnvVar;

  /// No description provided for @pageDashboardSecret.
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get pageDashboardSecret;

  /// No description provided for @storageEditKVTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit KV Namespace'**
  String get storageEditKVTitle;

  /// No description provided for @storageEditKVPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter new title'**
  String get storageEditKVPrompt;

  /// No description provided for @storageUpdateKVSuccess.
  ///
  /// In en, this message translates to:
  /// **'KV Namespace updated successfully!'**
  String get storageUpdateKVSuccess;

  /// No description provided for @storageDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {item}'**
  String storageDeleteTitle(String item);

  /// No description provided for @storageDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String storageDeleteContent(String name);

  /// No description provided for @storageDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'{item} deleted successfully!'**
  String storageDeleteSuccess(String item);

  /// No description provided for @storageNoItems.
  ///
  /// In en, this message translates to:
  /// **'No {item} found'**
  String storageNoItems(String item);

  /// No description provided for @storageCopyId.
  ///
  /// In en, this message translates to:
  /// **'ID copied to clipboard'**
  String get storageCopyId;

  /// No description provided for @storageCopyUuid.
  ///
  /// In en, this message translates to:
  /// **'UUID copied to clipboard'**
  String get storageCopyUuid;

  /// No description provided for @storageCreated.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String storageCreated(String date);

  /// No description provided for @storageRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get storageRename;

  /// No description provided for @pageDashboardSecretAdded.
  ///
  /// In en, this message translates to:
  /// **'Secret added.'**
  String get pageDashboardSecretAdded;

  /// No description provided for @pageDashboardSecretDeleted.
  ///
  /// In en, this message translates to:
  /// **'Secret deleted.'**
  String get pageDashboardSecretDeleted;

  /// No description provided for @pageDashboardDeleteBindingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Binding?'**
  String get pageDashboardDeleteBindingTitle;

  /// No description provided for @pageDashboardDeleteBindingContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String pageDashboardDeleteBindingContent(String name);

  /// No description provided for @pageDashboardBindingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Binding deleted.'**
  String get pageDashboardBindingDeleted;

  /// No description provided for @pageDashboardBindingAdded.
  ///
  /// In en, this message translates to:
  /// **'Binding added.'**
  String get pageDashboardBindingAdded;

  /// No description provided for @pageDashboardBindingTypeEnv.
  ///
  /// In en, this message translates to:
  /// **'Plain Text (Env Var)'**
  String get pageDashboardBindingTypeEnv;

  /// No description provided for @pageDashboardBindingTypeKV.
  ///
  /// In en, this message translates to:
  /// **'KV Namespace'**
  String get pageDashboardBindingTypeKV;

  /// No description provided for @pageDashboardBindingTypeD1.
  ///
  /// In en, this message translates to:
  /// **'D1 Database'**
  String get pageDashboardBindingTypeD1;

  /// No description provided for @workerDashboardRedeploying.
  ///
  /// In en, this message translates to:
  /// **'Redeploying to remove binding...'**
  String get workerDashboardRedeploying;

  /// No description provided for @workerDashboardPleaseDeploy.
  ///
  /// In en, this message translates to:
  /// **'Please deploy the worker first to configure triggers.'**
  String get workerDashboardPleaseDeploy;

  /// No description provided for @workerDashboardDeleteScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Schedule?'**
  String get workerDashboardDeleteScheduleTitle;

  /// No description provided for @workerDashboardScheduleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Schedule deleted.'**
  String get workerDashboardScheduleDeleted;

  /// No description provided for @workerDashboardDeleteDomainTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Domain?'**
  String get workerDashboardDeleteDomainTitle;

  /// No description provided for @workerDashboardDomainDeleted.
  ///
  /// In en, this message translates to:
  /// **'Domain deleted.'**
  String get workerDashboardDomainDeleted;

  /// No description provided for @workerDashboardAddDomainTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Domain'**
  String get workerDashboardAddDomainTitle;

  /// No description provided for @workerDashboardDomainAdded.
  ///
  /// In en, this message translates to:
  /// **'Domain added successfully.'**
  String get workerDashboardDomainAdded;

  /// No description provided for @workerDashboardDeployCode.
  ///
  /// In en, this message translates to:
  /// **'Deploy Code'**
  String get workerDashboardDeployCode;

  /// No description provided for @workerCron1m.
  ///
  /// In en, this message translates to:
  /// **'1 min'**
  String get workerCron1m;

  /// No description provided for @workerCron5m.
  ///
  /// In en, this message translates to:
  /// **'5 mins'**
  String get workerCron5m;

  /// No description provided for @workerCron15m.
  ///
  /// In en, this message translates to:
  /// **'15 mins'**
  String get workerCron15m;

  /// No description provided for @workerCron30m.
  ///
  /// In en, this message translates to:
  /// **'30 mins'**
  String get workerCron30m;

  /// No description provided for @workerCronHourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get workerCronHourly;

  /// No description provided for @workerCronDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get workerCronDaily;

  /// No description provided for @workerCronWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get workerCronWeekly;

  /// No description provided for @workerDashboardTabBindings.
  ///
  /// In en, this message translates to:
  /// **'Bindings & Secrets'**
  String get workerDashboardTabBindings;

  /// No description provided for @workerDashboardTabTriggers.
  ///
  /// In en, this message translates to:
  /// **'Triggers & Routes'**
  String get workerDashboardTabTriggers;

  /// No description provided for @workerDashboardTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get workerDashboardTabHistory;

  /// No description provided for @workerDashboardTabEditor.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get workerDashboardTabEditor;

  /// No description provided for @workerDashboardNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No history for new worker.'**
  String get workerDashboardNoHistory;

  /// No description provided for @workerDashboardNoDeployments.
  ///
  /// In en, this message translates to:
  /// **'No deployment history.'**
  String get workerDashboardNoDeployments;

  /// No description provided for @workerDashboardNoBindings.
  ///
  /// In en, this message translates to:
  /// **'No bindings or secrets configured.'**
  String get workerDashboardNoBindings;

  /// No description provided for @workerDashboardAddBinding.
  ///
  /// In en, this message translates to:
  /// **'Add Binding'**
  String get workerDashboardAddBinding;

  /// No description provided for @workerDashboardAddSecret.
  ///
  /// In en, this message translates to:
  /// **'Add Secret'**
  String get workerDashboardAddSecret;

  /// No description provided for @workerDashboardDeleteSecretTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Secret?'**
  String get workerDashboardDeleteSecretTitle;

  /// No description provided for @workerDashboardDeleteSecretContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the secret \"{name}\"?'**
  String workerDashboardDeleteSecretContent(String name);

  /// No description provided for @workerDashboardDeleteBindingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Binding?'**
  String get workerDashboardDeleteBindingTitle;

  /// No description provided for @workerDashboardDeleteBindingContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the binding \"{name}\"?\nThis will redeploy your code.'**
  String workerDashboardDeleteBindingContent(String name);

  /// No description provided for @workerDashboardDeleteScheduleContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the schedule \"{name}\"?'**
  String workerDashboardDeleteScheduleContent(String name);

  /// No description provided for @workerDashboardDeleteDomainContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the domain \"{name}\"?'**
  String workerDashboardDeleteDomainContent(String name);

  /// No description provided for @workerDashboardDeployedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deployed Successfully!'**
  String get workerDashboardDeployedSuccess;

  /// No description provided for @formSecretNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Secret Name (e.g. API_KEY)'**
  String get formSecretNameLabel;

  /// No description provided for @formSecretValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Secret Value'**
  String get formSecretValueLabel;

  /// No description provided for @formBindingTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Binding Type'**
  String get formBindingTypeLabel;

  /// No description provided for @formBindingNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Binding Name (e.g. DB, MY_KV, API_URL)'**
  String get formBindingNameLabel;

  /// No description provided for @formBindingValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get formBindingValueLabel;

  /// No description provided for @formBindingKvNamespaceLabel.
  ///
  /// In en, this message translates to:
  /// **'KV Namespace ID'**
  String get formBindingKvNamespaceLabel;

  /// No description provided for @formBindingSelectKvLabel.
  ///
  /// In en, this message translates to:
  /// **'Select KV Namespace'**
  String get formBindingSelectKvLabel;

  /// No description provided for @formBindingD1DatabaseLabel.
  ///
  /// In en, this message translates to:
  /// **'D1 Database ID'**
  String get formBindingD1DatabaseLabel;

  /// No description provided for @formBindingSelectD1Label.
  ///
  /// In en, this message translates to:
  /// **'Select D1 Database'**
  String get formBindingSelectD1Label;

  /// No description provided for @formCronExpressionLabel.
  ///
  /// In en, this message translates to:
  /// **'Cron Expression'**
  String get formCronExpressionLabel;

  /// No description provided for @formCronExpressionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. * * * * * or */5 * * * *'**
  String get formCronExpressionHint;

  /// No description provided for @formHostnameLabel.
  ///
  /// In en, this message translates to:
  /// **'Hostname'**
  String get formHostnameLabel;

  /// No description provided for @formHostnameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. api.example.com'**
  String get formHostnameHint;

  /// No description provided for @commonOpenSite.
  ///
  /// In en, this message translates to:
  /// **'Open site'**
  String get commonOpenSite;

  /// No description provided for @commonOpenInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get commonOpenInBrowser;

  /// No description provided for @workerCronEveryMinute.
  ///
  /// In en, this message translates to:
  /// **'Every minute'**
  String get workerCronEveryMinute;

  /// No description provided for @workerCronEvery5Minutes.
  ///
  /// In en, this message translates to:
  /// **'Every 5 minutes'**
  String get workerCronEvery5Minutes;

  /// No description provided for @workerCronEvery15Minutes.
  ///
  /// In en, this message translates to:
  /// **'Every 15 minutes'**
  String get workerCronEvery15Minutes;

  /// No description provided for @workerCronEvery30Minutes.
  ///
  /// In en, this message translates to:
  /// **'Every 30 minutes'**
  String get workerCronEvery30Minutes;

  /// No description provided for @workerCronEveryHour.
  ///
  /// In en, this message translates to:
  /// **'Every hour'**
  String get workerCronEveryHour;

  /// No description provided for @workerCronEvery6Hours.
  ///
  /// In en, this message translates to:
  /// **'Every 6 hours'**
  String get workerCronEvery6Hours;

  /// No description provided for @workerCronEvery12Hours.
  ///
  /// In en, this message translates to:
  /// **'Every 12 hours'**
  String get workerCronEvery12Hours;

  /// No description provided for @workerCronOnceADay.
  ///
  /// In en, this message translates to:
  /// **'Once a day (midnight)'**
  String get workerCronOnceADay;

  /// No description provided for @workerCronEveryDay9Am.
  ///
  /// In en, this message translates to:
  /// **'Every day at 9 AM'**
  String get workerCronEveryDay9Am;

  /// No description provided for @workerCronEverySunday.
  ///
  /// In en, this message translates to:
  /// **'Every Sunday'**
  String get workerCronEverySunday;

  /// No description provided for @workerCronFirstDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'First day of each month'**
  String get workerCronFirstDayOfMonth;

  /// No description provided for @workerCronCustomSchedule.
  ///
  /// In en, this message translates to:
  /// **'Custom schedule'**
  String get workerCronCustomSchedule;

  /// No description provided for @workerDashboardCustomDomainsRoutes.
  ///
  /// In en, this message translates to:
  /// **'Custom Domains / Routes'**
  String get workerDashboardCustomDomainsRoutes;

  /// No description provided for @workerDashboardCronSchedules.
  ///
  /// In en, this message translates to:
  /// **'Cron Schedules'**
  String get workerDashboardCronSchedules;

  /// No description provided for @workerDashboardNoCustomDomains.
  ///
  /// In en, this message translates to:
  /// **'No custom domains configured.'**
  String get workerDashboardNoCustomDomains;

  /// No description provided for @workerDashboardNoCronSchedules.
  ///
  /// In en, this message translates to:
  /// **'No cron schedules configured.'**
  String get workerDashboardNoCronSchedules;

  /// No description provided for @workerDashboardEditBinding.
  ///
  /// In en, this message translates to:
  /// **'Edit Binding'**
  String get workerDashboardEditBinding;

  /// No description provided for @workerDashboardAddDeploy.
  ///
  /// In en, this message translates to:
  /// **'Add (Deploy)'**
  String get workerDashboardAddDeploy;

  /// No description provided for @workerDashboardUpdateDeploy.
  ///
  /// In en, this message translates to:
  /// **'Update (Deploy)'**
  String get workerDashboardUpdateDeploy;

  /// No description provided for @workerDashboardEditSecret.
  ///
  /// In en, this message translates to:
  /// **'Edit Secret'**
  String get workerDashboardEditSecret;

  /// No description provided for @formNewSecretValueLabel.
  ///
  /// In en, this message translates to:
  /// **'New Secret Value'**
  String get formNewSecretValueLabel;

  /// No description provided for @workerDashboardSecretAdded.
  ///
  /// In en, this message translates to:
  /// **'Secret added.'**
  String get workerDashboardSecretAdded;

  /// No description provided for @workerDashboardSecretUpdated.
  ///
  /// In en, this message translates to:
  /// **'Secret updated.'**
  String get workerDashboardSecretUpdated;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get commonUpdate;

  /// No description provided for @dnsFormHintSrv.
  ///
  /// In en, this message translates to:
  /// **'Target (e.g. example.com). For SRV use data API for full control, or format content appropriately.'**
  String get dnsFormHintSrv;

  /// No description provided for @dnsFormHintDefault.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get dnsFormHintDefault;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
