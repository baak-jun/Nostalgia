import 'package:flutter/material.dart';
import 'package:nostalgia/core/utils/tag_rules.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/gallery/presentation/widgets/photo_card.dart';

class TagSearchScreen extends StatefulWidget {
  const TagSearchScreen({super.key, required this.photos});

  final List<PhotoItem> photos;

  @override
  State<TagSearchScreen> createState() => _TagSearchScreenState();
}

class _TagSearchScreenState extends State<TagSearchScreen> {
  final TextEditingController controller = TextEditingController();
  String query = '';

  @override
  Widget build(BuildContext context) {
    final tokens = query
        .toLowerCase()
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    final suggestedTags = _suggestedTags();

    final filtered = widget.photos.where((item) {
      if (tokens.isEmpty) {
        return true;
      }
      final lowerTags = visibleTags(item.tags).map((tag) => tag.toLowerCase()).toSet();
      return tokens.every(lowerTags.contains);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(
              hintText: '태그 검색 (예: 영수증, 여행)',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          if (suggestedTags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestedTags
                  .map(
                    (tag) => ActionChip(
                      label: Text('#$tag'),
                      onPressed: () => _applySuggestedTag(tag),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('검색 결과가 없습니다.'))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.82,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => PhotoCard(item: filtered[index]),
                  ),
          ),
        ],
      ),
    );
  }

  List<String> _suggestedTags() {
    final counts = <String, int>{};
    for (final item in widget.photos) {
      for (final rawTag in visibleTags(item.tags)) {
        final tag = rawTag.trim().toLowerCase();
        if (tag.isEmpty) continue;
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }

    final entries = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return a.key.compareTo(b.key);
      });

    return entries.take(12).map((entry) => entry.key).toList();
  }

  void _applySuggestedTag(String tag) {
    final currentTokens = query
        .toLowerCase()
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    if (currentTokens.contains(tag)) {
      return;
    }

    currentTokens.add(tag);
    final nextQuery = currentTokens.join(', ');
    setState(() {
      query = nextQuery;
      controller.text = nextQuery;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
