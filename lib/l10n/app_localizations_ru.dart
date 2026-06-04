// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Secure Messenger';

  @override
  String get chatsTitle => 'Чаты';

  @override
  String get searchChats => 'Поиск чатов...';

  @override
  String get noSecureChats => 'Пока нет безопасных чатов';

  @override
  String get startChatSubtitle =>
      'Нажмите кнопку ниже, чтобы начать\nзащищенную беседу.';

  @override
  String get deleteChat => 'Удалить чат';

  @override
  String get deleteChatConfirm => 'Вы уверены, что хотите удалить этот чат?';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get noChatsFound => 'Чаты не найдены';

  @override
  String get newChat => 'Новый чат';

  @override
  String get searchUsername => 'Поиск по имени пользователя...';

  @override
  String get findPeople => 'Найдите собеседника';

  @override
  String get typeUsername =>
      'Введите имя пользователя выше, чтобы начать\nновый защищенный чат.';

  @override
  String get tapToStart => 'Нажмите, чтобы начать защищенный чат';

  @override
  String get secureMessage => 'Безопасное сообщение...';

  @override
  String get decryptionFailed => 'Ошибка расшифровки';

  @override
  String get secureMessageFallback => 'Зашифрованное сообщение';

  @override
  String get settings => 'Настройки';

  @override
  String get profile => 'Профиль';

  @override
  String get privacySecurity => 'Конфиденциальность и безопасность';

  @override
  String get notifications => 'Уведомления';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get language => 'Язык';

  @override
  String get english => 'Английский';

  @override
  String get russian => 'Русский';

  @override
  String get logout => 'Выйти';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get online => 'в сети';

  @override
  String get offline => 'не в сети';

  @override
  String lastSeenAt(Object time) {
    return 'был(а) в $time';
  }

  @override
  String lastSeen(Object date) {
    return 'был(а) $date';
  }

  @override
  String get endToEndEncrypted => 'Сквозное шифрование';

  @override
  String get noOneOutside =>
      'Никто вне этого чата, даже\nсервер, не сможет прочитать ваши сообщения.';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get signInSubtitle => 'Войдите, чтобы продолжить безопасно';

  @override
  String get username => 'Имя пользователя';

  @override
  String get password => 'Пароль';

  @override
  String get login => 'Войти';

  @override
  String get noAccount => 'Нет аккаунта? Зарегистрируйтесь';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get joinSecure => 'Присоединяйтесь к защищенному мессенджеру';

  @override
  String get signUp => 'Регистрация';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get e2eEncryptionOn => 'Сквозное шифрование ВКЛЮЧЕНО';

  @override
  String get messageTones => 'Звуки сообщений, вибрация';

  @override
  String get chooseTheme => 'Выберите тему';

  @override
  String get system => 'Системная';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Темная';

  @override
  String get photoVideo => 'Фото/Видео';

  @override
  String get camera => 'Камера';

  @override
  String get document => 'Документ';

  @override
  String get fileTooLargeCompressing => 'Файл слишком большой, сжимаем...';

  @override
  String get photoTapToDownload => 'Фото (Нажмите, чтобы скачать)';

  @override
  String get videoTapToDownload => 'Видео (Нажмите, чтобы скачать)';

  @override
  String get videoTooLarge => 'Видео слишком большое. Лимит 50 МБ.';

  @override
  String get save => 'Сохранить';

  @override
  String get aboutMe => 'Обо мне';

  @override
  String get noBioSet => 'Информация не указана';

  @override
  String get tellUsAboutYourself => 'Расскажите о себе...';

  @override
  String get savedToGallery => 'Сохранено в галерею';

  @override
  String get storageAndData => 'Данные и память';

  @override
  String get autoClearCache => 'Автоочистка кэша через';

  @override
  String get never => 'Никогда';

  @override
  String get oneDay => '1 День';

  @override
  String get oneWeek => '1 Неделю';

  @override
  String get oneMonth => '1 Месяц';

  @override
  String get activeStatus => 'В сети';

  @override
  String get avatarUpdated => 'Аватар успешно обновлен';

  @override
  String avatarUpdateFailed(Object error) {
    return 'Ошибка обновления аватара: $error';
  }

  @override
  String get bioUpdated => 'Информация обновлена';

  @override
  String bioUpdateFailed(Object error) {
    return 'Ошибка обновления информации: $error';
  }

  @override
  String get tapToRetry => 'Нажмите, чтобы повторить';

  @override
  String get deleteForMe => 'Удалить у меня';

  @override
  String get deleteForEveryone => 'Удалить у всех';

  @override
  String get messageDeleted => 'Сообщение удалено';

  @override
  String get noMessagesYet => 'Пока нет сообщений';

  @override
  String get imageMessage => '📷 Фото';

  @override
  String get videoMessage => '🎥 Видео';

  @override
  String get documentMessage => '📄 Документ';

  @override
  String get audioMessage => '🎵 Аудио';

  @override
  String get secretChat => 'Секретный чат';

  @override
  String get secretChatSubtitle => 'Удаление сообщений по таймеру';

  @override
  String get disappearingTimer => 'Таймер удаления: ';

  @override
  String get seconds10 => '10 секунд';

  @override
  String get seconds30 => '30 секунд';

  @override
  String get minute1 => '1 минута';

  @override
  String get hour1 => '1 час';

  @override
  String get secureChat => 'Защищенный чат';

  @override
  String get setPinTitle => 'Установите ПИН-код';

  @override
  String get setPinSubtitle =>
      'Создайте 4-значный ПИН-код для защиты приложения';

  @override
  String get confirmPinTitle => 'Подтвердите ПИН-код';

  @override
  String get confirmPinSubtitle =>
      'Введите 4-значный ПИН-код еще раз для подтверждения';

  @override
  String get pinMismatch => 'ПИН-коды не совпадают. Попробуйте еще раз.';

  @override
  String get enableBiometricsTitle => 'Включить биометрию';

  @override
  String get enableBiometricsSubtitle =>
      'Хотите использовать отпечаток пальца или FaceID для быстрого входа в приложение?';

  @override
  String get enable => 'Включить';

  @override
  String get skip => 'Пропустить';

  @override
  String get enterPinTitle => 'Введите ПИН-код';

  @override
  String get enterPinSubtitle =>
      'Введите ваш 4-значный ПИН-код для разблокировки';

  @override
  String get incorrectPin => 'Неверный ПИН-код. Попробуйте еще раз.';

  @override
  String get biometricReason =>
      'Пожалуйста, пройдите аутентификацию для разблокировки приложения';

  @override
  String get biometricSettings => 'Вход по биометрии';
}
