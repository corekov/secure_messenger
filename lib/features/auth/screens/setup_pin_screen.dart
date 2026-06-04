import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/widgets/pin_pad.dart';
import '../../../l10n/app_localizations.dart';
import '../services/pin_auth_service.dart';
import '../providers/app_lock_provider.dart';

class SetupPinScreen extends ConsumerStatefulWidget {
  const SetupPinScreen({super.key});

  @override
  ConsumerState<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends ConsumerState<SetupPinScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _errorMsg = '';

  void _onPinChanged(String val) async {
    setState(() {
      _errorMsg = '';
      if (!_isConfirming) {
        _pin = val;
        if (_pin.length == 4) {
          _isConfirming = true;
        }
      } else {
        _confirmPin = val;
        if (_confirmPin.length == 4) {
          _verifyAndSave();
        }
      }
    });
  }

  Future<void> _verifyAndSave() async {
    final l10n = AppLocalizations.of(context)!;
    if (_pin == _confirmPin) {
      await ref.read(pinAuthServiceProvider).savePin(_pin);
      ref.read(hasPinStateProvider.notifier).setHasPin(true);
      
      // Check for biometrics
      final localAuth = LocalAuthentication();
      final canCheckBiometrics = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();

      if (canCheckBiometrics || isDeviceSupported) {
        if (!mounted) return;
        _showBiometricPrompt(l10n, localAuth);
      } else {
        if (!mounted) return;
        context.go('/chats');
      }
    } else {
      setState(() {
        _pin = '';
        _confirmPin = '';
        _isConfirming = false;
        _errorMsg = l10n.pinMismatch;
      });
    }
  }

  void _showBiometricPrompt(AppLocalizations l10n, LocalAuthentication localAuth) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.enableBiometricsTitle),
        content: Text(l10n.enableBiometricsSubtitle),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.go('/chats');
            },
            child: Text(l10n.skip),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final didAuthenticate = await localAuth.authenticate(
                  localizedReason: l10n.biometricReason,
                  biometricOnly: true,
                  persistAcrossBackgrounding: true,
                );
                if (didAuthenticate) {
                  await ref.read(biometricSettingsProvider.notifier).setBiometricEnabled(true);
                }
              } catch (_) {}
              
              if (mounted) {
                context.go('/chats');
              }
            },
            child: Text(l10n.enable),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isConfirming ? l10n.confirmPinTitle : l10n.setPinTitle),
        automaticallyImplyLeading: false, // User must set PIN to proceed
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Icon(
              _isConfirming ? Icons.check_circle_outline : Icons.lock_outline,
              size: 64,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            Text(
              _isConfirming ? l10n.confirmPinSubtitle : l10n.setPinSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMsg.isNotEmpty)
              Text(
                _errorMsg,
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
            const Spacer(),
            PinPadWidget(
              pinLength: 4,
              currentPin: _isConfirming ? _confirmPin : _pin,
              onPinChanged: _onPinChanged,
              onBiometricTap: () {},
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
