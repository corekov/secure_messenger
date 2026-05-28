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
}
