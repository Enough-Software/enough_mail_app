// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get signature => '由 Maily 发送';

  @override
  String get actionCancel => '取消';

  @override
  String get actionOk => '确定';

  @override
  String get actionDone => '完成';

  @override
  String get actionNext => '下一步';

  @override
  String get actionSkip => '跳过';

  @override
  String get actionUndo => '撤销';

  @override
  String get actionDelete => '删除';

  @override
  String get actionAccept => '接受';

  @override
  String get actionDecline => '拒绝';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionAddressCopy => '复制';

  @override
  String get actionAddressCompose => '新建邮件';

  @override
  String get actionAddressSearch => '搜索';

  @override
  String get splashLoading1 => 'Maily 启动中...';

  @override
  String get splashLoading2 => '准备您的 Maily 引擎...';

  @override
  String get splashLoading3 => '10、9、8… 启动 Maily';

  @override
  String get welcomePanel1Title => 'Maily';

  @override
  String get welcomePanel1Text => '欢迎使用 Maily，您友好且快速的邮件助手！';

  @override
  String get welcomePanel2Title => '账户';

  @override
  String get welcomePanel2Text => '管理无限数量的邮件账户。同时在所有账户中阅读和搜索邮件。';

  @override
  String get welcomePanel3Title => 'Swipe & Long-Press';

  @override
  String get welcomePanel3Text => '滑动邮件进行删除或标记为已读。长按邮件可以选择和管理多封邮件。';

  @override
  String get welcomePanel4Title => '保持收件箱整洁';

  @override
  String get welcomePanel4Text => '只需点击一下即可取消订阅新闻通讯。';

  @override
  String get welcomeActionSignIn => '登录您的邮件账户';

  @override
  String get homeSearchHint => '您的搜索';

  @override
  String get homeActionsShowAsStack => '堆叠显示';

  @override
  String get homeActionsShowAsList => '列表显示';

  @override
  String get homeEmptyFolderMessage => '全部完成！\n\n此文件夹中没有邮件。';

  @override
  String get homeEmptySearchMessage => '未找到邮件。';

  @override
  String get homeDeleteAllTitle => '确认';

  @override
  String get homeDeleteAllQuestion => '确定要删除所有邮件吗？';

  @override
  String get homeDeleteAllAction => '全部删除';

  @override
  String get homeDeleteAllScrubOption => '清理邮件';

  @override
  String get homeDeleteAllSuccess => '所有邮件已删除。';

  @override
  String get homeMarkAllSeenAction => '全部已读';

  @override
  String get homeMarkAllUnseenAction => '全部未读';

  @override
  String get homeFabTooltip => '新建邮件';

  @override
  String get homeLoadingMessageSourceTitle => '加载中...';

  @override
  String homeLoading(String name) {
    return '正在加载 $name...';
  }

  @override
  String get swipeActionToggleRead => '标记为已读/未读';

  @override
  String get swipeActionDelete => '删除';

  @override
  String get swipeActionMarkJunk => '标记为垃圾邮件';

  @override
  String get swipeActionArchive => '归档';

  @override
  String get swipeActionFlag => '切换星标';

  @override
  String multipleMovedToJunk(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString 封邮件已标记为垃圾邮件',
      one: '一封邮件已标记为垃圾邮件',
    );
    return '$_temp0';
  }

  @override
  String multipleMovedToInbox(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString 封邮件已移至收件箱',
      one: '一封邮件已移至收件箱',
    );
    return '$_temp0';
  }

  @override
  String multipleMovedToArchive(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString 封邮件已归档',
      one: '一封邮件已归档',
    );
    return '$_temp0';
  }

  @override
  String multipleMovedToTrash(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString 封邮件已删除',
      one: '一封邮件已删除',
    );
    return '$_temp0';
  }

  @override
  String get multipleSelectionNeededInfo => '请先选择邮件。';

  @override
  String multipleSelectionActionFailed(String details) {
    return '无法执行操作\n详细信息：$details';
  }

  @override
  String multipleMoveTitle(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '移动 $numberString 封邮件',
      one: '移动邮件',
    );
    return '$_temp0';
  }

  @override
  String get messageActionMultipleMarkSeen => 'Mark as read';

  @override
  String get messageActionMultipleMarkUnseen => 'Mark as unread';

  @override
  String get messageActionMultipleMarkFlagged => '标记星标';

  @override
  String get messageActionMultipleMarkUnflagged => '取消星标';

  @override
  String get messageActionViewInSafeMode => '不加载外部内容查看';

  @override
  String get emailSenderUnknown => '<no sender>';

  @override
  String get dateRangeFuture => '未来';

  @override
  String get dateRangeTomorrow => '明天';

  @override
  String get dateRangeToday => '今天';

  @override
  String get dateRangeYesterday => '昨天';

  @override
  String get dateRangeCurrentWeek => '本周';

  @override
  String get dateRangeLastWeek => '上周';

  @override
  String get dateRangeCurrentMonth => '本月';

  @override
  String get dateRangeLastMonth => '上月';

  @override
  String get dateRangeCurrentYear => '今年';

  @override
  String get dateRangeLongAgo => '更早';

  @override
  String get dateUndefined => '未定义';

  @override
  String get dateDayToday => '今天';

  @override
  String get dateDayYesterday => '昨天';

  @override
  String dateDayLastWeekday(String day) {
    return '上$day';
  }

  @override
  String get drawerEntryAbout => '关于 Maily';

  @override
  String get drawerEntrySettings => '设置';

  @override
  String drawerAccountsSectionTitle(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString 个账户',
      one: '一个账户',
    );
    return '$_temp0';
  }

  @override
  String get drawerEntryAddAccount => '添加账户';

  @override
  String get unifiedAccountName => '统一账户';

  @override
  String get unifiedFolderInbox => '统一收件箱';

  @override
  String get unifiedFolderSent => '统一已发送';

  @override
  String get unifiedFolderDrafts => '统一草稿';

  @override
  String get unifiedFolderTrash => '统一垃圾箱';

  @override
  String get unifiedFolderArchive => '统一归档';

  @override
  String get unifiedFolderJunk => '统一垃圾邮件';

  @override
  String get folderInbox => '收件箱';

  @override
  String get folderSent => '已发送';

  @override
  String get folderDrafts => '草稿';

  @override
  String get folderTrash => '垃圾箱';

  @override
  String get folderArchive => '归档';

  @override
  String get folderJunk => '垃圾邮件';

  @override
  String get folderUnknown => '未知';

  @override
  String get viewContentsAction => '查看内容';

  @override
  String get viewSourceAction => '查看源代码';

  @override
  String get detailsErrorDownloadInfo => '无法下载邮件。';

  @override
  String get detailsErrorDownloadRetry => '重试';

  @override
  String get detailsHeaderFrom => '发件人';

  @override
  String get detailsHeaderTo => '收件人';

  @override
  String get detailsHeaderCc => 'CC';

  @override
  String get detailsHeaderBcc => 'BCC';

  @override
  String get detailsHeaderDate => '日期';

  @override
  String get subjectUndefined => '<without subject>';

  @override
  String get detailsActionShowImages => '显示图片';

  @override
  String get detailsNewsletterActionUnsubscribe => '取消订阅';

  @override
  String get detailsNewsletterActionResubscribe => '重新订阅';

  @override
  String get detailsNewsletterStatusUnsubscribed => '已取消订阅';

  @override
  String get detailsNewsletterUnsubscribeDialogTitle => '取消订阅';

  @override
  String detailsNewsletterUnsubscribeDialogQuestion(String listName) {
    return '您确定要取消订阅 $listName 吗？';
  }

  @override
  String get detailsNewsletterUnsubscribeDialogAction => '取消订阅';

  @override
  String get detailsNewsletterUnsubscribeSuccessTitle => '已取消订阅';

  @override
  String detailsNewsletterUnsubscribeSuccessMessage(String listName) {
    return '您已成功取消订阅 $listName。';
  }

  @override
  String get detailsNewsletterUnsubscribeFailureTitle => '取消订阅失败';

  @override
  String detailsNewsletterUnsubscribeFailureMessage(String listName) {
    return '抱歉，我无法自动取消订阅 $listName。';
  }

  @override
  String get detailsNewsletterResubscribeDialogTitle => '重新订阅';

  @override
  String detailsNewsletterResubscribeDialogQuestion(String listName) {
    return '您确定要重新订阅 $listName 吗？';
  }

  @override
  String get detailsNewsletterResubscribeDialogAction => '订阅';

  @override
  String get detailsNewsletterResubscribeSuccessTitle => '已订阅';

  @override
  String detailsNewsletterResubscribeSuccessMessage(String listName) {
    return '您已重新订阅 $listName。';
  }

  @override
  String get detailsNewsletterResubscribeFailureTitle => 'Not subscribed';

  @override
  String detailsNewsletterResubscribeFailureMessage(String listName) {
    return '抱歉，$listName 的订阅请求失败了。';
  }

  @override
  String get detailsSendReadReceiptAction => '发送已读回执';

  @override
  String get detailsReadReceiptSentStatus => '已读回执已发送 ✔';

  @override
  String get detailsReadReceiptSubject => '已读回执';

  @override
  String get attachmentActionOpen => '打开';

  @override
  String attachmentDecodeError(String details) {
    return 'This attachment has an unsupported format or encoding.\nDetails: \$$details';
  }

  @override
  String attachmentDownloadError(String details) {
    return 'Unable to download this attachment.\nDetails: \$$details';
  }

  @override
  String get messageActionReply => '回复';

  @override
  String get messageActionReplyAll => '全部回复';

  @override
  String get messageActionForward => '转发';

  @override
  String get messageActionForwardAsAttachment => '作为附件转发';

  @override
  String messageActionForwardAttachments(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '转发 $numberString 个附件',
      one: '转发附件',
    );
    return '$_temp0';
  }

  @override
  String get messagesActionForwardAttachments => '转发附件';

  @override
  String get messageActionDelete => '删除';

  @override
  String get messageActionMoveToInbox => '移至收件箱';

  @override
  String get messageActionMove => '移动';

  @override
  String get messageStatusSeen => '已读';

  @override
  String get messageStatusUnseen => '未读';

  @override
  String get messageStatusFlagged => '已星标';

  @override
  String get messageStatusUnflagged => '未星标';

  @override
  String get messageActionMarkAsJunk => '标记为垃圾邮件';

  @override
  String get messageActionMarkAsNotJunk => '标记为非垃圾邮件';

  @override
  String get messageActionArchive => '归档';

  @override
  String get messageActionUnarchive => '移至收件箱';

  @override
  String get messageActionRedirect => '重定向';

  @override
  String get messageActionAddNotification => '添加通知';

  @override
  String get resultDeleted => '已删除';

  @override
  String get resultMovedToJunk => '已标记为垃圾邮件';

  @override
  String get resultMovedToInbox => '已移至收件箱';

  @override
  String get resultArchived => '已归档';

  @override
  String get resultRedirectedSuccess => '邮件已重定向 👍';

  @override
  String resultRedirectedFailure(String details) {
    return 'Unable to redirect message.\n\nThe server responded with the following details: \"$details\"';
  }

  @override
  String get redirectTitle => '重定向';

  @override
  String get redirectInfo => '将此邮件重定向到以下收件人。重定向不会更改邮件内容。';

  @override
  String get redirectEmailInputRequired => '您需要添加至少一个有效的电子邮件地址。';

  @override
  String searchQueryDescription(String folder) {
    return '在 $folder 中搜索...';
  }

  @override
  String searchQueryTitle(String query) {
    return '搜索 \"$query\"';
  }

  @override
  String get legaleseUsage => '使用 Maily 即表示您同意我们的 [PP] 和 [TC]。';

  @override
  String get legalesePrivacyPolicy => '隐私政策';

  @override
  String get legaleseTermsAndConditions => 'Terms & Conditions';

  @override
  String get aboutApplicationLegalese => 'Maily 是根据 GNU 通用公共许可证发布的自由软件。';

  @override
  String get feedbackActionSuggestFeature => '建议功能';

  @override
  String get feedbackActionReportProblem => '报告问题';

  @override
  String get feedbackActionHelpDeveloping => '帮助开发 Maily';

  @override
  String get feedbackTitle => '反馈';

  @override
  String get feedbackIntro => '感谢您测试 Maily！';

  @override
  String get feedbackProvideInfoRequest => '报告问题时请提供以下信息：';

  @override
  String get feedbackResultInfoCopied => '已复制到剪贴板';

  @override
  String get accountsTitle => '账户';

  @override
  String get accountsActionReorder => '重新排序账户';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSecurityBlockExternalImages => '阻止外部图片';

  @override
  String get settingsSecurityBlockExternalImagesDescriptionTitle => '外部图片';

  @override
  String get settingsSecurityBlockExternalImagesDescriptionText =>
      '电子邮件可能包含集成或托管在外部服务器上的图片。外部图片可能会向邮件发件人暴露信息，例如让发件人知道您已打开邮件。此选项允许您阻止此类外部图片，从而降低暴露敏感信息的风险。您仍然可以在阅读邮件时选择逐封加载这些图片。';

  @override
  String get settingsSecurityMessageRenderingHtml => '显示完整邮件内容';

  @override
  String get settingsSecurityMessageRenderingPlainText => '仅显示邮件文本';

  @override
  String get settingsSecurityLaunchModeLabel => 'Maily 应如何打开链接？';

  @override
  String get settingsSecurityLaunchModeExternal => '在外部打开链接';

  @override
  String get settingsSecurityLaunchModeInApp => '在 Maily 中打开链接';

  @override
  String get settingsActionAccounts => '管理账户';

  @override
  String get settingsActionDesign => '外观';

  @override
  String get settingsActionFeedback => '提供反馈';

  @override
  String get settingsActionWelcome => '显示欢迎页面';

  @override
  String get settingsReadReceipts => '已读回执';

  @override
  String get readReceiptsSettingsIntroduction => '您是否要显示已读回执请求？';

  @override
  String get readReceiptOptionAlways => '始终';

  @override
  String get readReceiptOptionNever => '从不';

  @override
  String get settingsFolders => '文件夹';

  @override
  String get folderNamesIntroduction => '您希望文件夹使用什么名称？';

  @override
  String get folderNamesSettingLocalized => 'Maily 提供的名称';

  @override
  String get folderNamesSettingServer => '服务提供的名称';

  @override
  String get folderNamesSettingCustom => '我自定义的名称';

  @override
  String get folderNamesEditAction => '编辑自定义名称';

  @override
  String get folderNamesCustomTitle => '自定义名称';

  @override
  String get folderAddAction => '创建文件夹';

  @override
  String get folderAddTitle => '创建文件夹';

  @override
  String get folderAddNameLabel => '名称';

  @override
  String get folderAddNameHint => '新文件夹的名称';

  @override
  String get folderAccountLabel => '账户';

  @override
  String get folderMailboxLabel => '文件夹';

  @override
  String get folderAddResultSuccess => '文件夹已创建 😊';

  @override
  String folderAddResultFailure(String details) {
    return '无法创建文件夹。\n\n服务器返回 $details';
  }

  @override
  String get folderDeleteAction => '删除';

  @override
  String get folderDeleteConfirmTitle => '确认';

  @override
  String folderDeleteConfirmText(String name) {
    return '您确定要删除文件夹 $name 吗？';
  }

  @override
  String get folderDeleteResultSuccess => '文件夹已删除。';

  @override
  String folderDeleteResultFailure(String details) {
    return '无法删除文件夹。\n\n服务器返回 $details';
  }

  @override
  String get settingsDevelopment => '开发设置';

  @override
  String get developerModeTitle => '开发模式';

  @override
  String get developerModeIntroduction => '如果启用开发模式，您将能够查看邮件的源代码并将文本附件转换为邮件。';

  @override
  String get developerModeEnable => '启用开发模式';

  @override
  String get developerShowAsEmail => '转换为电子邮件';

  @override
  String get developerShowAsEmailFailed => '此文本无法转换为 MIME 邮件。';

  @override
  String get designTitle => '外观设置';

  @override
  String get designSectionThemeTitle => '主题';

  @override
  String get designThemeOptionLight => '浅色';

  @override
  String get designThemeOptionDark => '深色';

  @override
  String get designThemeOptionSystem => '跟随系统';

  @override
  String get designThemeOptionCustom => '自定义';

  @override
  String get designSectionCustomTitle => '启用深色主题';

  @override
  String designThemeCustomStart(String time) {
    return '从 $time 开始';
  }

  @override
  String designThemeCustomEnd(String time) {
    return '到 $time 结束';
  }

  @override
  String get designSectionColorTitle => '配色方案';

  @override
  String get securitySettingsTitle => '安全性';

  @override
  String get securitySettingsIntro => '根据您的个人需求调整安全设置。';

  @override
  String get securityUnlockWithFaceId => '使用 Face ID 解锁 Maily。';

  @override
  String get securityUnlockWithTouchId => '使用 Touch ID 解锁 Maily。';

  @override
  String get securityUnlockReason => '解锁 Maily。';

  @override
  String get securityUnlockDisableReason => '解锁 Maily 以关闭锁定。';

  @override
  String get securityUnlockNotAvailable => '您的设备不支持生物识别，您可能需要先设置解锁选项。';

  @override
  String get securityUnlockLabel => '锁定 Maily';

  @override
  String get securityUnlockDescriptionTitle => '锁定 Maily';

  @override
  String get securityUnlockDescriptionText =>
      '您可以选择锁定对 Maily 的访问，这样即使他人有权访问您的设备，也无法阅读您的邮件。';

  @override
  String get securityLockImmediately => '立即锁定';

  @override
  String get securityLockAfter5Minutes => '5 分钟后锁定';

  @override
  String get securityLockAfter30Minutes => '30 分钟后锁定';

  @override
  String get lockScreenTitle => 'Maily 已锁定';

  @override
  String get lockScreenIntro => 'Maily 已锁定，请进行身份验证以继续。';

  @override
  String get lockScreenUnlockAction => '解锁';

  @override
  String get addAccountTitle => '添加账户';

  @override
  String get addAccountEmailLabel => '电子邮件';

  @override
  String get addAccountEmailHint => '请输入您的电子邮件地址';

  @override
  String addAccountResolvingSettingsLabel(String email) {
    return '正在解析 $email...';
  }

  @override
  String addAccountResolvedSettingsWrongAction(String provider) {
    return '不是 $provider？';
  }

  @override
  String addAccountResolvingSettingsFailedInfo(String email) {
    return '无法解析 $email。请返回修改或手动设置账户。';
  }

  @override
  String get addAccountEditManuallyAction => '手动编辑';

  @override
  String get addAccountPasswordLabel => '密码';

  @override
  String get addAccountPasswordHint => '请输入您的密码';

  @override
  String get addAccountApplicationPasswordRequiredInfo => '此提供商要求您设置应用专用密码。';

  @override
  String get addAccountApplicationPasswordRequiredButton => '创建应用专用密码';

  @override
  String get addAccountApplicationPasswordRequiredAcknowledged => '我已有应用密码';

  @override
  String get addAccountVerificationStep => '验证';

  @override
  String get addAccountSetupAccountStep => '账户设置';

  @override
  String addAccountVerifyingSettingsLabel(String email) {
    return '正在验证 $email...';
  }

  @override
  String addAccountVerifyingSuccessInfo(String email) {
    return '成功登录 $email。';
  }

  @override
  String addAccountVerifyingFailedInfo(String email) {
    return '抱歉，出现了问题。请检查您的电子邮件 $email 和密码。';
  }

  @override
  String addAccountOauthOptionsText(String provider) {
    return '使用 $provider 登录或创建应用专用密码。';
  }

  @override
  String addAccountOauthSignIn(String provider) {
    return '使用 $provider 登录';
  }

  @override
  String get addAccountOauthSignInGoogle => '使用 Google 登录';

  @override
  String get addAccountOauthSignInWithAppPassword => '或者，创建应用密码进行登录。';

  @override
  String get accountAddImapAccessSetupMightBeRequired =>
      '您的提供商可能要求您手动设置电子邮件应用的访问权限。';

  @override
  String get addAccountSetupImapAccessButtonLabel => '设置电子邮件访问';

  @override
  String get addAccountNameOfUserLabel => '您的姓名';

  @override
  String get addAccountNameOfUserHint => '收件人看到的姓名';

  @override
  String get addAccountNameOfAccountLabel => '账户名称';

  @override
  String get addAccountNameOfAccountHint => '请输入您的账户名称';

  @override
  String editAccountTitle(String name) {
    return '编辑 $name';
  }

  @override
  String editAccountFailureToConnectInfo(String name) {
    return 'Maily 无法连接 $name。';
  }

  @override
  String get editAccountFailureToConnectRetryAction => '重试';

  @override
  String get editAccountFailureToConnectChangePasswordAction => '更改密码';

  @override
  String get editAccountFailureToConnectFixedTitle => '已连接';

  @override
  String get editAccountFailureToConnectFixedInfo => '账户已重新连接。';

  @override
  String get editAccountIncludeInUnifiedLabel => '包含在统一账户中';

  @override
  String editAccountAliasLabel(String email) {
    return '$email 的别名电子邮件地址：';
  }

  @override
  String get editAccountNoAliasesInfo => '您此账户尚无已知别名。';

  @override
  String editAccountAliasRemoved(String email) {
    return '$email 别名已移除';
  }

  @override
  String get editAccountAddAliasAction => '添加别名';

  @override
  String get editAccountPlusAliasesSupported => '支持 + 别名';

  @override
  String get editAccountCheckPlusAliasAction => '测试 + 别名支持';

  @override
  String get editAccountBccMyself => '密送给自己';

  @override
  String get editAccountBccMyselfDescriptionTitle => '密送给自己';

  @override
  String get editAccountBccMyselfDescriptionText =>
      '您可以使用“密送给自己”功能，自动将从此账户发送的每封邮件同时发送给自己。通常不需要这样做，因为所有已发送邮件都会保存在“已发送”文件夹中。';

  @override
  String get editAccountServerSettingsAction => '编辑服务器设置';

  @override
  String get editAccountDeleteAccountAction => '删除账户';

  @override
  String get editAccountDeleteAccountConfirmationTitle => '确认';

  @override
  String editAccountDeleteAccountConfirmationQuery(String name) {
    return '您确定要删除账户 $name 吗？';
  }

  @override
  String editAccountTestPlusAliasTitle(String name) {
    return '$name 的 + 别名';
  }

  @override
  String get editAccountTestPlusAliasStepIntroductionTitle => '介绍';

  @override
  String editAccountTestPlusAliasStepIntroductionText(
    String accountName,
    String example,
  ) {
    return '您的账户 $accountName 可能支持 $example 这样的 + 别名。\n+ 别名可以帮助您保护身份并防止垃圾邮件。\n为了测试这一点，将向此生成的地址发送一封测试邮件。如果到达，则您的提供商支持 + 别名，您可以在撰写新邮件时轻松生成它们。';
  }

  @override
  String get editAccountTestPlusAliasStepTestingTitle => 'Testing';

  @override
  String get editAccountTestPlusAliasStepResultTitle => 'Result';

  @override
  String editAccountTestPlusAliasStepResultSuccess(String name) {
    return 'Your account $name supports + aliases.';
  }

  @override
  String editAccountTestPlusAliasStepResultNoSuccess(String name) {
    return 'Your account $name does not support + aliases.';
  }

  @override
  String get editAccountAddAliasTitle => '添加别名';

  @override
  String get editAccountEditAliasTitle => 'Edit alias';

  @override
  String get editAccountAliasAddAction => 'Add';

  @override
  String get editAccountAliasUpdateAction => 'Update';

  @override
  String get editAccountEditAliasNameLabel => 'Alias name';

  @override
  String get editAccountEditAliasEmailLabel => 'Alias email';

  @override
  String get editAccountEditAliasEmailHint => 'Your alias email address';

  @override
  String editAccountEditAliasDuplicateError(String email) {
    return 'There is already an alias with $email.';
  }

  @override
  String get editAccountEnableLogging => 'Enable logging';

  @override
  String get editAccountLoggingEnabled => 'Log enabled, please restart';

  @override
  String get editAccountLoggingDisabled => 'Log disabled, please restart';

  @override
  String get accountDetailsFallbackTitle => 'Server Settings';

  @override
  String get errorTitle => 'Error';

  @override
  String get accountProviderStepTitle => 'Email Service Provider';

  @override
  String get accountProviderCustom => 'Other email service';

  @override
  String accountDetailsErrorHostProblem(
    String incomingHost,
    String outgoingHost,
  ) {
    return 'Maily cannot reach the specified mail server. Please check your incoming server setting \"$incomingHost\" and your outgoing server setting \"$outgoingHost\".';
  }

  @override
  String accountDetailsErrorLoginProblem(String userName, String password) {
    return 'Unable to log your in. Please check your user name \"$userName\" and your password \"$password\".';
  }

  @override
  String get accountDetailsUserNameLabel => 'Login name';

  @override
  String get accountDetailsUserNameHint =>
      'Your user name, if different from email';

  @override
  String get accountDetailsPasswordLabel => 'Login password';

  @override
  String get accountDetailsPasswordHint => 'Your password';

  @override
  String get accountDetailsBaseSectionTitle => 'Base settings';

  @override
  String get accountDetailsIncomingLabel => 'Incoming server';

  @override
  String get accountDetailsIncomingHint => 'Domain like imap.domain.com';

  @override
  String get accountDetailsOutgoingLabel => 'Outgoing server';

  @override
  String get accountDetailsOutgoingHint => 'Domain like smtp.domain.com';

  @override
  String get accountDetailsAdvancedIncomingSectionTitle =>
      'Advanced incoming settings';

  @override
  String get accountDetailsIncomingServerTypeLabel => 'Incoming type:';

  @override
  String get accountDetailsOptionAutomatic => 'automatic';

  @override
  String get accountDetailsIncomingSecurityLabel => 'Incoming security:';

  @override
  String get accountDetailsSecurityOptionNone => 'Plain (no encryption)';

  @override
  String get accountDetailsIncomingPortLabel => 'Incoming port';

  @override
  String get accountDetailsPortHint => 'Leave empty to determine automatically';

  @override
  String get accountDetailsIncomingUserNameLabel => 'Incoming user name';

  @override
  String get accountDetailsAlternativeUserNameHint =>
      'Your user name, if different from above';

  @override
  String get accountDetailsIncomingPasswordLabel => 'Incoming password';

  @override
  String get accountDetailsAlternativePasswordHint =>
      'Your password, if different from above';

  @override
  String get accountDetailsAdvancedOutgoingSectionTitle =>
      'Advanced outgoing settings';

  @override
  String get accountDetailsOutgoingServerTypeLabel => 'Outgoing type:';

  @override
  String get accountDetailsOutgoingSecurityLabel => 'Outgoing security:';

  @override
  String get accountDetailsOutgoingPortLabel => 'Outgoing port';

  @override
  String get accountDetailsOutgoingUserNameLabel => 'Outgoing user name';

  @override
  String get accountDetailsOutgoingPasswordLabel => 'Outgoing password';

  @override
  String get composeTitleNew => '新建邮件';

  @override
  String get composeTitleForward => '转发';

  @override
  String get composeTitleReply => '回复';

  @override
  String get composeEmptyMessage => 'empty message';

  @override
  String get composeWarningNoSubject =>
      'You have not specified a subject. Do you want to sent the message without a subject?';

  @override
  String get composeActionSentWithoutSubject => 'Send';

  @override
  String get composeMailSendSuccess => 'Mail sent 😊';

  @override
  String composeSendErrorInfo(String details) {
    return 'Sorry, your mail could not be send. We received the following error:\n$details.';
  }

  @override
  String get composeRequestReadReceiptAction => 'Request read receipt';

  @override
  String get composeSaveDraftAction => 'Save as draft';

  @override
  String get composeMessageSavedAsDraft => 'Draft saved';

  @override
  String composeMessageSavedAsDraftErrorInfo(String details) {
    return 'Your draft could not be saved with the following error:\n$details';
  }

  @override
  String get composeConvertToPlainTextEditorAction => 'Convert to plain text';

  @override
  String get composeConvertToHtmlEditorAction =>
      'Convert to rich message (HTML)';

  @override
  String get composeContinueEditingAction => 'Continue editing';

  @override
  String get composeCreatePlusAliasAction => 'Create new + alias...';

  @override
  String get composeSenderHint => 'Sender';

  @override
  String get composeRecipientHint => 'Recipient email';

  @override
  String get composeSubjectLabel => 'Subject';

  @override
  String get composeSubjectHint => 'Message subject';

  @override
  String get composeAddAttachmentAction => 'Add';

  @override
  String composeRemoveAttachmentAction(String name) {
    return 'Remove $name';
  }

  @override
  String get composeLeftByMistake => 'Left by mistake?';

  @override
  String get attachTypeFile => 'File';

  @override
  String get attachTypePhoto => 'Photo';

  @override
  String get attachTypeVideo => 'Video';

  @override
  String get attachTypeAudio => 'Audio';

  @override
  String get attachTypeLocation => 'Location';

  @override
  String get attachTypeGif => 'Animated Gif';

  @override
  String get attachTypeGifSearch => 'search GIPHY';

  @override
  String get attachTypeSticker => 'Sticker';

  @override
  String get attachTypeStickerSearch => 'search GIPHY';

  @override
  String get attachTypeAppointment => 'Appointment';

  @override
  String get languageSettingTitle => 'Language';

  @override
  String get languageSettingLabel => 'Choose the language for Maily:';

  @override
  String get languageSettingSystemOption => 'System language';

  @override
  String get languageSettingConfirmationTitle => 'Use English for Maily?';

  @override
  String get languageSettingConfirmationQuery =>
      'Please confirm to use English as your chosen language.';

  @override
  String get languageSetInfo => 'Maily is now shown in English.';

  @override
  String get languageSystemSetInfo =>
      'Maily will now use the system\'s language or English if the system\'s language is not supported.';

  @override
  String get swipeSettingTitle => 'Swipe gestures';

  @override
  String get swipeSettingLeftToRightLabel => 'Left to right swipe';

  @override
  String get swipeSettingRightToLeftLabel => 'Right to left swipe';

  @override
  String get swipeSettingChangeAction => 'Change';

  @override
  String get signatureSettingsTitle => 'Signature';

  @override
  String get signatureSettingsComposeActionsInfo =>
      'Enable the signature for the following messages:';

  @override
  String get signatureSettingsAccountInfo =>
      'You can specify account specific signatures in the account settings.';

  @override
  String signatureSettingsAddForAccount(String account) {
    return 'Add signature for $account';
  }

  @override
  String get defaultSenderSettingsTitle => 'Default sender';

  @override
  String get defaultSenderSettingsLabel =>
      'Select the sender for new messages.';

  @override
  String defaultSenderSettingsFirstAccount(String email) {
    return 'First account ($email)';
  }

  @override
  String get defaultSenderSettingsAliasInfo =>
      'You can set up email alias addresses in the [AS].';

  @override
  String get defaultSenderSettingsAliasAccountSettings => 'account settings';

  @override
  String get replySettingsTitle => 'Message format';

  @override
  String get replySettingsIntro =>
      'In what format do you want to answer or forward email by default?';

  @override
  String get replySettingsFormatHtml => 'Always rich format (HTML)';

  @override
  String get replySettingsFormatSameAsOriginal =>
      'Use same format as originating email';

  @override
  String get replySettingsFormatPlainText => 'Always text-only';

  @override
  String get moveTitle => 'Move message';

  @override
  String moveSuccess(String mailbox) {
    return 'Messaged moved to $mailbox.';
  }

  @override
  String get editorArtInputLabel => 'Your input';

  @override
  String get editorArtInputHint => 'Enter text here';

  @override
  String get editorArtWaitingForInputHint => 'waiting for input...';

  @override
  String get fontSerifBold => 'Serif bold';

  @override
  String get fontSerifItalic => 'Serif italic';

  @override
  String get fontSerifBoldItalic => 'Serif bold italic';

  @override
  String get fontSans => 'Sans';

  @override
  String get fontSansBold => 'Sans bold';

  @override
  String get fontSansItalic => 'Sans italic';

  @override
  String get fontSansBoldItalic => 'Sans bold italic';

  @override
  String get fontScript => 'Script';

  @override
  String get fontScriptBold => 'Script bold';

  @override
  String get fontFraktur => 'Fraktur';

  @override
  String get fontFrakturBold => 'Fraktur bold';

  @override
  String get fontMonospace => 'Monospace';

  @override
  String get fontFullwidth => 'Fullwidth';

  @override
  String get fontDoublestruck => 'Double struck';

  @override
  String get fontCapitalized => 'Capitalized';

  @override
  String get fontCircled => 'Circled';

  @override
  String get fontParenthesized => 'Parenthesized';

  @override
  String get fontUnderlinedSingle => 'Underlined';

  @override
  String get fontUnderlinedDouble => 'Underlined double';

  @override
  String get fontStrikethroughSingle => 'Strike through';

  @override
  String get fontCrosshatch => 'Crosshatch';

  @override
  String accountLoadError(String name) {
    return 'Unable to connect to your account $name. Has the password been changed?';
  }

  @override
  String get accountLoadErrorEditAction => 'Edit account';

  @override
  String get extensionsTitle => 'Extensions';

  @override
  String get extensionsIntro =>
      'With extensions e-mail service providers, companies and developers can adapt Maily with useful functionalities.';

  @override
  String get extensionsLearnMoreAction => 'Learn more about extensions';

  @override
  String get extensionsReloadAction => 'Reload extensions';

  @override
  String get extensionDeactivateAllAction => 'Deactivate all extensions';

  @override
  String get extensionsManualAction => 'Load manually';

  @override
  String get extensionsManualUrlLabel => 'Url of extension';

  @override
  String extensionsManualLoadingError(String url) {
    return 'Unable to download extension from \"$url\".';
  }

  @override
  String get icalendarAcceptTentatively => 'Tentatively';

  @override
  String get icalendarActionChangeParticipantStatus => 'Change';

  @override
  String get icalendarLabelSummary => 'Title';

  @override
  String get icalendarNoSummaryInfo => '(no title)';

  @override
  String get icalendarLabelDescription => 'Description';

  @override
  String get icalendarLabelStart => 'Start';

  @override
  String get icalendarLabelEnd => 'End';

  @override
  String get icalendarLabelDuration => 'Duration';

  @override
  String get icalendarLabelLocation => 'Location';

  @override
  String get icalendarLabelTeamsUrl => 'Link';

  @override
  String get icalendarLabelRecurrenceRule => 'Repeats';

  @override
  String get icalendarLabelParticipants => 'Participants';

  @override
  String get icalendarParticipantStatusNeedsAction =>
      'You are asked to answer this invitation.';

  @override
  String get icalendarParticipantStatusAccepted =>
      'You have accepted this invitation.';

  @override
  String get icalendarParticipantStatusDeclined =>
      'You have declined this invitation.';

  @override
  String get icalendarParticipantStatusAcceptedTentatively =>
      'You have tentatively accepted this invitation.';

  @override
  String get icalendarParticipantStatusDelegated =>
      'You have delegated this invitation.';

  @override
  String get icalendarParticipantStatusInProcess => 'The task is in progress.';

  @override
  String get icalendarParticipantStatusPartial => 'The task is partially done.';

  @override
  String get icalendarParticipantStatusCompleted => 'The task is done.';

  @override
  String get icalendarParticipantStatusOther => 'Your status is unknown.';

  @override
  String get icalendarParticipantStatusChangeTitle => 'Your Status';

  @override
  String get icalendarParticipantStatusChangeText =>
      'Do you want to accept this invitation?';

  @override
  String icalendarParticipantStatusSentFailure(String details) {
    return 'Unable to send reply.\nThe server responded with the following details:\n$details';
  }

  @override
  String get icalendarExportAction => 'Export';

  @override
  String icalendarReplyStatusNeedsAction(String attendee) {
    return '$attendee has not answered this invitation.';
  }

  @override
  String icalendarReplyStatusAccepted(String attendee) {
    return '$attendee has accepted the appointment.';
  }

  @override
  String icalendarReplyStatusDeclined(String attendee) {
    return '$attendee has declined this invitation.';
  }

  @override
  String icalendarReplyStatusAcceptedTentatively(String attendee) {
    return '$attendee has tentatively accepted this invitation.';
  }

  @override
  String icalendarReplyStatusDelegated(String attendee) {
    return '$attendee has delegated this invitation.';
  }

  @override
  String icalendarReplyStatusInProcess(String attendee) {
    return '$attendee has started this task.';
  }

  @override
  String icalendarReplyStatusPartial(String attendee) {
    return '$attendee has partially done this task.';
  }

  @override
  String icalendarReplyStatusCompleted(String attendee) {
    return '$attendee has finished this task.';
  }

  @override
  String icalendarReplyStatusOther(String attendee) {
    return '$attendee has answered with an unknown status.';
  }

  @override
  String get icalendarReplyWithoutParticipants =>
      'This calendar reply contains no participants.';

  @override
  String icalendarReplyWithoutStatus(String attendee) {
    return '$attendee replied without an participation status.';
  }

  @override
  String get composeAppointmentTitle => 'Create Appointment';

  @override
  String get composeAppointmentLabelDay => 'day';

  @override
  String get composeAppointmentLabelTime => 'time';

  @override
  String get composeAppointmentLabelAllDayEvent => 'All day';

  @override
  String get composeAppointmentLabelRepeat => 'Repeat';

  @override
  String get composeAppointmentLabelRepeatOptionNever => '从不';

  @override
  String get composeAppointmentLabelRepeatOptionDaily => 'Daily';

  @override
  String get composeAppointmentLabelRepeatOptionWeekly => 'Weekly';

  @override
  String get composeAppointmentLabelRepeatOptionMonthly => 'Monthly';

  @override
  String get composeAppointmentLabelRepeatOptionYearly => 'Annually';

  @override
  String get composeAppointmentRecurrenceFrequencyLabel => 'Frequency';

  @override
  String get composeAppointmentRecurrenceIntervalLabel => 'Interval';

  @override
  String get composeAppointmentRecurrenceDaysLabel => 'On days';

  @override
  String get composeAppointmentRecurrenceUntilLabel => 'Until';

  @override
  String get composeAppointmentRecurrenceUntilOptionUnlimited => 'Unlimited';

  @override
  String composeAppointmentRecurrenceUntilOptionRecommended(String duration) {
    return 'Recommended ($duration)';
  }

  @override
  String get composeAppointmentRecurrenceUntilOptionSpecificDate =>
      'Until chosen date';

  @override
  String composeAppointmentRecurrenceMonthlyOnDayOfMonth(int day) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String dayString = dayNumberFormat.format(day);

    return 'On the $dayString. day of the month';
  }

  @override
  String get composeAppointmentRecurrenceMonthlyOnWeekDay => 'Weekday in month';

  @override
  String get composeAppointmentRecurrenceFirst => 'First';

  @override
  String get composeAppointmentRecurrenceSecond => 'Second';

  @override
  String get composeAppointmentRecurrenceThird => 'Third';

  @override
  String get composeAppointmentRecurrenceLast => 'Last';

  @override
  String get composeAppointmentRecurrenceSecondLast => 'Second-last';

  @override
  String durationYears(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String durationMonths(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String durationWeeks(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get durationEmpty => 'No duration';
}
