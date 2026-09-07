import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nostalgia/core/utils/format_bytes.dart';
import 'package:nostalgia/features/gallery/domain/photo_item.dart';
import 'package:nostalgia/features/settings/domain/app_settings.dart';
import 'package:photo_manager/photo_manager.dart';

class SwipeClassificationCard extends StatefulWidget {
  const SwipeClassificationCard({
    super.key,
    required this.item,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSwipeUp,
    required this.onSwipeDown,
    required this.isColorBlindMode,
    required this.swipeSensitivity,
  });

  final PhotoItem item;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeUp;
  final VoidCallback onSwipeDown;
  final bool isColorBlindMode;
  final SwipeSensitivity swipeSensitivity;

  @override
  State<SwipeClassificationCard> createState() => _SwipeClassificationCardState();
}

class _SwipeClassificationCardState extends State<SwipeClassificationCard> {
  Offset _offset = Offset.zero;
  Offset _releaseVelocity = Offset.zero;
  bool _isDragging = false;

  double get _distanceThreshold {
    switch (widget.swipeSensitivity) {
      case SwipeSensitivity.easy:
        return 60;
      case SwipeSensitivity.normal:
        return 80;
      case SwipeSensitivity.precise:
        return 110;
    }
  }

  double get _flingThreshold {
    switch (widget.swipeSensitivity) {
      case SwipeSensitivity.easy:
        return 520;
      case SwipeSensitivity.normal:
        return 650;
      case SwipeSensitivity.precise:
        return 820;
    }
  }

  _SwipeActionVisual get _visual {
    if (_offset == Offset.zero) {
      return _SwipeActionVisual.neutral;
    }

    if (_offset.dx.abs() >= _offset.dy.abs()) {
      return _offset.dx >= 0
          ? _SwipeActionVisual.keep(widget.isColorBlindMode)
          : _SwipeActionVisual.defer(widget.isColorBlindMode);
    }

    return _SwipeActionVisual.skip();
  }

