import 'package:intl/intl.dart' as intl;

import 'app_localizations.g.dart';

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get signature => 'Enviado con Maily';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionOk => 'Ok';

  @override
  String get actionDone => 'Hecho';

  @override
  String get actionNext => 'Siguiente';

  @override
  String get actionSkip => 'Saltar';

  @override
  String get actionUndo => 'Deshacer';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionAccept => 'Aceptar';

  @override
  String get actionDecline => 'Rechazar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionAddressCopy => 'Copiar';

  @override
  String get actionAddressCompose => 'Nuevo mensaje';

  @override
  String get actionAddressSearch => 'Buscar';

  @override
  String get splashLoading1 => 'Iniciando...';

  @override
  String get splashLoading2 => 'Preparando tu Motor de Maily...';

  @override
  String get splashLoading3 => 'Lanzando en el 10, 9, 8...';

  @override
  String get welcomePanel1Title => 'Maily';

  @override
  String get welcomePanel1Text => 'Bienvenido a Maily, tu ayudante de correo electrónico rápido y amistoso!';

  @override
  String get welcomePanel2Title => 'Cuentas';

  @override
  String get welcomePanel2Text => 'Administra cuentas de correo electrónico ilimitadas. Lee y busca correos en todas tus cuentas a la vez.';

  @override
  String get welcomePanel3Title => 'Deslizar y pulsar largo';

  @override
  String get welcomePanel3Text => 'Desliza el dedo por tus mensajes para borrarlos o marcarlos como leídos. Mantén pulsado un mensaje para seleccionarlo y gestionar varios.';

  @override
  String get welcomePanel4Title => 'Mantén tu bandeja de entrada limpia';

  @override
  String get welcomePanel4Text => 'Darse de baja de los boletines con un solo toque.';

  @override
  String get welcomeActionSignIn => 'Inicia sesión en tu cuenta de correo';

  @override
  String get homeSearchHint => 'Tu búsqueda';

  @override
  String get homeActionsShowAsStack => 'Mostrar como pila';

  @override
  String get homeActionsShowAsList => 'Mostrar como lista';

  @override
  String get homeEmptyFolderMessage => '¡Todo listo!\n\nNo hay mensajes en esta carpeta.';

  @override
  String get homeEmptySearchMessage => 'No se encontraron mensajes.';

  @override
  String get homeDeleteAllTitle => 'Confirmar';

  @override
  String get homeDeleteAllQuestion => '¿Realmente eliminar todos los mensajes?';

  @override
  String get homeDeleteAllAction => 'Borrar todo';

  @override
  String get homeDeleteAllScrubOption => 'Limpiar mensajes';

  @override
  String get homeDeleteAllSuccess => 'Todos los mensajes eliminados.';

  @override
  String get homeMarkAllSeenAction => 'Todos leídos';

  @override
  String get homeMarkAllUnseenAction => 'Todos no leídos';

  @override
  String get homeFabTooltip => 'Nuevo mensaje';

  @override
  String get homeLoadingMessageSourceTitle => 'Cargando...';

  @override
  String homeLoading(String name) {
    return 'cargando $name...';
  }

  @override
  String get swipeActionToggleRead => 'Marcar como leído/no leídos';

  @override
  String get swipeActionDelete => 'Eliminar';

  @override
  String get swipeActionMarkJunk => 'Marcar como basura';

  @override
  String get swipeActionArchive => 'Archivar';

  @override
  String get swipeActionFlag => 'Cambiar bandera';

  @override
  String multipleMovedToJunk(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Marcado $numberString mensajes como basura',
      one: 'Un mensaje marcado como basura',
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
      other: '¡Se ha movido $numberString ¡Los mensajes a la bandeja de entrada',
      one: '¡Se ha movido un mensaje a la bandeja de entrada',
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
      other: '¡Archivado $numberString ¡Mensajes',
      one: '¡Archivado un mensaje',
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
      other: '¡Eliminado $numberString ¡Mensajes',
      one: '¡Eliminado un mensaje',
    );
    return '$_temp0';
  }

  @override
  String get multipleSelectionNeededInfo => 'Por favor, seleccione mensajes primero.';

  @override
  String multipleSelectionActionFailed(String details) {
    return 'Unable to perform action\nDetails: $details';
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
      other: 'Mover $numberString mensajes',
      one: 'Mover mensaje',
    );
    return '$_temp0';
  }

  @override
  String get messageActionMultipleMarkSeen => 'Marcar como leído';

  @override
  String get messageActionMultipleMarkUnseen => 'Marcar como no leído';

  @override
  String get messageActionMultipleMarkFlagged => 'Marcar mensajes';

  @override
  String get messageActionMultipleMarkUnflagged => 'Desmarcar mensajes';

  @override
  String get messageActionViewInSafeMode => 'Ver sin contenido externo';

  @override
  String get emailSenderUnknown => '<sin remitente>';

  @override
  String get dateRangeFuture => 'futuro';

  @override
  String get dateRangeTomorrow => 'mañana';

  @override
  String get dateRangeToday => 'hoy';

  @override
  String get dateRangeYesterday => 'ayer';

  @override
  String get dateRangeCurrentWeek => 'esta semana';

  @override
  String get dateRangeLastWeek => 'semana pasada';

  @override
  String get dateRangeCurrentMonth => 'este mes';

  @override
  String get dateRangeLastMonth => 'mes pasado';

  @override
  String get dateRangeCurrentYear => 'este año';

  @override
  String get dateRangeLongAgo => 'hace mucho tiempo';

  @override
  String get dateUndefined => 'indefinido';

  @override
  String get dateDayToday => 'hoy';

  @override
  String get dateDayYesterday => 'ayer';

  @override
  String dateDayLastWeekday(String day) {
    return 'último $day';
  }

  @override
  String get drawerEntryAbout => 'Sobre Maily';

  @override
  String get drawerEntrySettings => 'Ajustes';

  @override
  String drawerAccountsSectionTitle(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString cuentas',
      one: 'Una cuenta',
    );
    return '$_temp0';
  }

  @override
  String get drawerEntryAddAccount => 'Añadir cuenta';

  @override
  String get unifiedAccountName => 'Cuenta unificada';

  @override
  String get unifiedFolderInbox => 'Entrada unificada';

  @override
  String get unifiedFolderSent => 'Enviado unificado';

  @override
  String get unifiedFolderDrafts => 'Borradores unificados';

  @override
  String get unifiedFolderTrash => 'Basura unificada';

  @override
  String get unifiedFolderArchive => 'Archivo unificado';

  @override
  String get unifiedFolderJunk => 'Chatarra unificada';

  @override
  String get folderInbox => 'Entrada';

  @override
  String get folderSent => 'Enviado';

  @override
  String get folderDrafts => 'Borradores';

  @override
  String get folderTrash => 'Basura';

  @override
  String get folderArchive => 'Archivar';

  @override
  String get folderJunk => 'Chatarra';

  @override
  String get folderUnknown => 'Desconocido';

  @override
  String get viewContentsAction => 'Ver contenido';

  @override
  String get viewSourceAction => 'Ver fuente';

  @override
  String get detailsErrorDownloadInfo => 'No se pudo descargar el mensaje.';

  @override
  String get detailsErrorDownloadRetry => 'Reintentar';

  @override
  String get detailsHeaderFrom => 'De';

  @override
  String get detailsHeaderTo => 'A';

  @override
  String get detailsHeaderCc => 'CC';

  @override
  String get detailsHeaderBcc => 'BCC';

  @override
  String get detailsHeaderDate => 'Fecha';

  @override
  String get subjectUndefined => '<sin sujeto>';

  @override
  String get detailsActionShowImages => 'Mostrar imágenes';

  @override
  String get detailsNewsletterActionUnsubscribe => 'Desuscribirse';

  @override
  String get detailsNewsletterActionResubscribe => 'Volver a suscribirse';

  @override
  String get detailsNewsletterStatusUnsubscribed => 'No suscrito';

  @override
  String get detailsNewsletterUnsubscribeDialogTitle => 'Cancelar suscripción';

  @override
  String detailsNewsletterUnsubscribeDialogQuestion(String listName) {
    return '¿Quieres darte de baja de la lista de correo $listName?';
  }

  @override
  String get detailsNewsletterUnsubscribeDialogAction => 'Cancelar suscripción';

  @override
  String get detailsNewsletterUnsubscribeSuccessTitle => 'No suscrito';

  @override
  String detailsNewsletterUnsubscribeSuccessMessage(String listName) {
    return 'Te has dado de baja de la lista de correo $listName.';
  }

  @override
  String get detailsNewsletterUnsubscribeFailureTitle => 'No desuscrito';

  @override
  String detailsNewsletterUnsubscribeFailureMessage(String listName) {
    return 'Lo siento, pero no he podido darte de baja de $listName automáticamente.';
  }

  @override
  String get detailsNewsletterResubscribeDialogTitle => 'Volver a suscribirse';

  @override
  String detailsNewsletterResubscribeDialogQuestion(String listName) {
    return '¿Quieres suscribirte de nuevo a esta lista de correo $listName?';
  }

  @override
  String get detailsNewsletterResubscribeDialogAction => 'Suscribirse';

  @override
  String get detailsNewsletterResubscribeSuccessTitle => 'Suscrito';

  @override
  String detailsNewsletterResubscribeSuccessMessage(String listName) {
    return 'Ahora estás suscrito a la lista de correo $listName de nuevo.';
  }

  @override
  String get detailsNewsletterResubscribeFailureTitle => 'No suscrito';

  @override
  String detailsNewsletterResubscribeFailureMessage(String listName) {
    return 'Lo sentimos, pero la solicitud de suscripción ha fallado para la lista de correo $listName.';
  }

  @override
  String get detailsSendReadReceiptAction => 'Enviar recibo de lectura';

  @override
  String get detailsReadReceiptSentStatus => 'Leer el recibo enviado ✔️';

  @override
  String get detailsReadReceiptSubject => 'Leer recibo';

  @override
  String get attachmentActionOpen => 'Abrir';

  @override
  String attachmentDecodeError(String details) {
    return 'Este archivo adjunto tiene un formato o codificación no compatibles.\nDetalles: \$$details';
  }

  @override
  String attachmentDownloadError(String details) {
    return 'No se puede descargar este adjunto.\nDetalles: \$$details';
  }

  @override
  String get messageActionReply => 'Responder';

  @override
  String get messageActionReplyAll => 'Responder a todos';

  @override
  String get messageActionForward => 'Reenviar';

  @override
  String get messageActionForwardAsAttachment => 'Reenviar como archivo adjunto';

  @override
  String messageActionForwardAttachments(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Reenviar $numberString archivos adjuntos',
      one: '¡Adelante el adjunto',
    );
    return '$_temp0';
  }

  @override
  String get messagesActionForwardAttachments => 'Reenviar archivos adjuntos';

  @override
  String get messageActionDelete => 'Eliminar';

  @override
  String get messageActionMoveToInbox => 'Mover a bandeja de entrada';

  @override
  String get messageActionMove => 'Mover';

  @override
  String get messageStatusSeen => 'Es leído';

  @override
  String get messageStatusUnseen => 'No es leído';

  @override
  String get messageStatusFlagged => 'Está marcado';

  @override
  String get messageStatusUnflagged => 'No está marcado';

  @override
  String get messageActionMarkAsJunk => 'Marcar como basura';

  @override
  String get messageActionMarkAsNotJunk => 'Marcar como no basura';

  @override
  String get messageActionArchive => 'Archivar';

  @override
  String get messageActionUnarchive => 'Mover a bandeja de entrada';

  @override
  String get messageActionRedirect => 'Redireccionar';

  @override
  String get messageActionAddNotification => 'Añadir notificación';

  @override
  String get resultDeleted => 'Eliminado';

  @override
  String get resultMovedToJunk => 'Marcado como basura';

  @override
  String get resultMovedToInbox => 'Movido a la bandeja de entrada';

  @override
  String get resultArchived => 'Archivado';

  @override
  String get resultRedirectedSuccess => 'Mensaje redireccionado 👍';

  @override
  String resultRedirectedFailure(String details) {
    return 'No se puede redirigir el mensaje.\n\nEl servidor respondió con los siguientes detalles: \"$details\"';
  }

  @override
  String get redirectTitle => 'Redireccionar';

  @override
  String get redirectInfo => 'Redirigir este mensaje a los siguientes destinatarios. Redirigir no altera el mensaje.';

  @override
  String get redirectEmailInputRequired => 'Necesitas añadir al menos una dirección de correo electrónico válida.';

  @override
  String searchQueryDescription(String folder) {
    return 'Buscar en $folder...';
  }

  @override
  String searchQueryTitle(String query) {
    return 'Buscar \"$query\"';
  }

  @override
  String get legaleseUsage => 'Al utilizar Maily aceptas nuestras [PP] y nuestras [TC].';

  @override
  String get legalesePrivacyPolicy => 'Política de Privacidad';

  @override
  String get legaleseTermsAndConditions => 'Términos y Condiciones';

  @override
  String get aboutApplicationLegalese => 'Maily es un software libre publicado bajo la Licencia Pública General GNU.';

  @override
  String get feedbackActionSuggestFeature => 'Sugerir una característica';

  @override
  String get feedbackActionReportProblem => 'Reportar un problema';

  @override
  String get feedbackActionHelpDeveloping => 'Ayuda al desarrollo de Maily';

  @override
  String get feedbackTitle => 'Comentarios';

  @override
  String get feedbackIntro => '¡Gracias por probar Maily!';

  @override
  String get feedbackProvideInfoRequest => 'Por favor, proporcione esta información cuando reporte un problema:';

  @override
  String get feedbackResultInfoCopied => 'Copiado al portapapeles';

  @override
  String get accountsTitle => 'Cuentas';

  @override
  String get accountsActionReorder => 'Reordenar cuentas';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSecurityBlockExternalImages => 'Bloquear imágenes externas';

  @override
  String get settingsSecurityBlockExternalImagesDescriptionTitle => 'Imágenes externas';

  @override
  String get settingsSecurityBlockExternalImagesDescriptionText => 'Los mensajes de correo electrónico pueden contener imágenes que están integradas o alojadas en servidores externos. Este último, imágenes externas pueden exponer información al remitente del mensaje, por ejemplo, para que el remitente sepa que ha abierto el mensaje. Esta opción le permite bloquear dichas imágenes externas, lo que reduce el riesgo de exponer información confidencial. Todavía puede optar por cargar dichas imágenes por mensaje cuando lea un mensaje.';

  @override
  String get settingsSecurityMessageRenderingHtml => 'Mostrar contenido completo del mensaje';

  @override
  String get settingsSecurityMessageRenderingPlainText => 'Mostrar sólo el texto de los mensajes';

  @override
  String get settingsSecurityLaunchModeLabel => '¿Cómo debe abrir enlaces Maily?';

  @override
  String get settingsSecurityLaunchModeExternal => 'Abrir enlaces externamente';

  @override
  String get settingsSecurityLaunchModeInApp => 'Abrir enlaces en Maily';

  @override
  String get settingsActionAccounts => 'Administrar cuentas';

  @override
  String get settingsActionDesign => 'Apariencia';

  @override
  String get settingsActionFeedback => 'Proporcionar comentarios';

  @override
  String get settingsActionWelcome => 'Mostrar bienvenida';

  @override
  String get settingsReadReceipts => 'Leer recibos';

  @override
  String get readReceiptsSettingsIntroduction => '¿Quieres mostrar las solicitudes de recibos de lectura?';

  @override
  String get readReceiptOptionAlways => 'Siempre';

  @override
  String get readReceiptOptionNever => 'Nunca';

  @override
  String get settingsFolders => 'Carpetas';

  @override
  String get folderNamesIntroduction => '¿Qué nombres prefiere para sus carpetas?';

  @override
  String get folderNamesSettingLocalized => 'Nombres dados por Maily';

  @override
  String get folderNamesSettingServer => 'Nombres dados por el servicio';

  @override
  String get folderNamesSettingCustom => 'Mis nombres personalizados';

  @override
  String get folderNamesEditAction => 'Editar nombres personalizados';

  @override
  String get folderNamesCustomTitle => 'Nombres personalizados';

  @override
  String get folderAddAction => 'Crear carpeta';

  @override
  String get folderAddTitle => 'Crear carpeta';

  @override
  String get folderAddNameLabel => 'Nombre';

  @override
  String get folderAddNameHint => 'Nombre de la nueva carpeta';

  @override
  String get folderAccountLabel => 'Cuenta';

  @override
  String get folderMailboxLabel => 'Carpeta';

  @override
  String get folderAddResultSuccess => 'Carpeta creada 😊';

  @override
  String folderAddResultFailure(String details) {
    return 'No se pudo crear la carpeta.\n\nEl servidor respondió con $details';
  }

  @override
  String get folderDeleteAction => 'Eliminar';

  @override
  String get folderDeleteConfirmTitle => 'Confirmar';

  @override
  String folderDeleteConfirmText(String name) {
    return '¿Realmente desea eliminar la carpeta $name?';
  }

  @override
  String get folderDeleteResultSuccess => 'Carpeta eliminada.';

  @override
  String folderDeleteResultFailure(String details) {
    return 'No se ha podido eliminar la carpeta.\n\nEl servidor ha respondido con $details';
  }

  @override
  String get settingsDevelopment => 'Configuración de desarrollo';

  @override
  String get developerModeTitle => 'Modo de desarrollo';

  @override
  String get developerModeIntroduction => 'Si activas el modo de desarrollo podrás ver el código fuente de los mensajes y convertir los archivos adjuntos de texto a mensajes.';

  @override
  String get developerModeEnable => 'Activar modo de desarrollo';

  @override
  String get developerShowAsEmail => 'Convertir texto a email';

  @override
  String get developerShowAsEmailFailed => 'Este texto no se puede convertir en un mensaje MIME.';

  @override
  String get designTitle => 'Ajustes de diseño';

  @override
  String get designSectionThemeTitle => 'Tema';

  @override
  String get designThemeOptionLight => 'Luz';

  @override
  String get designThemeOptionDark => 'Oscuro';

  @override
  String get designThemeOptionSystem => 'Sistema';

  @override
  String get designThemeOptionCustom => 'Personalizado';

  @override
  String get designSectionCustomTitle => 'Activar tema oscuro';

  @override
  String designThemeCustomStart(String time) {
    return 'de $time';
  }

  @override
  String designThemeCustomEnd(String time) {
    return 'hasta $time';
  }

  @override
  String get designSectionColorTitle => 'Esquema de color';

  @override
  String get securitySettingsTitle => 'Seguridad';

  @override
  String get securitySettingsIntro => 'Adapte la configuración de seguridad a sus necesidades personales.';

  @override
  String get securityUnlockWithFaceId => 'Desbloquea Maily con Face ID.';

  @override
  String get securityUnlockWithTouchId => 'Desbloquea Maily con Touch ID.';

  @override
  String get securityUnlockReason => 'Desbloquea Maily.';

  @override
  String get securityUnlockDisableReason => 'Desbloquear Maily para desactivar el bloqueo.';

  @override
  String get securityUnlockNotAvailable => 'Su dispositivo no soporta biométricos, posiblemente necesite configurar las opciones de desbloqueo primero.';

  @override
  String get securityUnlockLabel => 'Bloquear Maily';

  @override
  String get securityUnlockDescriptionTitle => 'Bloquear Maily';

  @override
  String get securityUnlockDescriptionText => 'Puedes elegir bloquear el acceso a Maily, para que otros no puedan leer tu correo electrónico incluso cuando tengan acceso a tu dispositivo.';

  @override
  String get securityLockImmediately => 'Bloquear inmediatamente';

  @override
  String get securityLockAfter5Minutes => 'Bloquear después de 5 minutos';

  @override
  String get securityLockAfter30Minutes => 'Bloquear después de 30 minutos';

  @override
  String get lockScreenTitle => 'Maily está bloqueado';

  @override
  String get lockScreenIntro => 'Maily está bloqueado, por favor autentifíquese para continuar.';

  @override
  String get lockScreenUnlockAction => 'Desbloquear';

  @override
  String get addAccountTitle => 'Añadir cuenta';

  @override
  String get addAccountEmailLabel => 'E-mail';

  @override
  String get addAccountEmailHint => 'Introduzca su dirección de correo electrónico';

  @override
  String addAccountResolvingSettingsLabel(String email) {
    return 'Resolviendo $email...';
  }

  @override
  String addAccountResolvedSettingsWrongAction(String provider) {
    return '¿No está en $provider?';
  }

  @override
  String addAccountResolvingSettingsFailedInfo(String email) {
    return 'No se puede resolver $email. Por favor, vuelve a cambiarlo o configura la cuenta manualmente.';
  }

  @override
  String get addAccountEditManuallyAction => 'Editar manualmente';

  @override
  String get addAccountPasswordLabel => 'Contraseña';

  @override
  String get addAccountPasswordHint => 'Por favor, introduce tu contraseña';

  @override
  String get addAccountApplicationPasswordRequiredInfo => 'Este proveedor requiere que establezcas una contraseña específica para la aplicación.';

  @override
  String get addAccountApplicationPasswordRequiredButton => 'Crear contraseña específica de la aplicación';

  @override
  String get addAccountApplicationPasswordRequiredAcknowledged => 'Ya tengo una contraseña de la aplicación';

  @override
  String get addAccountVerificationStep => 'Verificación';

  @override
  String get addAccountSetupAccountStep => 'Configuracion de Cuenta';

  @override
  String addAccountVerifyingSettingsLabel(String email) {
    return 'Verificando $email...';
  }

  @override
  String addAccountVerifyingSuccessInfo(String email) {
    return 'Has iniciado sesión con éxito en $email.';
  }

  @override
  String addAccountVerifyingFailedInfo(String email) {
    return 'Lo sentimos, pero ha habido un problema. Por favor, comprueba tu correo electrónico $email y contraseña.';
  }

  @override
  String addAccountOauthOptionsText(String provider) {
    return 'Inicie sesión con $provider o cree una contraseña específica de la aplicación.';
  }

  @override
  String addAccountOauthSignIn(String provider) {
    return 'Iniciar sesión con $provider';
  }

  @override
  String get addAccountOauthSignInGoogle => 'Iniciar sesión con Google';

  @override
  String get addAccountOauthSignInWithAppPassword => 'Alternativamente, cree una contraseña de la aplicación para iniciar sesión.';

  @override
  String get accountAddImapAccessSetupMightBeRequired => 'Su proveedor puede requerir que configure el acceso para aplicaciones de correo electrónico manualmente.';

  @override
  String get addAccountSetupImapAccessButtonLabel => 'Configurar acceso a email';

  @override
  String get addAccountNameOfUserLabel => 'Tu nombre';

  @override
  String get addAccountNameOfUserHint => 'El nombre que los destinatarios ven';

  @override
  String get addAccountNameOfAccountLabel => 'Nombre de cuenta';

  @override
  String get addAccountNameOfAccountHint => 'Introduce el nombre de tu cuenta';

  @override
  String editAccountTitle(String name) {
    return 'Editar $name';
  }

  @override
  String editAccountFailureToConnectInfo(String name) {
    return 'Maily no pudo conectar $name.';
  }

  @override
  String get editAccountFailureToConnectRetryAction => 'Reintentar';

  @override
  String get editAccountFailureToConnectChangePasswordAction => 'Cambiar contraseña';

  @override
  String get editAccountFailureToConnectFixedTitle => 'Conectado';

  @override
  String get editAccountFailureToConnectFixedInfo => 'La cuenta está conectada de nuevo.';

  @override
  String get editAccountIncludeInUnifiedLabel => 'Incluye en cuenta unificada';

  @override
  String editAccountAliasLabel(String email) {
    return 'Direcciones de correo electrónico de $email:';
  }

  @override
  String get editAccountNoAliasesInfo => 'Aún no tienes alias conocidos para esta cuenta.';

  @override
  String editAccountAliasRemoved(String email) {
    return 'Alias $email eliminado';
  }

  @override
  String get editAccountAddAliasAction => 'Añadir alias';

  @override
  String get editAccountPlusAliasesSupported => 'Soporta + alias';

  @override
  String get editAccountCheckPlusAliasAction => 'Prueba de soporte para + alias';

  @override
  String get editAccountBccMyself => 'BCC mismo';

  @override
  String get editAccountBccMyselfDescriptionTitle => 'BCC mismo';

  @override
  String get editAccountBccMyselfDescriptionText => 'Puedes enviar automáticamente mensajes a ti mismo para cada mensaje que envíes desde esta cuenta con la función \"BCC yo\". Normalmente esto no es necesario y deseado, ya que todos los mensajes salientes se almacenan en la carpeta \"Enviado\" de todos modos.';

  @override
  String get editAccountServerSettingsAction => 'Editar configuración del servidor';

  @override
  String get editAccountDeleteAccountAction => 'Eliminar cuenta';

  @override
  String get editAccountDeleteAccountConfirmationTitle => 'Confirmar';

  @override
  String editAccountDeleteAccountConfirmationQuery(String name) {
    return '¿Quieres eliminar la cuenta $name?';
  }

  @override
  String editAccountTestPlusAliasTitle(String name) {
    return '+ Alias para $name';
  }

  @override
  String get editAccountTestPlusAliasStepIntroductionTitle => 'Introducción';

  @override
  String editAccountTestPlusAliasStepIntroductionText(String accountName, String example) {
    return 'Tu cuenta $accountName podría ser compatible con los alias + llamados como $example.\nUn alias A + te ayuda a proteger tu identidad y te ayuda contra el spam.\nPara probarlo, se enviará un mensaje de prueba a esta dirección generada. Si llega, su proveedor soporta + alias y puede generarlos fácilmente a petición al escribir un nuevo mensaje de correo.';
  }

  @override
  String get editAccountTestPlusAliasStepTestingTitle => 'Pruebas';

  @override
  String get editAccountTestPlusAliasStepResultTitle => 'Resultado';

  @override
  String editAccountTestPlusAliasStepResultSuccess(String name) {
    return 'Tu cuenta $name soporta + alias.';
  }

  @override
  String editAccountTestPlusAliasStepResultNoSuccess(String name) {
    return 'Tu cuenta $name no soporta + alias.';
  }

  @override
  String get editAccountAddAliasTitle => 'Añadir alias';

  @override
  String get editAccountEditAliasTitle => 'Editar alias';

  @override
  String get editAccountAliasAddAction => 'Añadir';

  @override
  String get editAccountAliasUpdateAction => 'Actualizar';

  @override
  String get editAccountEditAliasNameLabel => 'Nombre del alias';

  @override
  String get editAccountEditAliasEmailLabel => 'Alias email';

  @override
  String get editAccountEditAliasEmailHint => 'Tu dirección de email de alias';

  @override
  String editAccountEditAliasDuplicateError(String email) {
    return 'Ya hay un alias con $email.';
  }

  @override
  String get editAccountEnableLogging => 'Activar registro';

  @override
  String get editAccountLoggingEnabled => 'Registro habilitado, por favor reinicie';

  @override
  String get editAccountLoggingDisabled => 'Registro desactivado, por favor reinicie';

  @override
  String get accountDetailsFallbackTitle => 'Ajustes del servidor';

  @override
  String get errorTitle => 'Error';

  @override
  String get accountProviderStepTitle => 'Proveedor de Servicio de Email';

  @override
  String get accountProviderCustom => 'Otro servicio de email';

  @override
  String accountDetailsErrorHostProblem(String incomingHost, String outgoingHost) {
    return 'Maily no puede llegar al servidor de correo especificado. Por favor, compruebe la configuración del servidor de entrada \"$incomingHost\" y la configuración del servidor de salida \"$outgoingHost\".';
  }

  @override
  String accountDetailsErrorLoginProblem(String userName, String password) {
    return 'No se puede iniciar sesión. Por favor, comprueba tu nombre de usuario \"$userName\" y tu contraseña \"$password\".';
  }

  @override
  String get accountDetailsUserNameLabel => 'Nombre de usuario';

  @override
  String get accountDetailsUserNameHint => 'Su nombre de usuario, si es diferente del correo electrónico';

  @override
  String get accountDetailsPasswordLabel => 'Contraseña de acceso';

  @override
  String get accountDetailsPasswordHint => 'Su contraseña';

  @override
  String get accountDetailsBaseSectionTitle => 'Ajustes de base';

  @override
  String get accountDetailsIncomingLabel => 'Servidor entrante';

  @override
  String get accountDetailsIncomingHint => 'Dominio como imap.domain.com';

  @override
  String get accountDetailsOutgoingLabel => 'Servidor saliente';

  @override
  String get accountDetailsOutgoingHint => 'Dominio como smtp.domain.com';

  @override
  String get accountDetailsAdvancedIncomingSectionTitle => 'Configuración avanzada de entrada';

  @override
  String get accountDetailsIncomingServerTypeLabel => 'Tipo de entrada:';

  @override
  String get accountDetailsOptionAutomatic => 'automático';

  @override
  String get accountDetailsIncomingSecurityLabel => 'Seguridad entrante:';

  @override
  String get accountDetailsSecurityOptionNone => 'Plain (sin cifrado)';

  @override
  String get accountDetailsIncomingPortLabel => 'Puerto entrante';

  @override
  String get accountDetailsPortHint => 'Dejar en blanco para determinar automáticamente';

  @override
  String get accountDetailsIncomingUserNameLabel => 'Nombre de usuario entrante';

  @override
  String get accountDetailsAlternativeUserNameHint => 'Tu nombre de usuario, si es diferente de arriba';

  @override
  String get accountDetailsIncomingPasswordLabel => 'Contraseña entrante';

  @override
  String get accountDetailsAlternativePasswordHint => 'Su contraseña, si es diferente de la anterior';

  @override
  String get accountDetailsAdvancedOutgoingSectionTitle => 'Ajustes avanzados de salida';

  @override
  String get accountDetailsOutgoingServerTypeLabel => 'Tipo saliente:';

  @override
  String get accountDetailsOutgoingSecurityLabel => 'Seguridad saliente:';

  @override
  String get accountDetailsOutgoingPortLabel => 'Puerto saliente';

  @override
  String get accountDetailsOutgoingUserNameLabel => 'Nombre de usuario saliente';

  @override
  String get accountDetailsOutgoingPasswordLabel => 'Contraseña saliente';

  @override
  String get composeTitleNew => 'Nuevo mensaje';

  @override
  String get composeTitleForward => 'Reenviar';

  @override
  String get composeTitleReply => 'Responder';

  @override
  String get composeEmptyMessage => 'mensaje vacío';

  @override
  String get composeWarningNoSubject => 'No ha especificado un asunto. ¿Desea enviar el mensaje sin un asunto?';

  @override
  String get composeActionSentWithoutSubject => 'Enviar';

  @override
  String get composeMailSendSuccess => 'Email enviado 😊';

  @override
  String composeSendErrorInfo(String details) {
    return 'Lo sentimos, no se ha podido enviar tu correo. Hemos recibido el siguiente error:\n$details.';
  }

  @override
  String get composeRequestReadReceiptAction => 'Solicitar recibo de lectura';

  @override
  String get composeSaveDraftAction => 'Guardar como borrador';

  @override
  String get composeMessageSavedAsDraft => 'Borrador guardado';

  @override
  String composeMessageSavedAsDraftErrorInfo(String details) {
    return 'No se ha podido guardar tu borrador con el siguiente error:\n$details';
  }

  @override
  String get composeConvertToPlainTextEditorAction => 'Convertir a texto plano';

  @override
  String get composeConvertToHtmlEditorAction => 'Convertir a mensaje enriquecido (HTML)';

  @override
  String get composeContinueEditingAction => 'Continuar editando';

  @override
  String get composeCreatePlusAliasAction => 'Crear nuevos + alias...';

  @override
  String get composeSenderHint => 'Remitente';

  @override
  String get composeRecipientHint => 'Email del destinatario';

  @override
  String get composeSubjectLabel => 'Sujeto';

  @override
  String get composeSubjectHint => 'Asunto del mensaje';

  @override
  String get composeAddAttachmentAction => 'Añadir';

  @override
  String composeRemoveAttachmentAction(String name) {
    return 'Eliminar $name';
  }

  @override
  String get composeLeftByMistake => '¿Dejado por error?';

  @override
  String get attachTypeFile => 'Fichero';

  @override
  String get attachTypePhoto => 'Foto';

  @override
  String get attachTypeVideo => 'Vídeo';

  @override
  String get attachTypeAudio => 'Audio';

  @override
  String get attachTypeLocation => 'Ubicación';

  @override
  String get attachTypeGif => 'Gif animado';

  @override
  String get attachTypeGifSearch => 'buscar GIPHY';

  @override
  String get attachTypeSticker => 'Pegatina';

  @override
  String get attachTypeStickerSearch => 'buscar GIPHY';

  @override
  String get attachTypeAppointment => 'Cita';

  @override
  String get languageSettingTitle => 'Idioma';

  @override
  String get languageSettingLabel => 'Elige el idioma para Maily:';

  @override
  String get languageSettingSystemOption => 'Idioma del sistema';

  @override
  String get languageSettingConfirmationTitle => '¿Usar Inglés para Maily?';

  @override
  String get languageSettingConfirmationQuery => 'Por favor confirme el uso del inglés como idioma elegido.';

  @override
  String get languageSetInfo => 'Ahora se muestra en inglés. Por favor, reinicia la aplicación para que surta efecto.';

  @override
  String get languageSystemSetInfo => 'Maily ahora utilizará el idioma del sistema o Inglés si el idioma del sistema no es compatible.';

  @override
  String get swipeSettingTitle => 'Deslizar gestos';

  @override
  String get swipeSettingLeftToRightLabel => 'Deslizar de izquierda a derecha';

  @override
  String get swipeSettingRightToLeftLabel => 'Deslizar derecha a izquierda';

  @override
  String get swipeSettingChangeAction => 'Cambiar';

  @override
  String get signatureSettingsTitle => 'Firma';

  @override
  String get signatureSettingsComposeActionsInfo => 'Activar la firma para los siguientes mensajes:';

  @override
  String get signatureSettingsAccountInfo => 'Puede especificar firmas específicas de la cuenta en la configuración de la cuenta.';

  @override
  String signatureSettingsAddForAccount(String account) {
    return 'Añadir firma para $account';
  }

  @override
  String get defaultSenderSettingsTitle => 'Remitente por defecto';

  @override
  String get defaultSenderSettingsLabel => 'Seleccione el remitente para nuevos mensajes.';

  @override
  String defaultSenderSettingsFirstAccount(String email) {
    return 'Primera cuenta ($email)';
  }

  @override
  String get defaultSenderSettingsAliasInfo => 'Puede configurar direcciones de alias de correo electrónico en la [AS].';

  @override
  String get defaultSenderSettingsAliasAccountSettings => 'configuración de cuenta';

  @override
  String get replySettingsTitle => 'Formato de mensaje';

  @override
  String get replySettingsIntro => '¿En qué formato desea responder o reenviar el correo electrónico por defecto?';

  @override
  String get replySettingsFormatHtml => 'Formato siempre rico (HTML)';

  @override
  String get replySettingsFormatSameAsOriginal => 'Usar el mismo formato que el correo original';

  @override
  String get replySettingsFormatPlainText => 'Siempre sólo texto';

  @override
  String get moveTitle => 'Mover mensaje';

  @override
  String moveSuccess(String mailbox) {
    return 'Mensajes movidos a $mailbox.';
  }

  @override
  String get editorArtInputLabel => 'Tu entrada';

  @override
  String get editorArtInputHint => 'Introduce el texto aquí';

  @override
  String get editorArtWaitingForInputHint => 'esperando por entrada...';

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
  String get fontScript => 'Escribir';

  @override
  String get fontScriptBold => 'Escribir negrita';

  @override
  String get fontFraktur => 'Fraktur';

  @override
  String get fontFrakturBold => 'Fraktur bold';

  @override
  String get fontMonospace => 'Monoespaciado';

  @override
  String get fontFullwidth => 'Ancho completo';

  @override
  String get fontDoublestruck => 'Doble golpeado';

  @override
  String get fontCapitalized => 'Capitalizado';

  @override
  String get fontCircled => 'Circlado';

  @override
  String get fontParenthesized => 'Parentesizado';

  @override
  String get fontUnderlinedSingle => 'Subrayado';

  @override
  String get fontUnderlinedDouble => 'Doble subrayado';

  @override
  String get fontStrikethroughSingle => 'Golpear a través';

  @override
  String get fontCrosshatch => 'Crosshatch';

  @override
  String accountLoadError(String name) {
    return 'No se puede conectar a su cuenta $name. ¿Ha cambiado la contraseña?';
  }

  @override
  String get accountLoadErrorEditAction => 'Editar cuenta';

  @override
  String get extensionsTitle => 'Extensiones';

  @override
  String get extensionsIntro => 'Con los proveedores de servicios de correo electrónico de extensiones, las empresas y los desarrolladores pueden adaptarse a las funcionalidades más útiles.';

  @override
  String get extensionsLearnMoreAction => 'Más información sobre extensiones';

  @override
  String get extensionsReloadAction => 'Recargar extensiones';

  @override
  String get extensionDeactivateAllAction => 'Desactivar todas las extensiones';

  @override
  String get extensionsManualAction => 'Cargar manualmente';

  @override
  String get extensionsManualUrlLabel => 'Url de la extensión';

  @override
  String extensionsManualLoadingError(String url) {
    return 'No se ha podido descargar la extensión de \"$url\".';
  }

  @override
  String get icalendarAcceptTentatively => 'Tentativamente';

  @override
  String get icalendarActionChangeParticipantStatus => 'Cambiar';

  @override
  String get icalendarLabelSummary => 'Título';

  @override
  String get icalendarNoSummaryInfo => '(sin título)';

  @override
  String get icalendarLabelDescription => 'Descripción';

  @override
  String get icalendarLabelStart => 'Comenzar';

  @override
  String get icalendarLabelEnd => 'Fin';

  @override
  String get icalendarLabelDuration => 'Duración';

  @override
  String get icalendarLabelLocation => 'Ubicación';

  @override
  String get icalendarLabelTeamsUrl => 'Enlace';

  @override
  String get icalendarLabelRecurrenceRule => 'Repetir';

  @override
  String get icalendarLabelParticipants => 'Participantes';

  @override
  String get icalendarParticipantStatusNeedsAction => 'Se le pide que responda a esta invitación.';

  @override
  String get icalendarParticipantStatusAccepted => 'Has aceptado esta invitación.';

  @override
  String get icalendarParticipantStatusDeclined => 'Has rechazado esta invitación.';

  @override
  String get icalendarParticipantStatusAcceptedTentatively => 'Has aceptado esta invitación de forma tentativa.';

  @override
  String get icalendarParticipantStatusDelegated => 'Usted ha delegado esta invitación.';

  @override
  String get icalendarParticipantStatusInProcess => 'La tarea está en curso.';

  @override
  String get icalendarParticipantStatusPartial => 'La tarea está parcialmente hecha.';

  @override
  String get icalendarParticipantStatusCompleted => 'La tarea está hecha.';

  @override
  String get icalendarParticipantStatusOther => 'Su estado es desconocido.';

  @override
  String get icalendarParticipantStatusChangeTitle => 'Tu estado';

  @override
  String get icalendarParticipantStatusChangeText => '¿Quieres aceptar esta invitación?';

  @override
  String icalendarParticipantStatusSentFailure(String details) {
    return 'No se puede enviar la respuesta.\nEl servidor respondió con los siguientes detalles:\n$details';
  }

  @override
  String get icalendarExportAction => 'Exportar';

  @override
  String icalendarReplyStatusNeedsAction(String attendee) {
    return '$attendee no ha respondido a esta invitación.';
  }

  @override
  String icalendarReplyStatusAccepted(String attendee) {
    return '$attendee ha aceptado la cita.';
  }

  @override
  String icalendarReplyStatusDeclined(String attendee) {
    return '$attendee ha rechazado esta invitación.';
  }

  @override
  String icalendarReplyStatusAcceptedTentatively(String attendee) {
    return '$attendee ha aceptado tentativamente esta invitación.';
  }

  @override
  String icalendarReplyStatusDelegated(String attendee) {
    return '$attendee ha delegado esta invitación.';
  }

  @override
  String icalendarReplyStatusInProcess(String attendee) {
    return '$attendee ha iniciado esta tarea.';
  }

  @override
  String icalendarReplyStatusPartial(String attendee) {
    return '$attendee ha realizado parcialmente esta tarea.';
  }

  @override
  String icalendarReplyStatusCompleted(String attendee) {
    return '$attendee ha finalizado esta tarea.';
  }

  @override
  String icalendarReplyStatusOther(String attendee) {
    return '$attendee ha respondido con un estado desconocido.';
  }

  @override
  String get icalendarReplyWithoutParticipants => 'Esta respuesta de calendario no contiene participantes.';

  @override
  String icalendarReplyWithoutStatus(String attendee) {
    return '$attendee respondió sin un estado de participación.';
  }

  @override
  String get composeAppointmentTitle => 'Crear cita';

  @override
  String get composeAppointmentLabelDay => 'día';

  @override
  String get composeAppointmentLabelTime => 'tiempo';

  @override
  String get composeAppointmentLabelAllDayEvent => 'Todo el día';

  @override
  String get composeAppointmentLabelRepeat => 'Repetir';

  @override
  String get composeAppointmentLabelRepeatOptionNever => 'Nunca';

  @override
  String get composeAppointmentLabelRepeatOptionDaily => 'Diario';

  @override
  String get composeAppointmentLabelRepeatOptionWeekly => 'Semanal';

  @override
  String get composeAppointmentLabelRepeatOptionMonthly => 'Mensual';

  @override
  String get composeAppointmentLabelRepeatOptionYearly => 'Anualmente';

  @override
  String get composeAppointmentRecurrenceFrequencyLabel => 'Frecuencia';

  @override
  String get composeAppointmentRecurrenceIntervalLabel => 'Intervalo';

  @override
  String get composeAppointmentRecurrenceDaysLabel => 'En días';

  @override
  String get composeAppointmentRecurrenceUntilLabel => 'Hasta';

  @override
  String get composeAppointmentRecurrenceUntilOptionUnlimited => 'Sin límite';

  @override
  String composeAppointmentRecurrenceUntilOptionRecommended(String duration) {
    return 'Recomendado ($duration)';
  }

  @override
  String get composeAppointmentRecurrenceUntilOptionSpecificDate => 'Hasta la fecha elegida';

  @override
  String composeAppointmentRecurrenceMonthlyOnDayOfMonth(int day) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String dayString = dayNumberFormat.format(day);

    return 'El $dayString. día del mes';
  }

  @override
  String get composeAppointmentRecurrenceMonthlyOnWeekDay => 'Día de la semana en mes';

  @override
  String get composeAppointmentRecurrenceFirst => 'Primero';

  @override
  String get composeAppointmentRecurrenceSecond => 'Segundo';

  @override
  String get composeAppointmentRecurrenceThird => 'Tercer';

  @override
  String get composeAppointmentRecurrenceLast => 'Último';

  @override
  String get composeAppointmentRecurrenceSecondLast => 'Segundo-último';

  @override
  String durationYears(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString años',
      one: '1 año',
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
      other: '$numberString meses',
      one: '1 mes',
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
      other: '$numberString semanas',
      one: '1 semana',
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
      other: '$numberString días',
      one: '1 día',
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
      other: '$numberString horas',
      one: '1 hora',
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
      other: '$numberString minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get durationEmpty => 'Sin duración';
}
