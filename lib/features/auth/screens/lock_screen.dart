import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/widgets/pin_pad.dart';
import '../../../l10n/app_localizations.dart';
import '../services/pin_auth_service.dart';
import '../providers/app_lock_provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/theme_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = '';
  String _errorMsg = '';
  bool _isCheckingBiometrics = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometrics();
    });
  }

  Future<void> _checkBiometrics() async {
    if (_isCheckingBiometrics) return;
    final isBiometricEnabled = ref.read(biometricSettingsProvider);
    if (!isBiometricEnabled) return;

    setState(() => _isCheckingBiometrics = true);
    try {
      final localAuth = LocalAuthentication();
      final l10n = AppLocalizations.of(context)!;
      final didAuthenticate = await localAuth.authenticate(
        localizedReason: l10n.biometricReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (didAuthenticate) {
        ref.read(appLockedStateProvider.notifier).unlock();
      }
    } catch (_) {
      // Fallback to PIN
    } finally {
      if (mounted) setState(() => _isCheckingBiometrics = false);
    }
  }

  void _onPinChanged(String val) async {
    setState(() {
      _errorMsg = '';
      _pin = val;
    });

    if (_pin.length == 4) {
      final isValid = await ref.read(pinAuthServiceProvider).verifyPin(_pin);
      final prefs = ref.read(sharedPreferencesProvider);
      const attemptsKey = 'pin_failed_attempts';

      if (isValid) {
        await prefs.setInt(attemptsKey, 0);
        ref.read(appLockedStateProvider.notifier).unlock();
      } else {
        int attempts = prefs.getInt(attemptsKey) ?? 0;
        attempts++;
        await prefs.setInt(attemptsKey, attempts);

        if (attempts >= 5) {
          await prefs.setInt(attemptsKey, 0);
          ref.read(authProvider.notifier).forceLogout();
        } else {
          if (mounted) {
            setState(() {
              _errorMsg = AppLocalizations.of(context)!.incorrectPin;
              _pin = '';
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isBiometricEnabled = ref.watch(biometricSettingsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).forceLogout();
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: Text(
                  'Logout',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
            const Spacer(),
            Icon(Icons.lock, size: 64, color: theme.iconTheme.color),
            const SizedBox(height: 16),
            Text(
              l10n.enterPinTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.enterPinSubtitle,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMsg.isNotEmpty)
              Text(
                _errorMsg,
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
            const SizedBox(height: 24),
            PinPadWidget(
              pinLength: 4,
              currentPin: _pin,
              onPinChanged: _onPinChanged,
              showBiometric: isBiometricEnabled,
              onBiometricTap: _checkBiometrics,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
