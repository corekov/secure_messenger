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

  @override
  String get photoVideo => 'Photo/Video';

  @override
  String get camera => 'Camera';

  @override
  String get document => 'Document';

  @override
  String get fileTooLargeCompressing => 'File too large, compressing...';

  @override
  String get photoTapToDownload => 'Photo (Tap to download)';

  @override
  String get videoTapToDownload => 'Video (Tap to download)';

  @override
  String get videoTooLarge => 'Video too large. 50MB limit.';

  @override
  String get save => 'Save';

  @override
  String get aboutMe => 'About me';

  @override
  String get noBioSet => 'No bio set';

  @override
  String get tellUsAboutYourself => 'Tell us about yourself...';

  @override
  String get savedToGallery => 'Saved to Gallery';

  @override
  String get storageAndData => 'Storage & Data';

  @override
  String get autoClearCache => 'Auto-clear cache after period';

  @override
  String get never => 'Never';

  @override
  String get oneDay => '1 Day';

  @override
  String get oneWeek => '1 Week';

  @override
  String get oneMonth => '1 Month';

  @override
  String get activeStatus => 'Active';

  @override
  String get avatarUpdated => 'Avatar updated successfully';

  @override
  String avatarUpdateFailed(Object error) {
    return 'Failed to upload avatar: $error';
  }

  @override
  String get bioUpdated => 'Bio updated';

  @override
  String bioUpdateFailed(Object error) {
    return 'Failed to update bio: $error';
  }

  @override
  String get tapToRetry => 'Tap to retry';

  @override
  String get deleteForMe => 'Delete for me';

  @override
  String get deleteForEveryone => 'Delete for everyone';

  @override
  String get messageDeleted => 'Message deleted';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get imageMessage => '📷 Image';

  @override
  String get videoMessage => '🎥 Video';

  @override
  String get documentMessage => '📄 Document';

  @override
  String get audioMessage => '🎵 Audio';

  @override
  String get secretChat => 'Secret Chat';

  @override
  String get secretChatSubtitle => 'Messages delete on a timer';

  @override
  String get disappearingTimer => 'Disappearing Timer: ';

  @override
  String get seconds10 => '10 seconds';

  @override
  String get seconds30 => '30 seconds';

  @override
  String get minute1 => '1 minute';

  @override
  String get hour1 => '1 hour';

  @override
  String get secureChat => 'Secure Chat';

  @override
  String get setPinTitle => 'Set a PIN Code';

  @override
  String get setPinSubtitle => 'Create a 4-digit PIN to secure your app';

  @override
  String get confirmPinTitle => 'Confirm PIN Code';

  @override
  String get confirmPinSubtitle => 'Enter the 4-digit PIN again to confirm';

  @override
  String get pinMismatch => 'PINs do not match. Please try again.';

  @override
  String get enableBiometricsTitle => 'Enable Biometrics';

  @override
  String get enableBiometricsSubtitle =>
      'Would you like to use fingerprint or face recognition to unlock the app faster?';

  @override
  String get enable => 'Enable';

  @override
  String get skip => 'Skip';

  @override
  String get enterPinTitle => 'Enter PIN';

  @override
  String get enterPinSubtitle => 'Enter your 4-digit PIN to unlock';

  @override
  String get incorrectPin => 'Incorrect PIN. Please try again.';

  @override
  String get biometricReason => 'Please authenticate to unlock the app';

  @override
  String get biometricSettings => 'Biometric Unlock';
}
