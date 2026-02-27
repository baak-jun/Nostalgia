import 'package:flutter/material.dart';

class TagEditorDialog extends StatefulWidget {
  const TagEditorDialog({
    super.key,
    required this.initialTags,
  });

  final Set<String> initialTags;

  @override
  State<TagEditorDialog> createState() => _TagEditorDialogState();
}

class _TagEditorDialogState extends State<TagEditorDialog> {
  late final TextEditingController _controller;
  late final FocusNode _inputFocusNode;
  late Set<String> _tags;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _inputFocusNode = FocusNode();
    _tags = {...widget.initialTags};
  }

  void _addTag(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return;
    }
    setState(() {
      _tags.add(normalized);
      _controller.clear();
    });
    _inputFocusNode.requestFocus();
  }

  void _handleSubmitted(String value) {
    if (value.trim().isEmpty) {
      Navigator.of(context).pop(_tags);
      return;
    }
    _addTag(value);
  }

  void _removeTag(String value) {
    setState(() {
      _tags.remove(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedTags = _tags.toList()..sort();

    return AlertDialog(
      title: const Text('태그 붙이기'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              focusNode: _inputFocusNode,
              autofocus: true,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration(
                hintText: '태그 입력 후 엔터',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            if (sortedTags.isEmpty)
              const Text('적용된 태그가 없습니다.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sortedTags
                    .map(
                      (tag) => InputChip(
                        label: Text('#$tag'),
                        onDeleted: () => _removeTag(tag),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_tags),
          child: const Text('저장'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }
}
