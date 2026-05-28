// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get signature => '使用 Maily 发送';

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
  String get splashLoading1 => 'Maily 正在启动...';

  @override
  String get splashLoading2 => '正在准备您的 Maily 引擎...';

  @override
  String get splashLoading3 => 'Maily 即将启动，倒数 10、9、8...';

  @override
  String get welcomePanel1Title => 'Maily';

  @override
  String get welcomePanel1Text => '欢迎使用 Maily，您友好快捷的邮件助手！';

  @override
  String get welcomePanel2Title => '账户';

  @override
  String get welcomePanel2Text => '管理无限数量的电子邮件账户。一次性阅读和搜索所有账户中的邮件。';

  @override
  String get welcomePanel3Title => '滑动与长按';

  @override
  String get welcomePanel3Text => '滑动邮件以删除或标记为已读。长按邮件以选择并管理多个邮件。';

  @override
  String get welcomePanel4Title => '保持收件箱整洁';

  @override
  String get welcomePanel4Text => '只需一键即可取消订阅新闻通讯。';

  @override
  String get welcomeActionSignIn => '登录您的邮件账户';

  @override
  String get homeSearchHint => '搜索';

  @override
  String get homeActionsShowAsStack => '以堆叠方式显示';

  @override
  String get homeActionsShowAsList => '以列表方式显示';

  @override
  String get homeEmptyFolderMessage => '已全部完成！\n\n此文件夹中没有邮件。';

  @override
  String get homeEmptySearchMessage => '未找到邮件。';

  @override
  String get homeDeleteAllTitle => '确认';

  @override
  String get homeDeleteAllQuestion => '确定要删除所有邮件吗？';

  @override
  String get homeDeleteAllAction => '全部删除';

  @override
  String get homeDeleteAllScrubOption => '清除邮件';

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
  String get swipeActionArchive => '存档';

  @override
  String get swipeActionFlag => '标记/取消标记';

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
      other: '$numberString 封邮件已存档',
      one: '一封邮件已存档',
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
    return '无法执行操作\n详情：$details';
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
  String get messageActionMultipleMarkSeen => '标记为已读';

  @override
  String get messageActionMultipleMarkUnseen => '标记为未读';

  @override
  String get messageActionMultipleMarkFlagged => '标记邮件';

  @override
  String get messageActionMultipleMarkUnflagged => '取消标记邮件';

  @override
  String get messageActionViewInSafeMode => '查看不含外部内容';

  @override
  String get emailSenderUnknown => '<无发件人>';

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
  String get dateRangeLongAgo => '很久以前';

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
  String get unifiedFolderArchive => '统一存档';

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
  String get folderArchive => '存档';

  @override
  String get folderJunk => '垃圾邮件';

  @override
  String get folderUnknown => '未知';

  @override
  String get viewContentsAction => '查看内容';

  @override
  String get viewSourceAction => '查看源代码';

  @override
  String get detailsErrorDownloadInfo => '邮件无法下载。';

  @override
  String get detailsErrorDownloadRetry => '重试';

  @override
  String get detailsHeaderFrom => '发件人';

  @override
  String get detailsHeaderTo => '收件人';

  @override
  String get detailsHeaderCc => '抄送';

  @override
  String get detailsHeaderBcc => '密送';

  @override
  String get detailsHeaderDate => '日期';

  @override
  String get subjectUndefined => '<无主题>';

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
    return '您确定要取消订阅邮件列表 $listName 吗？';
  }

  @override
  String get detailsNewsletterUnsubscribeDialogAction => '取消订阅';

  @override
  String get detailsNewsletterUnsubscribeSuccessTitle => '已取消订阅';

  @override
  String detailsNewsletterUnsubscribeSuccessMessage(String listName) {
    return '您已成功取消订阅邮件列表 $listName。';
  }

  @override
  String get detailsNewsletterUnsubscribeFailureTitle => '取消订阅失败';

  @override
  String detailsNewsletterUnsubscribeFailureMessage(String listName) {
    return '抱歉，我无法自动为您取消订阅 $listName。';
  }

  @override
  String get detailsNewsletterResubscribeDialogTitle => '重新订阅';

  @override
  String detailsNewsletterResubscribeDialogQuestion(String listName) {
    return '您确定要重新订阅邮件列表 $listName 吗？';
  }

  @override
  String get detailsNewsletterResubscribeDialogAction => '订阅';

  @override
  String get detailsNewsletterResubscribeSuccessTitle => '已订阅';

  @override
  String detailsNewsletterResubscribeSuccessMessage(String listName) {
    return '您已成功重新订阅邮件列表 $listName。';
  }

  @override
  String get detailsNewsletterResubscribeFailureTitle => '订阅失败';

  @override
  String detailsNewsletterResubscribeFailureMessage(String listName) {
    return '抱歉，邮件列表 $listName 的订阅请求失败。';
  }

  @override
  String get detailsSendReadReceiptAction => '发送已读回执';

  @override
  String get detailsReadReceiptSentStatus => '已发送已读回执 ✔';

  @override
  String get detailsReadReceiptSubject => '已读回执';

  @override
  String get attachmentActionOpen => '打开';

  @override
  String attachmentDecodeError(String details) {
    return '此附件格式或编码不受支持。\n详情：\$$details';
  }

  @override
  String attachmentDownloadError(String details) {
    return '无法下载此附件。\n详情：\$$details';
  }

  @override
  String get messageActionReply => '回复';

  @override
  String get messageActionReplyAll => '回复全部';

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
  String get messageStatusFlagged => '已标记';

  @override
  String get messageStatusUnflagged => '未标记';

  @override
  String get messageActionMarkAsJunk => '标记为垃圾邮件';

  @override
  String get messageActionMarkAsNotJunk => '标记为非垃圾邮件';

  @override
  String get messageActionArchive => '存档';

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
  String get resultArchived => '已存档';

  @override
  String get resultRedirectedSuccess => '邮件已重定向 👍';

  @override
  String resultRedirectedFailure(String details) {
    return '无法重定向邮件。\n\n服务器返回以下详情：\"$details\"';
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
  String get legaleseTermsAndConditions => '服务条款';

  @override
  String get aboutApplicationLegalese => 'Maily 是根据 GNU 通用公共许可证发布的免费软件。';

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
  String get feedbackProvideInfoRequest => '报告问题时，请提供以下信息：';

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
      '电子邮件可能包含内联图片或托管在外部服务器上的图片。后者（外部图片）可能会向发件人泄露信息，例如让发件人知道您已打开邮件。此选项允许您阻止此类外部图片，从而降低泄露敏感信息的风险。您仍然可以在阅读邮件时选择按邮件加载此类图片。';

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
  String get settingsActionWelcome => '显示欢迎界面';

  @override
  String get settingsReadReceipts => '已读回执';

  @override
  String get readReceiptsSettingsIntroduction => '您是否希望显示已读回执请求？';

  @override
  String get readReceiptOptionAlways => '始终显示';

  @override
  String get readReceiptOptionNever => '从不显示';

  @override
  String get settingsFolders => '文件夹';

  @override
  String get folderNamesIntroduction => '您喜欢使用什么名称来命名文件夹？';

  @override
  String get folderNamesSettingLocalized => 'Maily 提供的名称';

  @override
  String get folderNamesSettingServer => '服务提供的名称';

  @override
  String get folderNamesSettingCustom => '自定义名称';

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
  String get folderAddNameHint => '新文件夹名称';

  @override
  String get folderAccountLabel => '账户';

  @override
  String get folderMailboxLabel => '文件夹';

  @override
  String get folderAddResultSuccess => '文件夹已创建 😊';

  @override
  String folderAddResultFailure(String details) {
    return '无法创建文件夹。\n\n服务器返回：$details';
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
    return '无法删除文件夹。\n\n服务器返回：$details';
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
  String get developerShowAsEmail => '转换为邮件格式';

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
  String get designThemeOptionSystem => '系统';

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
  String get securitySettingsTitle => '安全';

  @override
  String get securitySettingsIntro => '根据您的个人需求调整安全设置。';

  @override
  String get securityUnlockWithFaceId => '使用面容 ID 解锁 Maily。';

  @override
  String get securityUnlockWithTouchId => '使用触控 ID 解锁 Maily。';

  @override
  String get securityUnlockReason => '解锁 Maily。';

  @override
  String get securityUnlockDisableReason => '解锁 Maily 以关闭锁定。';

  @override
  String get securityUnlockNotAvailable => '您的设备不支持生物识别功能，可能需要先设置解锁选项。';

  @override
  String get securityUnlockLabel => '锁定 Maily';

  @override
  String get securityUnlockDescriptionTitle => '锁定 Maily';

  @override
  String get securityUnlockDescriptionText =>
      '您可以选择锁定对 Maily 的访问，这样即使他人访问您的设备也无法阅读您的邮件。';

  @override
  String get securityLockImmediately => '立即锁定';

  @override
  String get securityLockAfter5Minutes => '5分钟后锁定';

  @override
  String get securityLockAfter30Minutes => '30分钟后锁定';

  @override
  String get lockScreenTitle => 'Maily 已锁定';

  @override
  String get lockScreenIntro => 'Maily 已锁定，请验证身份以继续。';

  @override
  String get lockScreenUnlockAction => '解锁';

  @override
  String get addAccountTitle => '添加账户';

  @override
  String get addAccountEmailLabel => '邮箱';

  @override
  String get addAccountEmailHint => '请输入您的邮箱地址';

  @override
  String addAccountResolvingSettingsLabel(String email) {
    return '正在解析 $email 的设置...';
  }

  @override
  String addAccountResolvedSettingsWrongAction(String provider) {
    return '不在 $provider 上？';
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
    return '已成功登录 $email。';
  }

  @override
  String addAccountVerifyingFailedInfo(String email) {
    return '抱歉，出现问题。请检查您的邮箱 $email 和密码。';
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
  String get addAccountSetupImapAccessButtonLabel => '设置邮箱访问权限';

  @override
  String get addAccountNameOfUserLabel => '您的姓名';

  @override
  String get addAccountNameOfUserHint => '收件人将看到的姓名';

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
    return 'Maily 无法连接到 $name。';
  }

  @override
  String get editAccountFailureToConnectRetryAction => '重试';

  @override
  String get editAccountFailureToConnectChangePasswordAction => '修改密码';

  @override
  String get editAccountFailureToConnectFixedTitle => '已连接';

  @override
  String get editAccountFailureToConnectFixedInfo => '账户已重新连接。';

  @override
  String get editAccountIncludeInUnifiedLabel => '包含在统一账户中';

  @override
  String editAccountAliasLabel(String email) {
    return '$email 的别名邮箱地址：';
  }

  @override
  String get editAccountNoAliasesInfo => '此账户暂无已知别名。';

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
  String get editAccountBccMyself => '密送自己';

  @override
  String get editAccountBccMyselfDescriptionTitle => '密送自己';

  @override
  String get editAccountBccMyselfDescriptionText =>
      '您可以使用\"密送自己\"功能，自动在您从此账户发送的每封邮件中密送一份给自己。通常这不太必要，因为所有外发邮件都会存储在\"已发送\"文件夹中。';

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
    return '您的账户 $accountName 可能支持所谓的 + 别名，如 $example。\n+ 别名可帮助您保护身份并抵御垃圾邮件。\n要测试此项，将向生成的地址发送一封测试邮件。如果邮件到达，说明您的提供商支持 + 别名，您可以在撰写新邮件时按需生成它们。';
  }

  @override
  String get editAccountTestPlusAliasStepTestingTitle => '测试中';

  @override
  String get editAccountTestPlusAliasStepResultTitle => '结果';

  @override
  String editAccountTestPlusAliasStepResultSuccess(String name) {
    return '您的账户 $name 支持 + 别名。';
  }

  @override
  String editAccountTestPlusAliasStepResultNoSuccess(String name) {
    return '您的账户 $name 不支持 + 别名。';
  }

  @override
  String get editAccountAddAliasTitle => '添加别名';

  @override
  String get editAccountEditAliasTitle => '编辑别名';

  @override
  String get editAccountAliasAddAction => '添加';

  @override
  String get editAccountAliasUpdateAction => '更新';

  @override
  String get editAccountEditAliasNameLabel => '别名名称';

  @override
  String get editAccountEditAliasEmailLabel => '别名邮箱';

  @override
  String get editAccountEditAliasEmailHint => '您的别名邮箱地址';

  @override
  String editAccountEditAliasDuplicateError(String email) {
    return '$email 已存在别名。';
  }

  @override
  String get editAccountEnableLogging => '启用日志';

  @override
  String get editAccountLoggingEnabled => '日志已启用，请重启';

  @override
  String get editAccountLoggingDisabled => '日志已禁用，请重启';

  @override
  String get accountDetailsFallbackTitle => '服务器设置';

  @override
  String get errorTitle => '错误';

  @override
  String get accountProviderStepTitle => '电子邮件服务提供商';

  @override
  String get accountProviderCustom => '其他电子邮件服务';

  @override
  String accountDetailsErrorHostProblem(
    String incomingHost,
    String outgoingHost,
  ) {
    return 'Maily 无法连接到指定的邮件服务器。请检查您的传入服务器设置 \"$incomingHost\" 和传出服务器设置 \"$outgoingHost\"。';
  }

  @override
  String accountDetailsErrorLoginProblem(String userName, String password) {
    return '无法登录。请检查您的用户名 \"$userName\" 和密码 \"$password\"。';
  }

  @override
  String get accountDetailsUserNameLabel => '登录名';

  @override
  String get accountDetailsUserNameHint => '您的用户名（如与邮箱不同）';

  @override
  String get accountDetailsPasswordLabel => '登录密码';

  @override
  String get accountDetailsPasswordHint => '您的密码';

  @override
  String get accountDetailsBaseSectionTitle => '基础设置';

  @override
  String get accountDetailsIncomingLabel => '传入服务器';

  @override
  String get accountDetailsIncomingHint => '域名，如 imap.domain.com';

  @override
  String get accountDetailsOutgoingLabel => '传出服务器';

  @override
  String get accountDetailsOutgoingHint => '域名，如 smtp.domain.com';

  @override
  String get accountDetailsAdvancedIncomingSectionTitle => '高级传入设置';

  @override
  String get accountDetailsIncomingServerTypeLabel => '传入类型：';

  @override
  String get accountDetailsOptionAutomatic => '自动';

  @override
  String get accountDetailsIncomingSecurityLabel => '传入安全：';

  @override
  String get accountDetailsSecurityOptionNone => '明文（无加密）';

  @override
  String get accountDetailsIncomingPortLabel => '传入端口';

  @override
  String get accountDetailsPortHint => '留空以自动确定';

  @override
  String get accountDetailsIncomingUserNameLabel => '传入用户名';

  @override
  String get accountDetailsAlternativeUserNameHint => '您的用户名（如与上方不同）';

  @override
  String get accountDetailsIncomingPasswordLabel => '传入密码';

  @override
  String get accountDetailsAlternativePasswordHint => '您的密码（如与上方不同）';

  @override
  String get accountDetailsAdvancedOutgoingSectionTitle => '高级传出设置';

  @override
  String get accountDetailsOutgoingServerTypeLabel => '传出类型：';

  @override
  String get accountDetailsOutgoingSecurityLabel => '传出安全：';

  @override
  String get accountDetailsOutgoingPortLabel => '传出端口';

  @override
  String get accountDetailsOutgoingUserNameLabel => '传出用户名';

  @override
  String get accountDetailsOutgoingPasswordLabel => '传出密码';

  @override
  String get composeTitleNew => '新建邮件';

  @override
  String get composeTitleForward => '转发';

  @override
  String get composeTitleReply => '回复';

  @override
  String get composeEmptyMessage => '空邮件';

  @override
  String get composeWarningNoSubject => '您尚未指定主题。确定要发送无主题的邮件吗？';

  @override
  String get composeActionSentWithoutSubject => '发送';

  @override
  String get composeMailSendSuccess => '邮件已发送 😊';

  @override
  String composeSendErrorInfo(String details) {
    return '抱歉，您的邮件无法发送。收到以下错误：\n$details。';
  }

  @override
  String get composeRequestReadReceiptAction => '请求已读回执';

  @override
  String get composeSaveDraftAction => '保存为草稿';

  @override
  String get composeMessageSavedAsDraft => '草稿已保存';

  @override
  String composeMessageSavedAsDraftErrorInfo(String details) {
    return '您的草稿无法保存，错误如下：\n$details';
  }

  @override
  String get composeConvertToPlainTextEditorAction => '转换为纯文本';

  @override
  String get composeConvertToHtmlEditorAction => '转换为富文本（HTML）';

  @override
  String get composeContinueEditingAction => '继续编辑';

  @override
  String get composeCreatePlusAliasAction => '创建新的 + 别名...';

  @override
  String get composeSenderHint => '发件人';

  @override
  String get composeRecipientHint => '收件人邮箱';

  @override
  String get composeSubjectLabel => '主题';

  @override
  String get composeSubjectHint => '邮件主题';

  @override
  String get composeAddAttachmentAction => '添加';

  @override
  String composeRemoveAttachmentAction(String name) {
    return '移除 $name';
  }

  @override
  String get composeLeftByMistake => '误离开？';

  @override
  String get attachTypeFile => '文件';

  @override
  String get attachTypePhoto => '照片';

  @override
  String get attachTypeVideo => '视频';

  @override
  String get attachTypeAudio => '音频';

  @override
  String get attachTypeLocation => '位置';

  @override
  String get attachTypeGif => '动图';

  @override
  String get attachTypeGifSearch => '搜索 GIPHY';

  @override
  String get attachTypeSticker => '贴纸';

  @override
  String get attachTypeStickerSearch => '搜索 GIPHY';

  @override
  String get attachTypeAppointment => '日程';

  @override
  String get languageSettingTitle => '语言';

  @override
  String get languageSettingLabel => '选择 Maily 的语言：';

  @override
  String get languageSettingSystemOption => '系统语言';

  @override
  String get languageSettingConfirmationTitle => '使用中文作为 Maily 语言？';

  @override
  String get languageSettingConfirmationQuery => '请确认使用中文作为您选择的语言。';

  @override
  String get languageSetInfo => 'Maily 现在显示为中文。';

  @override
  String get languageSystemSetInfo => 'Maily 将使用系统语言，如果系统语言不支持则使用英语。';

  @override
  String get swipeSettingTitle => '滑动手势';

  @override
  String get swipeSettingLeftToRightLabel => '从左向右滑动';

  @override
  String get swipeSettingRightToLeftLabel => '从右向左滑动';

  @override
  String get swipeSettingChangeAction => '更改';

  @override
  String get signatureSettingsTitle => '签名';

  @override
  String get signatureSettingsComposeActionsInfo => '为以下邮件类型启用签名：';

  @override
  String get signatureSettingsAccountInfo => '您可以在账户设置中指定特定账户的签名。';

  @override
  String signatureSettingsAddForAccount(String account) {
    return '为 $account 添加签名';
  }

  @override
  String get defaultSenderSettingsTitle => '默认发件人';

  @override
  String get defaultSenderSettingsLabel => '选择新邮件的发件人。';

  @override
  String defaultSenderSettingsFirstAccount(String email) {
    return '第一个账户 ($email)';
  }

  @override
  String get defaultSenderSettingsAliasInfo => '您可以在 [AS] 中设置邮箱别名地址。';

  @override
  String get defaultSenderSettingsAliasAccountSettings => '账户设置';

  @override
  String get replySettingsTitle => '邮件格式';

  @override
  String get replySettingsIntro => '默认情况下，您希望以什么格式回复或转发邮件？';

  @override
  String get replySettingsFormatHtml => '始终使用富格式（HTML）';

  @override
  String get replySettingsFormatSameAsOriginal => '使用与原始邮件相同的格式';

  @override
  String get replySettingsFormatPlainText => '始终使用纯文本';

  @override
  String get moveTitle => '移动邮件';

  @override
  String moveSuccess(String mailbox) {
    return '邮件已移至 $mailbox。';
  }

  @override
  String get editorArtInputLabel => '您的输入';

  @override
  String get editorArtInputHint => '在此输入文本';

  @override
  String get editorArtWaitingForInputHint => '等待输入...';

  @override
  String get fontSerifBold => '衬线粗体';

  @override
  String get fontSerifItalic => '衬线斜体';

  @override
  String get fontSerifBoldItalic => '衬线粗斜体';

  @override
  String get fontSans => '无衬线';

  @override
  String get fontSansBold => '无衬线粗体';

  @override
  String get fontSansItalic => '无衬线斜体';

  @override
  String get fontSansBoldItalic => '无衬线粗斜体';

  @override
  String get fontScript => '手写体';

  @override
  String get fontScriptBold => '手写体粗体';

  @override
  String get fontFraktur => '德文花体';

  @override
  String get fontFrakturBold => '德文花体粗体';

  @override
  String get fontMonospace => '等宽';

  @override
  String get fontFullwidth => '全角';

  @override
  String get fontDoublestruck => '双线体';

  @override
  String get fontCapitalized => '大写';

  @override
  String get fontCircled => '圆圈';

  @override
  String get fontParenthesized => '括号';

  @override
  String get fontUnderlinedSingle => '下划线';

  @override
  String get fontUnderlinedDouble => '双下划线';

  @override
  String get fontStrikethroughSingle => '删除线';

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
  String get composeAppointmentLabelRepeatOptionNever => 'Never';

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
