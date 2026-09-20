import 'package:flutter/material.dart';

class TagEditorDialog extends StatefulWidget {
  const TagEditorDialog({
    super.key,
    required this.initialTags,
    this.suggestedTags = const <String>{},
  });

  final Set<String> initialTags;
  final Set<String> suggestedTags;

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
    final normalized = value.replaceAll('#', '').trim().toLowerCase();
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
    final theme = Theme.of(context);
    final sortedTags = _tags.toList()..sort();
    final remainingSuggestions = widget.suggestedTags
        .where((s) => !_tags.contains(s.toLowerCase()))
        .take(10)
        .toList();

    return AlertDialog(
      title: const Text('태그'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Selected Active Tags (# tag)
            if (sortedTags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sortedTags
                    .map(
                      (tag) => InputChip(
                        label: Text('#$tag'),
                        selected: true,
                        selectedColor: theme.colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeTag(tag),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Recommended Suggestions (+ tag)
            if (remainingSuggestions.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: remainingSuggestions
                    .map(
                      (suggestion) => ActionChip(
                        avatar: const Icon(Icons.add, size: 16),
                        label: Text(suggestion),
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => _addTag(suggestion),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Tag input field (# 새 태그 추가)
            TextField(
              controller: _controller,
              focusNode: _inputFocusNode,
              autofocus: true,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration(
                hintText: '# 새 태그 추가',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: '태그 추가',
                  onPressed: () => _addTag(_controller.text),
                ),
              ),
            ),
          ],
        ),
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
