// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Secure Messenger';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get searchChats => 'Search chats...';

  @override
  String get noSecureChats => 'No secure chats yet';

  @override
  String get startChatSubtitle =>
      'Tap the button below to start an\nend-to-end encrypted conversation.';

  @override
  String get deleteChat => 'Delete Chat';

  @override
  String get deleteChatConfirm => 'Are you sure you want to delete this chat?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get noChatsFound => 'No chats found';

  @override
  String get newChat => 'New Chat';

  @override
  String get searchUsername => 'Search username...';

  @override
  String get findPeople => 'Find people securely';

  @override
  String get typeUsername =>
      'Type a username above to start\na new end-to-end encrypted chat.';

  @override
  String get tapToStart => 'Tap to start secure chat';

  @override
  String get secureMessage => 'Secure message...';

  @override
  String get decryptionFailed => 'Decryption failed';

  @override
  String get secureMessageFallback => 'Secure message';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get notifications => 'Notifications';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get russian => 'Russian';

  @override
  String get logout => 'Logout';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get online => 'online';

  @override
  String get offline => 'offline';

  @override
  String lastSeenAt(Object time) {
    return 'last seen at $time';
  }

  @override
  String lastSeen(Object date) {
    return 'last seen $date';
  }

  @override
  String get endToEndEncrypted => 'End-to-End Encrypted';

  @override
  String get noOneOutside =>
      'No one outside of this chat, not even\nthe server, can read your messages.';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInSubtitle => 'Sign in to continue securely';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get noAccount => 'Don\'t have an account? Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinSecure => 'Join the secure messenger';

  @override
  String get signUp => 'Sign Up';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get e2eEncryptionOn => 'End-to-End Encryption is ON';

  @override
  String get messageTones => 'Message tones, vibration';

  @override
  String get chooseTheme => 'Choose your theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';
}
