import 'package:flutter/material.dart';
import 'package:nostalgia/features/sync/data/metadata_sync_service.dart';

Future<bool> showMetadataSyncConfirmDialog(
  BuildContext context, {
  required MetadataSyncDryRunResult preview,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('메타데이터 동기화'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('대상: ${preview.targetCount}개 (jpg/jpeg)'),
          Text('미지원 포맷: ${preview.unsupportedCount}개'),
          Text('원본 파일 접근 실패: ${preview.noFileCount}개'),
          const SizedBox(height: 8),
          const Text('실행 시 복제본에 태그를 쓰고, 성공한 원본은 보류함으로 이동합니다.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('실행'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<void> showMetadataSyncResultDialog(
  BuildContext context, {
  required MetadataSyncRunResult result,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('동기화 결과'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('성공: ${result.syncedOriginalIds.length}개'),
          Text('실패: ${result.failedOriginalIds.length}개'),
          Text('미지원: ${result.unsupportedOriginalIds.length}개'),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('확인'),
        ),
      ],
    ),
  );
}