  void _handlePanEnd() {
    final dx = _offset.dx;
    final dy = _offset.dy;
    final vx = _releaseVelocity.dx.abs();
    final vy = _releaseVelocity.dy.abs();
    final strongHorizontalFling = vx > _flingThreshold && vx >= vy;
    final strongVerticalFling = vy > _flingThreshold && vy > vx;

    if (dx.abs() >= dy.abs() && (dx.abs() >= _distanceThreshold || strongHorizontalFling)) {
      if (dx >= 0) {
        widget.onSwipeRight();
      } else {
        widget.onSwipeLeft();
      }
      setState(() => _offset = Offset.zero);
      return;
    }

    if (dy.abs() >= _distanceThreshold || strongVerticalFling) {
      if (dy < 0) {
        widget.onSwipeUp();
      } else {
        widget.onSwipeDown();
      }
      setState(() => _offset = Offset.zero);
      return;
    }

    setState(() => _offset = Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final visual = _visual;
    final rotation = (_offset.dx / 420).clamp(-0.14, 0.14);
    final horizontalDominant = _offset.dx.abs() >= _offset.dy.abs();
    final sideOpacity = horizontalDominant ? (_offset.dx.abs() / 60).clamp(0.0, 1.0) : 0.0;
    final verticalDominant = _offset.dy.abs() > _offset.dx.abs();
    final upOpacity = verticalDominant && _offset.dy > 0
        ? (0.55 + (_offset.dy.abs() / 220)).clamp(0.55, 1.0)
        : 0.0;
    final downOpacity = verticalDominant && _offset.dy < 0
        ? (0.55 + (_offset.dy.abs() / 220)).clamp(0.55, 1.0)
        : 0.0;

    return GestureDetector(
      onPanStart: (_) => setState(() => _isDragging = true),
      onPanUpdate: (details) {
        setState(() {
          _offset += details.delta;
        });
      },
      onPanEnd: (details) {
        _releaseVelocity = details.velocity.pixelsPerSecond;
        setState(() => _isDragging = false);
        _handlePanEnd();
      },
      onPanCancel: () {
        setState(() {
          _isDragging = false;
          _offset = Offset.zero;
        });
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: visual.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: _offset.dx > 0 ? sideOpacity : 0,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bookmark_added_outlined, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            '보관',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Opacity(
                    opacity: _offset.dx < 0 ? sideOpacity : 0,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '보류함',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.pause_circle_outline, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Opacity(
                    opacity: upOpacity,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fast_forward_outlined, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            '아래로 스킵',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                    opacity: downOpacity,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fast_forward_outlined, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            '위로 스킵',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: _isDragging ? Duration.zero : const Duration(milliseconds: 170),
            curve: Curves.easeOut,
            transform: Matrix4.identity()
              ..translate(_offset.dx, _offset.dy)
              ..rotateZ(rotation),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _CardImage(item: widget.item)),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text('${widget.item.dateLabel} | ${formatBytes(widget.item.sizeBytes)}'),
                        if (widget.item.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: widget.item.tags
                                .take(3)
                                .map(
                                  (tag) => Chip(
                                    label: Text('#$tag'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeActionVisual {
  const _SwipeActionVisual({
    required this.backgroundColor,
    required this.alignment,
    required this.icon,
    required this.label,
    required this.leadingIcon,
  });

  final Color backgroundColor;
  final Alignment alignment;
  final IconData icon;
  final String label;
  final bool leadingIcon;

  static const _SwipeActionVisual neutral = _SwipeActionVisual(
    backgroundColor: Color(0xFFBFB4A6),
    alignment: Alignment.centerLeft,
    icon: Icons.swipe_up_alt,
    label: '\uC2A4\uC640\uC774\uD504',
    leadingIcon: true,
  );

  factory _SwipeActionVisual.keep(bool isColorBlindMode) => _SwipeActionVisual(
    backgroundColor: isColorBlindMode ? const Color(0xFF1F5AA5) : const Color(0xFF2E7D32),
    alignment: Alignment.centerLeft,
    icon: Icons.bookmark_added_outlined,
    label: '\uBCF4\uAD00',
    leadingIcon: true,
  );

  factory _SwipeActionVisual.defer(bool isColorBlindMode) => _SwipeActionVisual(
    backgroundColor: isColorBlindMode ? const Color(0xFF8A4B0F) : const Color(0xFFC62828),
    alignment: Alignment.centerRight,
    icon: Icons.pause_circle_outline,
    label: '\uBCF4\uB958\uD568',
    leadingIcon: false,
  );

  factory _SwipeActionVisual.skip() => const _SwipeActionVisual(
    backgroundColor: Color(0xFF6B6B6B),
    alignment: Alignment.center,
    icon: Icons.fast_forward_outlined,
    label: '\uC2A4\uD0B5',
    leadingIcon: true,
  );
}

class _CardImage extends StatefulWidget {
  const _CardImage({required this.item});

  final PhotoItem item;

  @override
  State<_CardImage> createState() => _CardImageState();
}

class _CardImageState extends State<_CardImage> {
  Future<Uint8List?>? _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = _createFuture();
  }

  @override
  void didUpdateWidget(covariant _CardImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id || oldWidget.item.asset != widget.item.asset) {
      _thumbnailFuture = _createFuture();
    }
  }

  Future<Uint8List?>? _createFuture() {
    final asset = widget.item.asset;
    if (asset == null) {
      return null;
    }
    return asset.thumbnailDataWithSize(const ThumbnailSize(1200, 1200));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.imageBytes != null && widget.item.imageBytes!.isNotEmpty) {
      return Image.memory(widget.item.imageBytes!, fit: BoxFit.cover, width: double.infinity);
    }

    if (widget.item.asset == null) {
      return Container(
        color: Colors.black12,
        alignment: Alignment.center,
        child: Icon(widget.item.isScreenshot ? Icons.screenshot_monitor : Icons.photo, size: 56),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: _thumbnailFuture,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return Container(
            color: Colors.black12,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image_outlined, size: 40),
          );
        }
        return Image.memory(bytes, fit: BoxFit.cover, width: double.infinity);
      },
    );
  }
}
