import 'package:flutter/material.dart';
import 'package:archer_link/utils/demo_mode.dart';

/// Открывает модалку ввода пароля для демо-режима. [onConfirm] вызывается
/// после закрытия модалки, когда введён верный пароль.
void showDemoModeDialog(BuildContext context, {required VoidCallback onConfirm}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return _DemoModeDialog(
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          onConfirm();
        },
      );
    },
  );
}

/// Модалка ввода пароля для демо-режима
class _DemoModeDialog extends StatefulWidget {
  final VoidCallback onConfirm;

  const _DemoModeDialog({required this.onConfirm});

  @override
  State<_DemoModeDialog> createState() => _DemoModeDialogState();
}

class _DemoModeDialogState extends State<_DemoModeDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isPasswordCorrect = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final correct = _controller.text == demoPassword;
    if (correct != _isPasswordCorrect) {
      setState(() {
        _isPasswordCorrect = correct;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromRGBO(30, 30, 30, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок + крестик
            Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    'Demo Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white54,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Поле ввода пароля
            TextField(
              controller: _controller,
              obscureText: false,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter password',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color.fromRGBO(50, 50, 50, 1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Кнопка входа
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPasswordCorrect ? widget.onConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(85, 107, 47, 1),
                  disabledBackgroundColor: const Color.fromRGBO(60, 60, 60, 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Enter Demo Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isPasswordCorrect ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
