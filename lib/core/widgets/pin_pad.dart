import 'package:flutter/material.dart';

class PinPadWidget extends StatelessWidget {
  final int pinLength;
  final String currentPin;
  final ValueChanged<String> onPinChanged;
  final VoidCallback onBiometricTap;
  final bool showBiometric;

  const PinPadWidget({
    super.key,
    required this.pinLength,
    required this.currentPin,
    required this.onPinChanged,
    required this.onBiometricTap,
    this.showBiometric = false,
  });

  void _handleKeyPress(String value) {
    if (currentPin.length < pinLength) {
      onPinChanged(currentPin + value);
    }
  }

  void _handleBackspace() {
    if (currentPin.isNotEmpty) {
      onPinChanged(currentPin.substring(0, currentPin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pinLength, (index) {
            final isFilled = index < currentPin.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? Colors.blueAccent : Colors.transparent,
                border: Border.all(
                  color: isFilled ? Colors.blueAccent : Colors.grey,
                  width: 2,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 48),
        // Keypad
        SizedBox(
          width: 280,
          child: Column(
            children: [
              _buildRow(['1', '2', '3']),
              const SizedBox(height: 16),
              _buildRow(['4', '5', '6']),
              const SizedBox(height: 16),
              _buildRow(['7', '8', '9']),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBiometricButton(),
                  _buildNumberButton('0'),
                  _buildBackspaceButton(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((n) => _buildNumberButton(n)).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _handleKeyPress(number),
      customBorder: const CircleBorder(),
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withAlpha(20),
        ),
        child: Text(
          number,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return InkWell(
      onTap: _handleBackspace,
      customBorder: const CircleBorder(),
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        child: const Icon(Icons.backspace_outlined, size: 28),
      ),
    );
  }

  Widget _buildBiometricButton() {
    if (!showBiometric) {
      return const SizedBox(width: 72, height: 72);
    }
    return InkWell(
      onTap: onBiometricTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        child: const Icon(Icons.fingerprint, size: 36, color: Colors.blueAccent),
      ),
    );
  }
}
