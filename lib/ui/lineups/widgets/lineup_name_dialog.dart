import 'package:flutter/material.dart';

import '../view_models/c01_view_model.dart';

/// Hộp thoại nhập tên đội hình (tạo mới / đổi tên). Trả `null` nếu huỷ.
Future<String?> askLineupName(
  BuildContext context, {
  required String title,
  String initial = '',
  String confirmText = 'Lưu',
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _NameDialog(title: title, initial: initial, confirmText: confirmText),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, required this.initial, required this.confirmText});

  final String title;
  final String initial;
  final String confirmText;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: lineupNameMaxLength,
          validator: validateLineupName,
          onFieldSubmitted: (_) => _submit(),
          decoration: const InputDecoration(labelText: 'Tên đội hình'),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
        FilledButton(onPressed: _submit, child: Text(widget.confirmText)),
      ],
    );
  }
}
