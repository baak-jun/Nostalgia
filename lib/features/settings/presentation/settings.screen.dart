import 'package:flutter/material.dart';
import 'package:nostalgia/features/settings/domain/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  void _close() {
    Navigator.of(context).pop(_settings);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _close();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('설정'),
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            SwitchListTile(
              value: _settings.isColorBlindMode,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(isColorBlindMode: value);
                });
              },
              title: const Text('색약 모드'),
              subtitle: const Text('보관/보류 색 대비를 색약 친화 조합으로 변경'),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('스와이프 감도', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    SegmentedButton<SwipeSensitivity>(
                      segments: const [
                        ButtonSegment<SwipeSensitivity>(
                          value: SwipeSensitivity.easy,
                          label: Text('쉬움'),
                        ),
                        ButtonSegment<SwipeSensitivity>(
                          value: SwipeSensitivity.normal,
                          label: Text('보통'),
                        ),
                        ButtonSegment<SwipeSensitivity>(
                          value: SwipeSensitivity.precise,
                          label: Text('정밀'),
                        ),
                      ],
                      selected: <SwipeSensitivity>{_settings.swipeSensitivity},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _settings = _settings.copyWith(
                            swipeSensitivity: selection.first,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 6),
                    const Text('쉬움: 적은 이동으로 분류 / 정밀: 더 크게 움직여야 분류'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('메타데이터 & 갤러리 검색 동기화', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _settings.syncSamsungFilenameTags,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(syncSamsungFilenameTags: value);
                        });
                      },
                      title: const Text('삼성 갤러리 검색 연동 (파일명 태깅)'),
                      subtitle: const Text('삼성 갤러리 및 내 파일 검색창에서 #태그로 검색 가능하도록 파일명에 태그 포함'),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _settings.writeExifMetadata,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(writeExifMetadata: value);
                        });
                      },
                      title: const Text('표준 EXIF 메타데이터 기록'),
                      subtitle: const Text('PC/클라우드/라이트룸 호환을 위해 UserComment 및 ImageDescription에 태그 기록 (원본 안전 제자리 수정)'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
